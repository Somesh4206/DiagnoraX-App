import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';
import '../services/gemini_service.dart';

class SymptomCheckerScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const SymptomCheckerScreen({super.key, required this.user});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _Message {
  final String id;
  final String role; // 'user' | 'ai'
  final String content;
  final SymptomAnalysis? analysis;

  _Message({
    required this.id,
    required this.role,
    required this.content,
    this.analysis,
  });
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  final List<_Message> _messages = [];
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_Message(
      id: '0',
      role: 'ai',
      content:
          "Hello! I'm your DiagnoraX AI assistant. Tell me about your symptoms, and I'll help you understand what might be going on.",
    ));
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend() async {
    final input = _inputCtrl.text.trim();
    if (input.isEmpty || _loading) return;

    setState(() {
      _messages.add(_Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'user',
        content: input,
      ));
      _loading = true;
    });
    _inputCtrl.clear();
    _scrollToBottom();

    try {
      final analysis = await GeminiService.analyzeSymptoms(input);
      setState(() {
        _messages.add(_Message(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          role: 'ai',
          content: 'Based on your symptoms, here is a preliminary analysis:',
          analysis: analysis,
        ));
      });
    } catch (e) {
      final errorMsg = e.toString();
      final isApiKeyError = errorMsg.contains('API key') || errorMsg.contains('400');
      
      setState(() {
        _messages.add(_Message(
          id: DateTime.now().toString(),
          role: 'ai',
          content: isApiKeyError
              ? '⚠️ API Key Not Configured\n\n'
                'To use AI features, you need a Gemini API key:\n\n'
                '1. Visit: https://aistudio.google.com/app/apikey\n'
                '2. Sign in with Google\n'
                '3. Click "Create API Key"\n'
                '4. Copy the key\n'
                '5. Add it to your .env file\n'
                '6. Restart the app\n\n'
                'The API is free to use!'
              : 'Error: ${e.toString()}',
        ));
      });
    } finally {
      setState(() => _loading = false);
      _scrollToBottom();
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
                color: AppTheme.neonGreenDim,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.medical_services, color: AppTheme.neonGreen, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Symptom Checker', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('AI-powered analysis', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat Area
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i == _messages.length) {
                  return _TypingIndicator();
                }
                return _buildMessage(_messages[i]);
              },
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(top: BorderSide(color: AppTheme.borderColor)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputCtrl,
                          onSubmitted: (_) => _handleSend(),
                          maxLines: null,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g., I have a headache and mild fever...',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: AppTheme.borderColor),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _handleSend,
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppTheme.neonGreen,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: neonGlowShadow(opacity: 0.2),
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline,
                          size: 11, color: AppTheme.textMuted),
                      SizedBox(width: 4),
                      Text(
                        'DiagnoraX AI can make mistakes. Check important info.',
                        style: TextStyle(
                            color: AppTheme.textMuted, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(_Message msg) {
    final isUser = msg.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.neonGreenDim,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy_outlined,
                  color: AppTheme.neonGreen, size: 18),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppTheme.neonGreen
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16).copyWith(
                      topLeft: isUser
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      topRight: isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    msg.content,
                    style: TextStyle(
                      color: isUser ? Colors.black : AppTheme.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: isUser ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
                if (msg.analysis != null) ...[
                  const SizedBox(height: 10),
                  _AnalysisCard(analysis: msg.analysis!),
                ],
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_outline,
                  color: AppTheme.textSecondary, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  final SymptomAnalysis analysis;

  const _AnalysisCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      highlight: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  analysis.prediction,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neonGreen,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SeverityBadge(severity: analysis.severity),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline,
                  color: AppTheme.neonGreen, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  analysis.recommendations,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),
          const Text(
            'NEXT STEPS',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          ...analysis.nextSteps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ',
                      style: TextStyle(
                          color: AppTheme.neonGreen, fontSize: 14)),
                  Expanded(
                    child: Text(
                      step,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const DisclaimerBanner(),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.neonGreenDim,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.smart_toy_outlined,
                color: AppTheme.neonGreen, size: 18),
          ),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16).copyWith(
                topLeft: const Radius.circular(4),
              ),
            ),
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) {
                return Opacity(
                  opacity: _anim.value,
                  child: const Text(
                    'Analyzing symptoms...',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
