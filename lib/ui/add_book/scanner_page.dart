import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'search_book_page.dart';

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner un livre'),
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
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              debugPrint('Barcode found! ${barcode.rawValue}');
              // For now, just show a snackbar and pop
              // In real implementation, we would fetch the book
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Code détecté: ${barcode.rawValue}')),
              );
              // _controller.stop(); // Optional: stop scanning after one
              // Navigator.pop(context, barcode.rawValue);
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SearchBookPage()),
          );
        },
        label: const Text('Recherche manuelle'),
        icon: const Icon(Icons.search),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
