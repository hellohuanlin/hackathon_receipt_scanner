
import 'receipt_scanner_platform_interface.dart';

class ReceiptScanner {
  Future<double?> scanReceipt() {
    return ReceiptScannerPlatform.instance.scanReceipt();
  }
}
