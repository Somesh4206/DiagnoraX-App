import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';
import '../services/gemini_service.dart';

class PrescriptionScannerScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const PrescriptionScannerScreen({super.key, required this.user});

  @override
  State<PrescriptionScannerScreen> createState() =>
      _PrescriptionScannerScreenState();
}

class _PrescriptionScannerScreenState
    extends State<PrescriptionScannerScreen> {
  File? _image;
  bool _loading = false;
  PrescriptionData? _result;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final xFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );
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
      final base64Image = base64Encode(bytes);
      final ext = _image!.path.split('.').last.toLowerCase();
      final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
      final result = await GeminiService.scanPrescription(base64Image, mime);
      setState(() => _result = result);
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
            SnackBar(content: Text('Scan failed: $e')),
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
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.neonGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.document_scanner_outlined,
                color: AppTheme.neonGreen, size: 18),
          ),
          const SizedBox(width: 10),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Prescription Scanner',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Extract medicines from image',
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ]),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Picker Area
            GestureDetector(
              onTap: () => _showPickerOptions(),
              child: Container(
                width: double.infinity,
                height: _image != null ? null : 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _image != null
                        ? AppTheme.neonGreenBorder
                        : AppTheme.borderColorLight,
                    style: _image != null
                        ? BorderStyle.solid
                        : BorderStyle.solid,
                  ),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            Image.file(_image!,
                                width: double.infinity, fit: BoxFit.cover),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: _showPickerOptions,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.edit,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 52,
                              color: AppTheme.neonGreen.withOpacity(0.4)),
                          const SizedBox(height: 14),
                          const Text('Tap to upload prescription image',
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 14)),
                          const SizedBox(height: 6),
                          const Text('Camera or Gallery',
                              style: TextStyle(
                                  color: AppTheme.textMuted, fontSize: 12)),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // Source buttons
            Row(children: [
              Expanded(
                child: _SourceButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SourceButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ),
            ]),

            const SizedBox(height: 16),

            if (_image != null)
              NeonButton(
                label: 'Scan Prescription',
                icon: Icons.document_scanner_outlined,
                loading: _loading,
                fullWidth: true,
                onTap: _analyze,
              ),

            if (_loading) ...[
              const SizedBox(height: 32),
              const NeonLoader(message: 'Extracting medicine details...'),
            ],

            if (_result != null) ...[
              const SizedBox(height: 28),
              _ResultSection(data: _result!, user: widget.user),
            ],
          ],
        ),
      ),
    );
  }

  void _showPickerOptions() {
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
                child: _SourceButton(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    })),
            const SizedBox(width: 14),
            Expanded(
                child: _SourceButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
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

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SourceButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(children: [
          Icon(icon, color: AppTheme.neonGreen, size: 26),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  final PrescriptionData data;
  final Map<String, dynamic> user;
  const _ResultSection({required this.data, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.check_circle, color: AppTheme.neonGreen, size: 22),
        const SizedBox(width: 8),
        const Text('Extracted Successfully',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 16),

      // Doctor / Hospital info
      if (data.doctorName != null || data.hospitalName != null)
        GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('PRESCRIPTION INFO',
                style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
            const SizedBox(height: 12),
            if (data.doctorName != null)
              _InfoRow(
                  icon: Icons.person_outline,
                  label: 'Doctor',
                  value: data.doctorName!),
            if (data.hospitalName != null) ...[
              const SizedBox(height: 8),
              _InfoRow(
                  icon: Icons.local_hospital_outlined,
                  label: 'Hospital',
                  value: data.hospitalName!),
            ],
            if (data.date != null) ...[
              const SizedBox(height: 8),
              _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Date',
                  value: data.date!),
            ],
          ]),
        ),

      const SizedBox(height: 14),

      // Medicines
      const Text('MEDICINES',
          style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2)),
      const SizedBox(height: 10),
      ...data.medicines.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              highlight: true,
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.neonGreenDim,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.medication_rounded,
                      color: AppTheme.neonGreen, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Wrap(spacing: 8, children: [
                          _Chip(label: m.dosage, color: AppTheme.blueAccent),
                          _Chip(label: m.timing, color: AppTheme.yellowAccent),
                          _Chip(
                              label: m.frequency,
                              color: AppTheme.purpleAccent),
                        ]),
                      ]),
                ),
              ]),
            ),
          )),

      const SizedBox(height: 16),
      const DisclaimerBanner(
          text:
              'DISCLAIMER: Always verify extracted details with your original prescription before taking medicines.'),
    ]);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 14, color: AppTheme.textMuted),
      const SizedBox(width: 8),
      Text('$label: ',
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
      Expanded(
          child: Text(value,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500))),
    ]);
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}
