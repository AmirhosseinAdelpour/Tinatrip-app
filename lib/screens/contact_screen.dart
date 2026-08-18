import 'package:flutter/material.dart';
import '../theme/app_build_context.dart';
import '../widgets/app_background.dart';
import '../platform_actions.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  static const _phones = ['02191690935', '05191690935', '05135147359'];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: AppBar(title: const Text('تماس با ما')),
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.surface, colors.background],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colors.primary.withAlpha(51),
                        ),
                      ),
                      child: Text(
                        'پشتیبانی تینا تریپ آماده دریافت انتقادات، پیشنهادات و نظرات شما می‌باشد.',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: colors.onBackground,
                          height: 1.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    for (final phone in _phones)
                      _ContactRow(
                        icon: Icons.phone_in_talk,
                        color: colors.primary,
                        label: 'شماره ثابت',
                        value: phone,
                        onTap: () => dialNumber(phone),
                      ),
                    _ContactRow(
                      icon: Icons.phone_iphone,
                      color: colors.primary,
                      label: 'شماره همراه',
                      value: '09909675218',
                      onTap: () => dialNumber('09909675218'),
                    ),
                    _ContactRow(
                      icon: Icons.camera_alt,
                      color: colors.error,
                      label: 'اینستاگرام',
                      value: 'tinasafar_com',
                      onTap: () =>
                          openExternalUrl('https://instagram.com/tinasafar_com'),
                    ),
                    _ContactRow(
                      icon: Icons.mail_outline,
                      color: colors.secondary,
                      label: 'ایمیل',
                      value: 'tinatrip24@gmail.com',
                      onTap: () => sendEmail(
                        to: 'tinatrip24@gmail.com',
                        subject: 'ارتباط با تیناتریپ',
                        body: '',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.line),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.muted.withAlpha(178),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: colors.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(Icons.chevron_left, color: colors.muted, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
