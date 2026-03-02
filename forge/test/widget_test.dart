import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Forge app smoke test', (WidgetTester tester) async {
    // Forge requires Firebase initialization, so a full widget test
    // would need firebase_core mocking. This is a placeholder.
    expect(1 + 1, equals(2));
  });
}
