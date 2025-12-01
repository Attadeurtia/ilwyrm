import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'batch_add_page.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  final Set<String> _scannedIsbns = {};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final isbn = barcode.rawValue!;
        if (!_scannedIsbns.contains(isbn)) {
          setState(() {
            _scannedIsbns.add(isbn);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Livre scanné: $isbn'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    }
  }

  void _finishScanning() {
    _controller.stop();
    if (_scannedIsbns.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BatchAddPage(isbns: _scannedIsbns.toList()),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner des livres'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.camera_rear),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.scrim.withValues(alpha: 0.54),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Scanner le code-barres d\'un livre',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _finishScanning,
        label: Text(
          _scannedIsbns.isEmpty
              ? 'Annuler'
              : 'Terminer (${_scannedIsbns.length})',
        ),
        icon: Icon(_scannedIsbns.isEmpty ? Icons.close : Icons.check),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
