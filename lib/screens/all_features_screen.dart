import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';
import 'prescription_scanner_screen.dart';
import 'report_analyzer_screen.dart';
import 'drug_interaction_screen.dart';
import 'doctor_recommendations_screen.dart';

class AllFeaturesScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  const AllFeaturesScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.neonGreenDim,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.apps_rounded,
                color: AppTheme.neonGreen, size: 18),
          ),
          const SizedBox(width: 10),
          const Text('All Features',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Medical Tools',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMuted,
                  letterSpacing: 1.5)),
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _FeatureTile(
                icon: Icons.document_scanner_outlined,
                title: 'Prescription\nScanner',
                subtitle: 'Extract medicines',
                color: AppTheme.neonGreen,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            PrescriptionScannerScreen(user: user))),
              ),
              _FeatureTile(
                icon: Icons.analytics_outlined,
                title: 'Report\nAnalyzer',
                subtitle: 'Lab report insights',
                color: AppTheme.purpleAccent,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ReportAnalyzerScreen(user: user))),
              ),
              _FeatureTile(
                icon: Icons.shield_outlined,
                title: 'Drug\nInteractions',
                subtitle: 'Safety checker',
                color: AppTheme.redAccent,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            DrugInteractionScreen(user: user))),
              ),
              _FeatureTile(
                icon: Icons.local_hospital_outlined,
                title: 'Find\nDoctors',
                subtitle: 'Near you',
                color: AppTheme.yellowAccent,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            DoctorRecommendationsScreen(user: user))),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Tip banner
          GlassCard(
            highlight: true,
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.blueAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.tips_and_updates_outlined,
                    color: AppTheme.blueAccent, size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pro Tip',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 4),
                      Text(
                          'Use Prescription Scanner after a doctor visit to automatically set medication reminders.',
                          style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              height: 1.4)),
                    ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.22)),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const Spacer(),
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.3)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 11, color: color.withOpacity(0.7))),
            ]),
      ),
    );
  }
}
