import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';
import '../services/gemini_service.dart';

class BodyAnalyzerScreen extends StatefulWidget {
  const BodyAnalyzerScreen({super.key});

  @override
  State<BodyAnalyzerScreen> createState() => _BodyAnalyzerScreenState();
}

class _BodyAnalyzerScreenState extends State<BodyAnalyzerScreen> {
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String _gender = 'male';
  bool _loading = false;
  BodyCompositionAnalysis? _result;

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final h = double.tryParse(_heightCtrl.text);
    final w = double.tryParse(_weightCtrl.text);
    final a = int.tryParse(_ageCtrl.text);

    if (h == null || w == null || a == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields correctly')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      final analysis = await GeminiService.analyzeBodyComposition(
        height: h,
        weight: w,
        age: a,
        gender: _gender,
      );
      setState(() => _result = analysis);
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
            SnackBar(content: Text('Analysis failed: $e')),
          );
        }
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.emeraldAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.monitor_weight_outlined,
                  color: AppTheme.emeraldAccent, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Body Composition',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('AI body analysis',
                    style:
                        TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Card
            GlassCard(
              highlight: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Measurements',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: NeonTextField(
                          hint: '170',
                          label: 'Height (cm)',
                          controller: _heightCtrl,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: NeonTextField(
                          hint: '70',
                          label: 'Weight (kg)',
                          controller: _weightCtrl,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  NeonTextField(
                    hint: '25',
                    label: 'Age',
                    controller: _ageCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  // Gender Selector
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
                  Row(
                    children: [
                      _GenderChip(
                        label: 'Male',
                        icon: Icons.male,
                        selected: _gender == 'male',
                        onTap: () => setState(() => _gender = 'male'),
                      ),
                      const SizedBox(width: 10),
                      _GenderChip(
                        label: 'Female',
                        icon: Icons.female,
                        selected: _gender == 'female',
                        onTap: () => setState(() => _gender = 'female'),
                      ),
                      const SizedBox(width: 10),
                      _GenderChip(
                        label: 'Other',
                        icon: Icons.person_outline,
                        selected: _gender == 'other',
                        onTap: () => setState(() => _gender = 'other'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  NeonButton(
                    label: 'Analyze Body Composition',
                    icon: Icons.analytics_outlined,
                    loading: _loading,
                    fullWidth: true,
                    onTap: _analyze,
                  ),
                ],
              ),
            ),

            if (_loading) ...[
              const SizedBox(height: 32),
              const NeonLoader(message: 'Analyzing body composition...'),
            ],

            if (_result != null) ...[
              const SizedBox(height: 24),
              _ResultSection(result: _result!),
            ],
          ],
        ),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.neonGreenDim : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.neonGreenBorder : AppTheme.borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? AppTheme.neonGreen : AppTheme.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppTheme.neonGreen : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  final BodyCompositionAnalysis result;

  const _ResultSection({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analysis Results',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),

        // BMI Highlight
        GlassCard(
          highlight: true,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.neonGreenDim,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.monitor_weight_outlined,
                    color: AppTheme.neonGreen, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('BMI',
                      style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text(
                    result.bmi.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neonGreen,
                    ),
                  ),
                  Text(
                    _getBMICategory(result.bmi),
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Metrics Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _MetricCard(
                label: 'Body Fat',
                value: '${result.fatPercentage.toStringAsFixed(1)}%',
                icon: Icons.opacity_outlined,
                color: AppTheme.redAccent),
            _MetricCard(
                label: 'Muscle Mass',
                value: '${result.muscleMass.toStringAsFixed(1)} kg',
                icon: Icons.fitness_center_outlined,
                color: AppTheme.blueAccent),
            _MetricCard(
                label: 'Water Content',
                value: '${result.waterContent.toStringAsFixed(1)}%',
                icon: Icons.water_drop_outlined,
                color: AppTheme.neonGreen),
            _MetricCard(
                label: 'Bone Mass',
                value: '${result.boneMass.toStringAsFixed(1)} kg',
                icon: Icons.category_outlined,
                color: AppTheme.yellowAccent),
            _MetricCard(
                label: 'Visceral Fat',
                value: result.visceralFat.toStringAsFixed(1),
                icon: Icons.warning_amber_outlined,
                color: AppTheme.purpleAccent),
          ],
        ),

        const SizedBox(height: 14),

        // Insights
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.lightbulb_outline,
                      color: AppTheme.yellowAccent, size: 20),
                  SizedBox(width: 8),
                  Text('Health Insights',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                result.insights,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
