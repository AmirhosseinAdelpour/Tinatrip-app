import 'package:flutter_test/flutter_test.dart';

import 'package:tinatrip_app/main.dart';

void main() {
  testWidgets('Home shows animated tagline, actions and services', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TunaTripApp());

    await tester.pump(const Duration(milliseconds: 4500));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    expect(find.text('مرجع بهترین تورها، هتل‌ها و پروازهای داخلی و خارجی'), findsWidgets);
    expect(find.text('گشت'), findsOneWidget);
    expect(find.text('اطلاعات پرواز'), findsOneWidget);
    expect(find.text('پرواز'), findsOneWidget);
    expect(find.text('هتل'), findsOneWidget);
    expect(find.text('تور'), findsOneWidget);
  });
}
