import 'package:flutter/material.dart';
import '../theme/app_build_context.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({
    super.key,
    required this.onBlog,
    required this.onRules,
  });

  final VoidCallback onBlog;
  final VoidCallback onRules;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Drawer(
      backgroundColor: colors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 28),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/logo.jpg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'تیناتریپ',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'منوی اصلی',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.muted.withAlpha(178),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              color: colors.line,
            ),
            const SizedBox(height: 12),
            _DrawerTile(
              icon: Icons.article_outlined,
              color: colors.primary,
              label: 'وبلاگ',
              onTap: onBlog,
            ),
            _DrawerTile(
              icon: Icons.description_outlined,
              color: colors.secondary,
              label: 'قوانین',
              onTap: onRules,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Text(
                'تینا تریپ، پلی به سوی دنیا',
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.muted.withAlpha(153),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withAlpha(76)),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(
          label,
          style: context.textTheme.bodyLarge?.copyWith(
            color: colors.onBackground,
          ),
        ),
        trailing: Icon(Icons.chevron_left, color: colors.muted, size: 20),
        onTap: onTap,
      ),
    );
  }
}
