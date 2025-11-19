
import 'receipt_scanner_platform_interface.dart';

class ReceiptScanner {
  Future<String?> getPlatformVersion() {
    return ReceiptScannerPlatform.instance.getPlatformVersion();
  }
}
