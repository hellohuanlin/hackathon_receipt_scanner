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
  double? _billAmount;
  double _tipPercentage = 20.0;
  String _errorMessage = '';
  final _receiptScannerPlugin = ReceiptScanner();

  double get _tipAmount => (_billAmount ?? 0) * (_tipPercentage / 100);
  double get _totalAmount => (_billAmount ?? 0) + _tipAmount;

  // Scan receipt and get the amount
  Future<void> scanReceipt() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final amount = await _receiptScannerPlugin.scanReceipt();
      if (amount != null && amount > 0) {
        setState(() {
          _billAmount = amount;
          _errorMessage = '';
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to scan receipt';
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.message ?? 'Unknown error'}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Tip Calculator'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: scanReceipt,
                icon: const Icon(Icons.receipt_long),
                label: const Text('Scan Receipt'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 30),
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red.shade900),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_billAmount != null) ...[
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Bill Amount:',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              '\$${_billAmount!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Tip Percentage',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  '${_tipPercentage.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                Slider(
                  value: _tipPercentage,
                  min: 10,
                  max: 30,
                  divisions: 20,
                  label: '${_tipPercentage.toStringAsFixed(0)}%',
                  onChanged: (value) {
                    setState(() {
                      _tipPercentage = value;
                    });
                  },
                ),
                const SizedBox(height: 30),
                Card(
                  elevation: 4,
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tip Amount:',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              '\$${_tipAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${_totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (_billAmount == null && _errorMessage.isEmpty) ...[
                const Spacer(),
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Scan a receipt to calculate tip',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
