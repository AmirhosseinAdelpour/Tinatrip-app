import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_build_context.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';

class RulesSection {
  final String title;
  final List<String> paragraphs;

  const RulesSection({required this.title, required this.paragraphs});
}

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  final ScrollController _scroll = ScrollController();
  List<RulesSection>? _sections;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _sections = null;
      _failed = false;
    });
    try {
      final raw = await rootBundle.loadString('assets/rules.json');
      final data = jsonDecode(raw) as List;
      final sections = <RulesSection>[];
      for (final entry in data) {
        final map = entry as Map;
        final title = map['title'] as String;
        final paragraphs = (map['paragraphs'] as List)
            .map((p) => p.toString())
            .toList();
        sections.add(RulesSection(title: title, paragraphs: paragraphs));
      }
      if (!mounted) return;
      setState(() => _sections = sections);
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      appBar: AppBar(title: const Text('قوانین')),
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
              child: _failed
                  ? _RulesErrorView(onRetry: _load)
                  : _sections == null
                      ? const _RulesLoadingView()
                      : _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final sections = _sections!;
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
          child: Column(
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 48,
                color: colors.secondary,
              ),
              const SizedBox(height: 10),
              Text(
                'قوانین و مقررات',
                textAlign: TextAlign.center,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'تیناتریپ | tinatrip.com',
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.muted,
                ),
              ),
            ],
          ),
        ),
        _RulesToc(
          titles: [for (final s in sections) s.title],
          onTap: (_) {},
        ),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            itemCount: sections.length,
            itemBuilder: (context, index) {
              return _RulesSectionCard(
                index: index,
                section: sections[index],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RulesToc extends StatelessWidget {
  const _RulesToc({required this.titles, required this.onTap});

  final List<String> titles;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: titles.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => onTap(index),
            borderRadius: BorderRadius.circular(100),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: colors.line),
              ),
              child: Text(
                titles[index],
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.onBackground,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RulesSectionCard extends StatelessWidget {
  const _RulesSectionCard({
    required this.index,
    required this.section,
  });

  final int index;
  final RulesSection section;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accentList = [
      colors.primary,
      colors.secondary,
      colors.accent,
      colors.error,
    ];
    final accent = accentList[index % accentList.length];
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [accent.withAlpha(38), colors.surface],
              ),
              border: Border(bottom: BorderSide(color: colors.line)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accent.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accent.withAlpha(76)),
                  ),
                  child: Icon(
                    Icons.menu_book_outlined,
                    color: accent,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    section.title,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onBackground,
                      height: 1.4,
                    ),
                  ),
                ),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < section.paragraphs.length; i++) ...[
                  Text(
                    section.paragraphs[i],
                    textAlign: TextAlign.justify,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.onBackground,
                      height: 1.85,
                    ),
                  ),
                  if (i < section.paragraphs.length - 1)
                    const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RulesLoadingView extends StatelessWidget {
  const _RulesLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          SizedBox(height: 18),
          Text('در حال بارگذاری قوانین…'),
        ],
      ),
    );
  }
}

class _RulesErrorView extends StatelessWidget {
  const _RulesErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 52, color: colors.error),
            const SizedBox(height: 20),
            Text(
              'بارگذاری قوانین ممکن نشد',
              textAlign: TextAlign.center,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لطفاً دوباره تلاش کنید.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.muted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            GradientButton(
              label: 'تلاش دوباره',
              icon: Icons.refresh,
              onTap: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
