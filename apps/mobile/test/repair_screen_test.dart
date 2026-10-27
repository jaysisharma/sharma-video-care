import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharma_video_care_mobile/screens/service_request_screen.dart';
import 'package:sharma_video_care_mobile/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pump(WidgetTester tester, {double textScale = 1}) async {
    tester.view.physicalSize = const Size(1179, 2556); // iPhone 16 Pro
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: const Size(393, 852), textScaler: TextScaler.linear(textScale)),
        child: ServiceRequestScreen(appState: AppState()),
      ),
    ));
    await tester.pump();
  }

  for (final scale in [1.0, 1.3]) {
    testWidgets('services tab lays out without overflow at text scale $scale', (tester) async {
      await pump(tester, textScale: scale);
      expect(tester.takeException(), isNull);
      expect(find.text('Free inspection before every repair'), findsOneWidget);
      await tester.drag(find.byType(ListView).first, const Offset(0, -1500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tabs use plain names', (tester) async {
    await pump(tester);
    for (final t in ['Services', 'Book', 'My repairs']) {
      expect(find.text(t), findsOneWidget);
    }
  });

  testWidgets('choosing a department opens the form with that device type', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Lenses'));
    await tester.pumpAndSettle();
    expect(find.text('Your device'), findsOneWidget);
    expect(find.text('Lens'), findsOneWidget); // dropdown shows the matching category
  });

  testWidgets('pickup address starts empty, not the shop address', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Book'));
    await tester.pumpAndSettle();
    expect(find.text('Station Road, Near Railway Station'), findsNothing);
    expect(find.text('Ward 4'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
