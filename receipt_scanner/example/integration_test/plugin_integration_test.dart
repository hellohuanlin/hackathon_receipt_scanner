// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:receipt_scanner/receipt_scanner.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scanReceipt test', (WidgetTester tester) async {
    final ReceiptScanner plugin = ReceiptScanner();
    final double? amount = await plugin.scanReceipt();
    // The amount should be a valid number (non-null and non-negative)
    expect(amount, isNotNull);
    expect(amount! >= 0, true);
  });
}
