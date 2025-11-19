import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'receipt_scanner_method_channel.dart';

abstract class ReceiptScannerPlatform extends PlatformInterface {
  /// Constructs a ReceiptScannerPlatform.
  ReceiptScannerPlatform() : super(token: _token);

  static final Object _token = Object();

  static ReceiptScannerPlatform _instance = MethodChannelReceiptScanner();

  /// The default instance of [ReceiptScannerPlatform] to use.
  ///
  /// Defaults to [MethodChannelReceiptScanner].
  static ReceiptScannerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ReceiptScannerPlatform] when
  /// they register themselves.
  static set instance(ReceiptScannerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
