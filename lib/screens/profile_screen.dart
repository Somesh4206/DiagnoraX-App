import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback? onProfileUpdated;

  const ProfileScreen({super.key, required this.user, this.onProfileUpdated});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _contactCtrl;
  late TextEditingController _historyCtrl;
  String _gender = 'male';
  bool _saving = false;
  bool _saved = false;
  bool _loading = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _ageCtrl = TextEditingController();
    _contactCtrl = TextEditingController();
    _historyCtrl = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = AuthService.currentUser;
      if (user != null) {
        final data = await AuthService.getUserProfile(user.uid);
        if (mounted) {
          setState(() {
            _userData = data;
            _nameCtrl.text = data?['displayName'] ?? user.displayName ?? '';
            _emailCtrl.text = data?['email'] ?? user.email ?? '';
            _ageCtrl.text = data?['age']?.toString() ?? '';
            _contactCtrl.text = data?['contact'] ?? '';
            _historyCtrl.text = data?['medicalHistory'] ?? '';
            _gender = data?['gender'] ?? 'male';
            _loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _ageCtrl.dispose();
    _contactCtrl.dispose();
    _historyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      await AuthService.updateUserProfile(
        uid: user.uid,
        displayName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        age: int.tryParse(_ageCtrl.text),
        gender: _gender,
        contact: _contactCtrl.text.trim(),
        medicalHistory: _historyCtrl.text.trim(),
      );
      
      setState(() {
        _saving = false;
        _saved = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppTheme.neonGreen,
          ),
        );
        
        // Notify parent to reload user data
        widget.onProfileUpdated?.call();
      }
      
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _saved = false);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.neonGreen),
        ),
      );
    }

    final displayName = _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'User';
    final email = _emailCtrl.text;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: const Text('Profile'),
        actions: [
          if (_saved)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.neonGreen, size: 18),
                  SizedBox(width: 6),
                  Text('Saved!',
                      style: TextStyle(
                          color: AppTheme.neonGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ],
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar Section
            GlassCard(
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.neonGreenDim,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.neonGreenBorder, width: 2),
                      boxShadow: neonGlowShadow(opacity: 0.15),
                    ),
                    child: Center(
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.neonGreen,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined,
                                size: 13, color: AppTheme.textMuted),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                email,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Basic Info
            GlassCard(
              highlight: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.person_outline,
                          color: AppTheme.neonGreen, size: 20),
                      SizedBox(width: 8),
                      Text('Basic Information',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  NeonTextField(
                    hint: 'Full Name',
                    label: 'Name',
                    controller: _nameCtrl,
                  ),
                  const SizedBox(height: 16),
                  NeonTextField(
                    hint: 'email@example.com',
                    label: 'Email',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  NeonTextField(
                    hint: '25',
                    label: 'Age',
                    controller: _ageCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  NeonTextField(
                    hint: '+1234567890',
                    label: 'Contact Number',
                    controller: _contactCtrl,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'GENDER',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: [
                      _GenderOption(
                          label: 'Male',
                          selected: _gender == 'male',
                          onTap: () => setState(() => _gender = 'male')),
                      _GenderOption(
                          label: 'Female',
                          selected: _gender == 'female',
                          onTap: () => setState(() => _gender = 'female')),
                      _GenderOption(
                          label: 'Other',
                          selected: _gender == 'other',
                          onTap: () => setState(() => _gender = 'other')),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Medical History
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.history_edu_outlined,
                          color: AppTheme.blueAccent, size: 20),
                      SizedBox(width: 8),
                      Text('Medical History',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  NeonTextField(
                    hint:
                        'e.g., Diabetes, Hypertension, Allergies...',
                    controller: _historyCtrl,
                    maxLines: 4,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            NeonButton(
              label: 'Save Profile',
              icon: Icons.save_outlined,
              loading: _saving,
              fullWidth: true,
              onTap: _save,
            ),

            const SizedBox(height: 16),

            // Logout
            OutlinedButton.icon(
              onPressed: () async {
                await AuthService.signOut();
                if (mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                foregroundColor: Colors.red.shade400,
                side: BorderSide(color: Colors.red.shade400, width: 1.5),
              ),
            ),

            const SizedBox(height: 32),

            // App info
            const Text(
              'DiagnoraX AI v1.0.0\nNot a substitute for professional medical advice.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.neonGreenDim
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                selected ? AppTheme.neonGreenBorder : AppTheme.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppTheme.neonGreen : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
