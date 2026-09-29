import 'package:flutter_test/flutter_test.dart';
import 'package:orbital_pulse/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('OrbitalPulse smoke test', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const OrbitalPulseApp());
    expect(find.text('OrbitalPulse'), findsOneWidget);
    // "Elon" appears in the bottom nav and as a Videos filter chip.
    expect(find.text('Elon'), findsWidgets);
    expect(find.text('Launches'), findsOneWidget);
    expect(find.text('Videos'), findsOneWidget);
  });
}
