import 'package:flutter_test/flutter_test.dart';
import 'package:orbital_pulse/main.dart';

void main() {
  testWidgets('OrbitalPulse smoke test', (tester) async {
    await tester.pumpWidget(const OrbitalPulseApp());
    expect(find.text('OrbitalPulse'), findsOneWidget);
    expect(find.text('Elon'), findsOneWidget);
    expect(find.text('Launches'), findsOneWidget);
  });
}
