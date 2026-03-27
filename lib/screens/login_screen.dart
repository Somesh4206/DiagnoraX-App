import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  bool _isLogin = true;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_fadeController);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _loading = true);
    try {
      if (_isLogin) {
        await AuthService.signInWithEmail(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
      } else {
        await AuthService.registerWithEmail(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          name: _nameCtrl.text.trim(),
        );
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isLogin ? 'Login failed: $e' : 'Registration failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _loading = true);
    try {
      await AuthService.signInWithGoogle();
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString();
        
        if (errorMsg.contains('PEOPLE_API_DISABLED')) {
          _showPeopleApiDialog();
        } else if (errorMsg.contains('OAUTH_NOT_CONFIGURED')) {
          _showOAuthSetupDialog();
        } else if (errorMsg.contains('CLIENT_ID_MISSING') || errorMsg.contains('not configured')) {
          _showClientIdDialog();
        } else if (errorMsg.contains('cancelled')) {
          // User cancelled, no need to show error
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Google sign-in failed: ${errorMsg.replaceAll('Exception: ', '')}'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showPeopleApiDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.api_outlined, color: AppTheme.yellowAccent),
            SizedBox(width: 10),
            Expanded(child: Text('Enable People API', style: TextStyle(fontSize: 18))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The Google People API needs to be enabled for Google Sign-In to work:',
                style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 16),
              _buildStep('1', 'Click the link below to enable the API:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.neonGreenDim.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.neonGreenBorder),
                ),
                child: const SelectableText(
                  'https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=858146532130',
                  style: TextStyle(
                    color: AppTheme.neonGreen,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildStep('2', 'Click "Enable API" button'),
              _buildStep('3', 'Wait 1-2 minutes for activation'),
              _buildStep('4', 'Refresh this app and try again'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.neonGreenDim.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.neonGreenBorder),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.neonGreen, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Or use Email/Password login instead',
                        style: TextStyle(color: AppTheme.neonGreen, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it', style: TextStyle(color: AppTheme.neonGreen)),
          ),
        ],
      ),
    );
  }

  void _showOAuthSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.settings_outlined, color: AppTheme.yellowAccent),
            SizedBox(width: 10),
            Expanded(child: Text('OAuth Configuration Required', style: TextStyle(fontSize: 18))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Google Sign-In needs OAuth configuration in Google Cloud Console:',
                style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 16),
              _buildStep('1', 'Go to Google Cloud Console'),
              _buildStep('2', 'Navigate to: APIs & Services → Credentials'),
              _buildStep('3', 'Click on OAuth 2.0 Client ID:\n858146532130-rmnpqqbtkcr4k3thlaho5drr252kkvq9'),
              _buildStep('4', 'Add Authorized JavaScript origins:\nhttp://localhost'),
              _buildStep('5', 'Add Authorized redirect URIs:\nhttp://localhost/__/auth/handler'),
              _buildStep('6', 'Save and wait 5 minutes'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.neonGreenDim.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.neonGreenBorder),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.neonGreen, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Or use Email/Password login instead',
                        style: TextStyle(color: AppTheme.neonGreen, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it', style: TextStyle(color: AppTheme.neonGreen)),
          ),
        ],
      ),
    );
  }

  void _showClientIdDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppTheme.yellowAccent),
            SizedBox(width: 10),
            Text('Client ID Missing'),
          ],
        ),
        content: const Text(
          'Google Sign-In requires Client ID configuration.\n\n'
          'Please use Email/Password login instead, or:\n\n'
          '1. Go to Firebase Console\n'
          '2. Authentication → Google\n'
          '3. Copy Web client ID\n'
          '4. Add to web/index.html',
          style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppTheme.neonGreen)),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.neonGreenDim,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.neonGreen),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppTheme.neonGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.neonGreenDim,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.neonGreenBorder),
                      boxShadow: neonGlowShadow(),
                    ),
                    child: const Icon(
                      Icons.monitor_heart_outlined,
                      size: 42,
                      color: AppTheme.neonGreen,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1.2,
                      ),
                      children: [
                        TextSpan(
                          text: 'Diagnora',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'X',
                          style: TextStyle(color: AppTheme.neonGreen),
                        ),
                        TextSpan(
                          text: ' AI',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  const Text(
                    'Your AI Health Assistant',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Email/Password Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (!_isLogin) ...[
                          TextFormField(
                            controller: _nameCtrl,
                            style: const TextStyle(color: AppTheme.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Full Name',
                              prefixIcon: const Icon(Icons.person_outline, color: AppTheme.neonGreen),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppTheme.borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppTheme.borderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppTheme.neonGreen, width: 2),
                              ),
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.neonGreen),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppTheme.borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppTheme.borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppTheme.neonGreen, width: 2),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Email is required';
                            if (!val.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: true,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.neonGreen),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppTheme.borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppTheme.borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppTheme.neonGreen, width: 2),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Password is required';
                            if (val.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // Login/Register Button
                        GestureDetector(
                          onTap: _loading ? null : _handleEmailAuth,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.neonGreen,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: _loading
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: AppTheme.neonGreen.withOpacity(0.35),
                                        blurRadius: 20,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ),
                            child: _loading
                                ? const Center(
                                    child: SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation(Colors.black),
                                      ),
                                    ),
                                  )
                                : Text(
                                    _isLogin ? 'Login' : 'Register',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Toggle Login/Register
                        GestureDetector(
                          onTap: () => setState(() => _isLogin = !_isLogin),
                          child: Text(
                            _isLogin
                                ? "Don't have an account? Register"
                                : 'Already have an account? Login',
                            style: const TextStyle(
                              color: AppTheme.neonGreen,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Container(height: 1, color: AppTheme.borderColor)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(child: Container(height: 1, color: AppTheme.borderColor)),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Google Sign In Button
                  GestureDetector(
                    onTap: _loading ? null : _handleGoogleSignIn,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_loading) ...[
                            const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation(Colors.black),
                              ),
                            ),
                          ] else ...[
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.g_mobiledata_rounded,
                                color: Colors.blue,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Continue with Google',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Terms
                  const Text(
                    'By continuing, you agree to our Terms of Service.\nDiagnoraX is not a substitute for professional medical advice.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
