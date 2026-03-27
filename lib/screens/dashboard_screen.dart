import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';

class DashboardScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  final ValueChanged<int> onNavigate;

  const DashboardScreen({
    super.key,
    required this.user,
    required this.onNavigate,
  });

  String get _firstName =>
      (user['displayName'] as String? ?? 'User').split(' ').first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'OVERVIEW',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Welcome back,\n$_firstName 👋',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Health Score
                  GlassCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.neonGreenDim,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: AppTheme.neonGreen,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'HEALTH SCORE',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '84/100',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.history_rounded,
                      iconColor: AppTheme.blueAccent,
                      label: 'Checks',
                      value: '12',
                      trend: '+2',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.medication_rounded,
                      iconColor: AppTheme.neonGreen,
                      label: 'Meds',
                      value: '3',
                      trend: '2d',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.notifications_rounded,
                      iconColor: AppTheme.yellowAccent,
                      label: 'Alerts',
                      value: '5',
                      trend: '2 PM',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _ActionCard(
                    icon: Icons.medical_services,
                    title: 'Check Symptoms',
                    description: 'AI-powered prediction',
                    color: AppTheme.blueAccent,
                    onTap: () => onNavigate(1),
                  ),
                  _ActionCard(
                    icon: Icons.document_scanner_outlined,
                    title: 'Scan Prescription',
                    description: 'Extract & set reminders',
                    color: AppTheme.neonGreen,
                    onTap: () => _navigateToFeature(context, 'prescription'),
                  ),
                  _ActionCard(
                    icon: Icons.analytics_outlined,
                    title: 'Analyze Report',
                    description: 'Lab report insights',
                    color: AppTheme.purpleAccent,
                    onTap: () => _navigateToFeature(context, 'report'),
                  ),
                  _ActionCard(
                    icon: Icons.monitor_weight_outlined,
                    title: 'Body Analysis',
                    description: 'Fat, Bone & Water',
                    color: AppTheme.emeraldAccent,
                    onTap: () => onNavigate(2),
                  ),
                  _ActionCard(
                    icon: Icons.shield_outlined,
                    title: 'Drug Safety',
                    description: 'Check interactions',
                    color: AppTheme.redAccent,
                    onTap: () => _navigateToFeature(context, 'interactions'),
                  ),
                  _ActionCard(
                    icon: Icons.local_hospital_outlined,
                    title: 'Find Doctors',
                    description: 'Near you',
                    color: AppTheme.yellowAccent,
                    onTap: () => _navigateToFeature(context, 'doctors'),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Health Insights
              GlassCard(
                highlight: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.favorite, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Health Insights',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _InsightItem(
                      icon: Icons.water_drop_outlined,
                      iconColor: AppTheme.blueAccent,
                      title: 'Stay Hydrated',
                      description:
                          'Based on your recent reports, increasing water intake could improve your energy levels.',
                    ),
                    const Divider(height: 24),
                    _InsightItem(
                      icon: Icons.medication_outlined,
                      iconColor: AppTheme.yellowAccent,
                      title: 'Medication',
                      description:
                          'You have 2 medicines scheduled for this afternoon. Don\'t forget to take them.',
                    ),
                    const Divider(height: 24),
                    _InsightItem(
                      icon: Icons.directions_walk_outlined,
                      iconColor: AppTheme.neonGreen,
                      title: 'Activity Level',
                      description:
                          'Your activity has been low this week. Try a 15-minute walk today.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToFeature(BuildContext context, String feature) {
    // Navigate to sub-screens
    Widget? screen;
    switch (feature) {
      case 'prescription':
        // screen = PrescriptionScannerScreen();
        break;
      case 'report':
        // screen = ReportAnalyzerScreen();
        break;
      case 'interactions':
        // screen = DrugInteractionScreen();
        break;
      case 'doctors':
        // screen = DoctorRecommendationsScreen();
        break;
    }
    if (screen != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => screen!),
      );
    }
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 26),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _InsightItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
