import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'symptom_checker_screen.dart';
import 'body_analyzer_screen.dart';
import 'reminders_screen.dart';
import 'profile_screen.dart';
import 'all_features_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _userData;
  bool _loading = true;

  List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = AuthService.currentUser;
    if (user != null) {
      final data = await AuthService.getUserProfile(user.uid);
      if (mounted) {
        setState(() {
          _userData = {
            'uid': user.uid,
            'email': user.email ?? '',
            'displayName': data?['displayName'] ?? user.displayName ?? 'User',
            'photoURL': user.photoURL,
            'age': data?['age'],
            'gender': data?['gender'],
            'contact': data?['contact'],
            'medicalHistory': data?['medicalHistory'],
          };
          _loading = false;
          _initScreens();
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _userData = {
            'displayName': 'User',
            'email': '',
            'uid': '',
          };
          _loading = false;
          _initScreens();
        });
      }
    }
  }

  void _initScreens() {
    _screens = [
      DashboardScreen(user: _userData!, onNavigate: _navigateTo),
      SymptomCheckerScreen(user: _userData!),
      const BodyAnalyzerScreen(),
      RemindersScreen(user: _userData!),
      AllFeaturesScreen(user: _userData!),
      ProfileScreen(user: _userData!, onProfileUpdated: _loadUserData),
    ];
  }

  void _navigateTo(int index) {
    setState(() => _currentIndex = index);
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

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home', active: currentIndex == 0, onTap: () => onTap(0)),
              _NavItem(icon: Icons.medical_services_outlined, activeIcon: Icons.medical_services, label: 'Symptoms', active: currentIndex == 1, onTap: () => onTap(1)),
              _NavItem(icon: Icons.monitor_weight_outlined, activeIcon: Icons.monitor_weight, label: 'Body', active: currentIndex == 2, onTap: () => onTap(2)),
              _NavItem(icon: Icons.notifications_outlined, activeIcon: Icons.notifications_rounded, label: 'Reminders', active: currentIndex == 3, onTap: () => onTap(3)),
              _NavItem(icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view_rounded, label: 'More', active: currentIndex == 4, onTap: () => onTap(4)),
              _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile', active: currentIndex == 5, onTap: () => onTap(5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.neonGreenDim : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: active ? Border.all(color: AppTheme.neonGreenBorder) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? activeIcon : icon, size: 21, color: active ? AppTheme.neonGreen : AppTheme.textMuted),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.3, color: active ? AppTheme.neonGreen : AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}
