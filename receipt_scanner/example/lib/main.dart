import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:receipt_scanner/receipt_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _scanResult = 'No receipt scanned yet';
  final _receiptScannerPlugin = ReceiptScanner();

  // Scan receipt and get the amount
  Future<void> scanReceipt() async {
    String result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      final amount = await _receiptScannerPlugin.scanReceipt();
      if (amount != null) {
        result = 'Scanned amount: \$${amount.toStringAsFixed(2)}';
      } else {
        result = 'Failed to scan receipt';
      }
    } on PlatformException catch (e) {
      result = 'Error: ${e.message}';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Receipt Scanner Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_scanResult, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: scanReceipt,
                child: const Text('Scan Receipt'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
