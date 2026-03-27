import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';
import '../services/gemini_service.dart';

class DrugInteractionScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const DrugInteractionScreen({super.key, required this.user});

  @override
  State<DrugInteractionScreen> createState() => _DrugInteractionScreenState();
}

class _DrugInteractionScreenState extends State<DrugInteractionScreen> {
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  bool _loading = false;
  String? _result;

  void _addField() {
    setState(() => _controllers.add(TextEditingController()));
  }

  void _removeField(int index) {
    if (_controllers.length <= 2) return;
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
  }

  Future<void> _check() async {
    final meds =
        _controllers.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
    if (meds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Enter at least 2 medicines to check interactions')));
      return;
    }
    setState(() {
      _loading = true;
      _result = null;
    });
    try {
      final res = await GeminiService.checkDrugInteractions(meds);
      setState(() => _result = res);
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
            SnackBar(content: Text('Check failed: $e')),
          );
        }
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
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
              color: AppTheme.redAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.shield_outlined,
                color: AppTheme.redAccent, size: 18),
          ),
          const SizedBox(width: 10),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Drug Interaction Checker',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text('Check harmful combinations',
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ]),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Input Card
          GlassCard(
            highlight: true,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.medication_outlined,
                    color: AppTheme.redAccent, size: 20),
                const SizedBox(width: 8),
                const Text('Your Medications',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 6),
              const Text('Enter all medicines you are currently taking.',
                  style:
                      TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              const SizedBox(height: 20),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _controllers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _controllers[i],
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText:
                            'Medicine ${i + 1} (e.g., Aspirin)',
                        prefixIcon: Icon(Icons.medication_rounded,
                            color: AppTheme.redAccent.withOpacity(0.6),
                            size: 18),
                      ),
                    ),
                  ),
                  if (_controllers.length > 2) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _removeField(i),
                      icon: const Icon(Icons.remove_circle_outline,
                          color: AppTheme.redAccent, size: 22),
                    ),
                  ],
                ]),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _addField,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Medicine'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(color: AppTheme.borderColorLight)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _check,
                    icon: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.black)))
                        : const Icon(Icons.shield_outlined, size: 16),
                    label: Text(_loading ? 'Checking…' : 'Check Safety'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.redAccent,
                        foregroundColor: Colors.white),
                  ),
                ),
              ]),
            ]),
          ),

          if (_loading) ...[
            const SizedBox(height: 32),
            const NeonLoader(message: 'Cross-referencing drug databases...'),
          ],

          if (_result != null) ...[
            const SizedBox(height: 24),
            _ResultCard(result: _result!),
          ],

          if (_result == null && !_loading) ...[
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.borderColor,
                    style: BorderStyle.solid),
              ),
              child: Column(children: [
                Icon(Icons.info_outline,
                    size: 48,
                    color: AppTheme.textMuted.withOpacity(0.3)),
                const SizedBox(height: 14),
                const Text(
                  'Enter your medications above\nto see a detailed safety report.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppTheme.textMuted, fontSize: 13, height: 1.5),
                ),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    // Parse sections separated by ## headings
    final lines = result.split('\n');

    return GlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.shield_outlined, color: AppTheme.redAccent, size: 24),
          const SizedBox(width: 10),
          const Text('Safety Report',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 16),
        ...lines.map((line) {
          if (line.startsWith('## ') || line.startsWith('# ')) {
            return Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 6),
              child: Text(
                line.replaceAll(RegExp(r'^#+\s*'), ''),
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neonGreen),
              ),
            );
          }
          if (line.startsWith('**') && line.endsWith('**')) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                line.replaceAll('**', ''),
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary),
              ),
            );
          }
          if (line.startsWith('- ') || line.startsWith('* ')) {
            return Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(
                            color: AppTheme.redAccent, fontSize: 14)),
                    Expanded(
                        child: Text(
                      line.substring(2),
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          height: 1.4),
                    )),
                  ]),
            );
          }
          if (line.trim().isEmpty) return const SizedBox(height: 6);
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(line,
                style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.5)),
          );
        }).toList(),
        const SizedBox(height: 16),
        const DisclaimerBanner(
            text:
                'CRITICAL: This is for informational purposes only. Never stop or change medication without consulting your doctor.'),
      ]),
    );
  }
}
