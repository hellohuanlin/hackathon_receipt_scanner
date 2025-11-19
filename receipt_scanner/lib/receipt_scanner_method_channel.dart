import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'receipt_scanner_platform_interface.dart';

/// An implementation of [ReceiptScannerPlatform] that uses method channels.
class MethodChannelReceiptScanner extends ReceiptScannerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('receipt_scanner');

  @override
  Future<double?> scanReceipt() async {
    final amount = await methodChannel.invokeMethod<double>(
      'scanReceipt',
    );
    return amount;
  }
}
