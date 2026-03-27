import 'package:flutter/material.dart';
import '../theme.dart';

// ─── Neon Glass Card ────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final bool highlight;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.highlight = false,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: neonCardDecoration(highlight: highlight),
        child: child,
      ),
    );
  }
}

// ─── Neon Button ────────────────────────────────────────────────────────────
class NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool loading;
  final bool outline;
  final bool fullWidth;

  const NeonButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.loading = false,
    this.outline = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Colors.black),
            ),
          )
        else if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        if (!loading)
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
      ],
    );

    if (outline) {
      return OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          minimumSize: fullWidth ? const Size(double.infinity, 48) : null,
        ),
        child: content,
      );
    }

    return ElevatedButton(
      onPressed: loading ? null : onTap,
      style: ElevatedButton.styleFrom(
        minimumSize: fullWidth ? const Size(double.infinity, 48) : null,
        backgroundColor: AppTheme.neonGreen,
        foregroundColor: Colors.black,
        disabledBackgroundColor: AppTheme.neonGreen.withOpacity(0.5),
        shadowColor: AppTheme.neonGlow,
        elevation: loading ? 0 : 4,
      ),
      child: content,
    );
  }
}

// ─── Severity Badge ──────────────────────────────────────────────────────────
class SeverityBadge extends StatelessWidget {
  final String severity;

  const SeverityBadge({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (severity.toLowerCase()) {
      case 'low':
        color = AppTheme.severityLow;
        break;
      case 'medium':
        color = AppTheme.severityMedium;
        break;
      case 'high':
        color = AppTheme.severityHigh;
        break;
      case 'critical':
        color = AppTheme.severityCritical;
        break;
      default:
        color = AppTheme.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        severity.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppTheme.neonGreen, size: 22),
              const SizedBox(width: 10),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Stat Card ───────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String trend;

  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Flexible(
                child: Text(
                  trend,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Neon Input Field ─────────────────────────────────────────────────────────
class NeonTextField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final Widget? suffix;
  final Widget? prefix;
  final String? label;

  const NeonTextField({
    super.key,
    required this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.suffix,
    this.prefix,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            prefixIcon: prefix,
          ),
        ),
      ],
    );
  }
}

// ─── Loading Spinner ──────────────────────────────────────────────────────────
class NeonLoader extends StatelessWidget {
  final String? message;

  const NeonLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppTheme.neonGreen),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Disclaimer Banner ────────────────────────────────────────────────────────
class DisclaimerBanner extends StatelessWidget {
  final String text;

  const DisclaimerBanner({
    super.key,
    this.text =
        'DISCLAIMER: This is AI-generated and NOT a professional medical diagnosis. In an emergency, call emergency services immediately.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.redAccent.withOpacity(0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.redAccent,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppTheme.redAccent.withOpacity(0.85),
                fontSize: 10,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.borderColor,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppTheme.textMuted.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── API Key Setup Banner ─────────────────────────────────────────────────────
class ApiKeySetupBanner extends StatelessWidget {
  const ApiKeySetupBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      highlight: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.yellowAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.key,
                  color: AppTheme.yellowAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'API Key Required',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'To use AI features, you need a free API key from Gemini or Groq:',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'OPTION 1: Gemini (Recommended)',
            style: TextStyle(
              color: AppTheme.neonGreen,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _SetupStep(
            number: '1',
            text: 'Visit: https://aistudio.google.com/app/apikey',
          ),
          const SizedBox(height: 6),
          _SetupStep(number: '2', text: 'Click "Create API Key"'),
          const SizedBox(height: 6),
          _SetupStep(number: '3', text: 'Add to .env as GEMINI_API_KEY'),
          const SizedBox(height: 16),
          const Text(
            'OPTION 2: Groq (Fallback)',
            style: TextStyle(
              color: AppTheme.blueAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _SetupStep(
            number: '1',
            text: 'Visit: https://console.groq.com/keys',
          ),
          const SizedBox(height: 6),
          _SetupStep(number: '2', text: 'Create API Key'),
          const SizedBox(height: 6),
          _SetupStep(number: '3', text: 'Add to .env as GROQ_API_KEY'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.neonGreenDim,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.neonGreenBorder),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline,
                    color: AppTheme.neonGreen, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Both APIs are free! Groq is used as fallback when Gemini hits rate limits.',
                    style: TextStyle(
                      color: AppTheme.neonGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SetupStep extends StatelessWidget {
  final String number;
  final String text;

  const _SetupStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.neonGreenDim,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppTheme.neonGreenBorder),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: AppTheme.neonGreen,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
