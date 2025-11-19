import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_scanner/receipt_scanner.dart';
import 'package:receipt_scanner/receipt_scanner_platform_interface.dart';
import 'package:receipt_scanner/receipt_scanner_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockReceiptScannerPlatform
    with MockPlatformInterfaceMixin
    implements ReceiptScannerPlatform {
  @override
  Future<double?> scanReceipt() => Future.value(42.99);
}

void main() {
  final ReceiptScannerPlatform initialPlatform = ReceiptScannerPlatform.instance;

  test('$MethodChannelReceiptScanner is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelReceiptScanner>());
  });

  test('scanReceipt', () async {
    ReceiptScanner receiptScannerPlugin = ReceiptScanner();
    MockReceiptScannerPlatform fakePlatform = MockReceiptScannerPlatform();
    ReceiptScannerPlatform.instance = fakePlatform;

    expect(await receiptScannerPlugin.scanReceipt(), 42.99);
  });
}
