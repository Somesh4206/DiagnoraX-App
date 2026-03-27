import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';
import '../services/gemini_service.dart';

class ReportAnalyzerScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const ReportAnalyzerScreen({super.key, required this.user});

  @override
  State<ReportAnalyzerScreen> createState() => _ReportAnalyzerScreenState();
}

class _ReportAnalyzerScreenState extends State<ReportAnalyzerScreen> {
  File? _image;
  bool _loading = false;
  ReportAnalysis? _result;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final xFile = await _picker.pickImage(
        source: source, imageQuality: 85, maxWidth: 1200);
    if (xFile == null) return;
    setState(() {
      _image = File(xFile.path);
      _result = null;
    });
  }

  Future<void> _analyze() async {
    if (_image == null) return;
    setState(() => _loading = true);
    try {
      final bytes = await _image!.readAsBytes();
      final b64 = base64Encode(bytes);
      final ext = _image!.path.split('.').last.toLowerCase();
      final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
      final res = await GeminiService.analyzeMedicalReport(b64, mime);
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
            SnackBar(content: Text('Analysis failed: $e')),
          );
        }
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Color _riskColor(double score) {
    if (score < 30) return AppTheme.severityLow;
    if (score < 60) return AppTheme.severityMedium;
    if (score < 80) return AppTheme.severityHigh;
    return AppTheme.severityCritical;
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
              color: AppTheme.purpleAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.analytics_outlined,
                color: AppTheme.purpleAccent, size: 18),
          ),
          const SizedBox(width: 10),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Report Analyzer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('AI lab report insights',
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ]),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Upload Area
          GestureDetector(
            onTap: () => _showPickerSheet(),
            child: Container(
              width: double.infinity,
              height: _image != null ? null : 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _image != null
                        ? AppTheme.purpleAccent.withOpacity(0.4)
                        : AppTheme.borderColorLight),
              ),
              child: _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(children: [
                        Image.file(_image!,
                            width: double.infinity, fit: BoxFit.cover),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: _showPickerSheet,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.edit,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ]),
                    )
                  : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.upload_file_outlined,
                          size: 52,
                          color: AppTheme.purpleAccent.withOpacity(0.45)),
                      const SizedBox(height: 14),
                      const Text('Upload your lab report',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 14)),
                      const SizedBox(height: 6),
                      const Text('Blood test, X-Ray, MRI, etc.',
                          style: TextStyle(
                              color: AppTheme.textMuted, fontSize: 12)),
                    ]),
            ),
          ),

          const SizedBox(height: 16),

          Row(children: [
            Expanded(
                child: _SrcBtn(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    color: AppTheme.purpleAccent,
                    onTap: () => _pickImage(ImageSource.camera))),
            const SizedBox(width: 12),
            Expanded(
                child: _SrcBtn(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    color: AppTheme.purpleAccent,
                    onTap: () => _pickImage(ImageSource.gallery))),
          ]),

          if (_image != null) ...[
            const SizedBox(height: 16),
            NeonButton(
              label: 'Analyze Report',
              icon: Icons.analytics_outlined,
              loading: _loading,
              fullWidth: true,
              onTap: _analyze,
            ),
          ],

          if (_loading) ...[
            const SizedBox(height: 32),
            const NeonLoader(message: 'Analyzing medical report...'),
          ],

          if (_result != null) ...[
            const SizedBox(height: 28),

            // Report Type
            Row(children: [
              const Icon(Icons.description_outlined,
                  color: AppTheme.purpleAccent, size: 22),
              const SizedBox(width: 8),
              Text(_result!.reportType,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 18),

            // Risk Score Card
            GlassCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Risk Score',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            '${_result!.riskScore.toInt()}/100',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _riskColor(_result!.riskScore)),
                          ),
                        ]),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _result!.riskScore / 100,
                        backgroundColor: Colors.white.withOpacity(0.06),
                        valueColor: AlwaysStoppedAnimation(
                            _riskColor(_result!.riskScore)),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _riskLabel(_result!.riskScore),
                      style: TextStyle(
                          color: _riskColor(_result!.riskScore),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8),
                    ),
                  ]),
            ),

            const SizedBox(height: 14),

            // Findings
            GlassCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.search, color: AppTheme.blueAccent, size: 20),
                      SizedBox(width: 8),
                      Text('Key Findings',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 12),
                    Text(_result!.findings,
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            height: 1.6)),
                  ]),
            ),

            const SizedBox(height: 14),

            // Insights
            GlassCard(
              highlight: true,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.lightbulb_outline,
                          color: AppTheme.yellowAccent, size: 20),
                      SizedBox(width: 8),
                      Text('Health Insights',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 12),
                    Text(_result!.insights,
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            height: 1.6)),
                  ]),
            ),

            const SizedBox(height: 16),
            const DisclaimerBanner(),
          ],
        ]),
      ),
    );
  }

  String _riskLabel(double score) {
    if (score < 30) return 'LOW RISK — Results look healthy';
    if (score < 60) return 'MODERATE RISK — Some values need attention';
    if (score < 80) return 'HIGH RISK — Consult a doctor soon';
    return 'CRITICAL — Seek immediate medical attention';
  }

  void _showPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Choose Source',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
                child: _SrcBtn(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    color: AppTheme.purpleAccent,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    })),
            const SizedBox(width: 14),
            Expanded(
                child: _SrcBtn(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    color: AppTheme.purpleAccent,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    })),
          ]),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }
}

class _SrcBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SrcBtn(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}
