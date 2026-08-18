import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TunaTripApp());
}

class TunaTripApp extends StatelessWidget {
  const TunaTripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تیناتریپ',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      theme: AppTheme.light,
      home: AppEntry(),
    );
  }
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    if (_splashDone) {
      return const HomeScreen();
    }
    return SplashHost(
      onComplete: () {
        if (mounted) setState(() => _splashDone = true);
      },
    );
  }
}
