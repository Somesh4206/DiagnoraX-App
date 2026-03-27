import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';
import '../services/gemini_service.dart';

class DoctorRecommendationsScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const DoctorRecommendationsScreen({super.key, required this.user});

  @override
  State<DoctorRecommendationsScreen> createState() =>
      _DoctorRecommendationsScreenState();
}

class _DoctorRecommendationsScreenState
    extends State<DoctorRecommendationsScreen> {
  final _specialtyCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  bool _loading = false;
  List<DoctorRecommendation> _doctors = [];

  final List<String> _specialties = [
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Neurologist',
    'Orthopedist',
    'Pediatrician',
    'Gynecologist',
    'Psychiatrist',
    'Dentist',
    'Ophthalmologist',
  ];

  Future<void> _search() async {
    final specialty = _specialtyCtrl.text.trim();
    final location = _locationCtrl.text.trim();
    if (specialty.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter both specialty and location')));
      return;
    }
    setState(() {
      _loading = true;
      _doctors = [];
    });
    try {
      final docs = await GeminiService.getDoctorRecommendations(
          specialty: specialty, location: location);
      setState(() => _doctors = docs);
    } catch (e) {
      final errorMsg = e.toString();
      final isApiKeyError = errorMsg.contains('API key') || errorMsg.contains('400');
      
      if (mounted) {
        if (isApiKeyError) {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: ApiKeySetupBanner(),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Search failed: $e')),
          );
        }
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _specialtyCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

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
              color: AppTheme.yellowAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.local_hospital_outlined,
                color: AppTheme.yellowAccent, size: 18),
          ),
          const SizedBox(width: 10),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Find Doctors',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('AI-powered recommendations',
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ]),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Search Card
          GlassCard(
            highlight: true,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Find a Specialist',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text(
                  'Get AI-recommended doctors based on specialty and location.',
                  style:
                      TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              const SizedBox(height: 20),
              NeonTextField(
                hint: 'e.g., Cardiologist',
                label: 'Specialty',
                controller: _specialtyCtrl,
                prefix: const Icon(Icons.medical_services_outlined,
                    size: 18, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 16),
              NeonTextField(
                hint: 'e.g., Mumbai, India',
                label: 'Location',
                controller: _locationCtrl,
                prefix: const Icon(Icons.location_on_outlined,
                    size: 18, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 16),

              // Specialty Quick Chips
              const Text('QUICK SELECT',
                  style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _specialties
                    .map((s) => GestureDetector(
                          onTap: () =>
                              setState(() => _specialtyCtrl.text = s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _specialtyCtrl.text == s
                                  ? AppTheme.neonGreenDim
                                  : Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _specialtyCtrl.text == s
                                      ? AppTheme.neonGreenBorder
                                      : AppTheme.borderColor),
                            ),
                            child: Text(s,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: _specialtyCtrl.text == s
                                        ? AppTheme.neonGreen
                                        : AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 20),
              NeonButton(
                label: 'Find Doctors',
                icon: Icons.search,
                loading: _loading,
                fullWidth: true,
                onTap: _search,
              ),
            ]),
          ),

          if (_loading) ...[
            const SizedBox(height: 32),
            const NeonLoader(message: 'Finding doctors near you...'),
          ],

          if (_doctors.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              '${_doctors.length} Doctors Found',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _doctors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _DoctorCard(doc: _doctors[i]),
            ),
            const SizedBox(height: 16),
            const DisclaimerBanner(
                text:
                    'Note: These are AI-generated suggestions. Always verify doctor credentials and availability independently.'),
          ],

          if (_doctors.isEmpty && !_loading) ...[
            const SizedBox(height: 28),
            EmptyState(
              icon: Icons.local_hospital_outlined,
              message:
                  'Enter a specialty and location\nto find recommended doctors.',
            ),
          ],
        ]),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final DoctorRecommendation doc;
  const _DoctorCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.yellowAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                doc.name.isNotEmpty ? doc.name[0] : 'D',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.yellowAccent),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doc.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text(doc.specialty,
                      style: const TextStyle(
                          color: AppTheme.neonGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ]),
          ),
          // Rating
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(children: [
              const Icon(Icons.star_rounded,
                  color: AppTheme.yellowAccent, size: 16),
              const SizedBox(width: 3),
              Text(doc.rating.toStringAsFixed(1),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ]),
            Text('${doc.experience} yrs exp',
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 11)),
          ]),
        ]),

        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 10),

        Row(children: [
          const Icon(Icons.local_hospital_outlined,
              size: 14, color: AppTheme.textMuted),
          const SizedBox(width: 6),
          Expanded(
              child: Text(doc.hospital,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13))),
        ]),

        const SizedBox(height: 8),

        Row(children: [
          const Icon(Icons.phone_outlined,
              size: 14, color: AppTheme.textMuted),
          const SizedBox(width: 6),
          Text(doc.phone,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.neonGreenDim,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.neonGreenBorder),
              ),
              child: const Text('Book',
                  style: TextStyle(
                      color: AppTheme.neonGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ]),
    );
  }
}
