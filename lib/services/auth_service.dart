import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email/Password Registration
  static Future<User?> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        
        // Create user document in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'displayName': name,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Email/Password Login
  static Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Phone Authentication - Send OTP
  static Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) codeSent,
    required Function(String error) verificationFailed,
    required Function(User? user) verificationCompleted,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        final userCredential = await _auth.signInWithCredential(credential);
        verificationCompleted(userCredential.user);
      },
      verificationFailed: (FirebaseAuthException e) {
        verificationFailed(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // Phone Authentication - Verify OTP
  static Future<User?> signInWithPhoneOTP({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Create user document if new user
      if (userCredential.user != null) {
        final userDoc = _firestore.collection('users').doc(userCredential.user!.uid);
        final docSnapshot = await userDoc.get();
        
        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': userCredential.user!.uid,
            'phoneNumber': userCredential.user!.phoneNumber,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
      
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Google Sign In
  static Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      // Create or update user document
      if (user != null) {
        final userDoc = _firestore.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();
        
        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName,
            'photoURL': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'web-context-cancelled') {
        throw Exception('Google Sign-In was cancelled');
      }
      throw Exception('Google Sign-In failed: ${e.message}');
    } catch (e) {
      final errorStr = e.toString();
      
      // Handle People API not enabled
      if (errorStr.contains('People API') || errorStr.contains('SERVICE_DISABLED')) {
        throw Exception('PEOPLE_API_DISABLED');
      }
      
      // Handle OAuth configuration errors
      if (errorStr.contains('401') || errorStr.contains('invalid_client')) {
        throw Exception('OAUTH_NOT_CONFIGURED');
      }
      
      if (errorStr.contains('ClientID not set')) {
        throw Exception('CLIENT_ID_MISSING');
      }
      
      rethrow;
    }
  }

  // Sign Out
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Update user profile in Firestore
  static Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? email,
    int? age,
    String? gender,
    String? contact,
    String? medicalHistory,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updates['displayName'] = displayName;
      if (email != null) updates['email'] = email;
      if (age != null) updates['age'] = age;
      if (gender != null) updates['gender'] = gender;
      if (contact != null) updates['contact'] = contact;
      if (medicalHistory != null) updates['medicalHistory'] = medicalHistory;

      await _firestore.collection('users').doc(uid).update(updates);

      // Update Firebase Auth display name if changed
      if (displayName != null && currentUser != null) {
        await currentUser!.updateDisplayName(displayName);
      }

      // Update Firebase Auth email if changed
      if (email != null && currentUser != null) {
        await currentUser!.verifyBeforeUpdateEmail(email);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile from Firestore
  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      rethrow;
    }
  }

  // Stream user profile
  static Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }
}
