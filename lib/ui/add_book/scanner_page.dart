import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../data/library_index.dart';
import '../../l10n/l10n.dart';
import 'batch_add_page.dart';
import 'scan_cover_page.dart';

class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({super.key});

  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
    // Un ISBN est toujours imprimé en EAN-13 : se limiter à ce format accélère
    // la détection et ignore QR codes et autres codes-barres.
    formats: const [BarcodeFormat.ean13],
  );
  final Set<String> _scannedIsbns = {};
  final Set<String> _duplicateIsbns = {};
  final Set<String> _ignoredCodes = {};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final isbn = barcode.rawValue;
      if (isbn == null ||
          _scannedIsbns.contains(isbn) ||
          _ignoredCodes.contains(isbn)) {
        continue;
      }

      // Un EAN-13 de livre commence par 978/979 ; les autres (produits,
      // magazines…) ne sont pas des ISBN et ne donneraient aucun résultat.
      if (!isbn.startsWith('978') && !isbn.startsWith('979')) {
        _ignoredCodes.add(isbn);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.notAnIsbn(isbn)),
            duration: const Duration(seconds: 2),
          ),
        );
        continue;
      }

      // Signale immédiatement si un livre avec cet ISBN est déjà en bibliothèque.
      final inLibrary =
          ref.read(libraryIndexProvider).value?.containsIsbn(isbn) ?? false;
      setState(() {
        _scannedIsbns.add(isbn);
        if (inLibrary) _duplicateIsbns.add(isbn);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            inLibrary
                ? context.l10n.isbnAlreadyInLibrary(isbn)
                : context.l10n.bookScanned(isbn),
          ),
          backgroundColor:
              inLibrary ? Theme.of(context).colorScheme.tertiary : null,
          duration: const Duration(seconds: 1),
        ),
      );
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
    // Garde l'index de la bibliothèque abonné (donc à jour) pour le contrôle
    // d'ISBN déjà présent au moment du scan.
    ref.watch(libraryIndexProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.scannerTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.document_scanner),
            tooltip: context.l10n.scanCoverTooltip,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScanCoverPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: context.l10n.torchTooltip,
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.camera_rear),
            tooltip: context.l10n.switchCameraTooltip,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.scannerHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16,
                      ),
                    ),
                    if (_duplicateIsbns.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.duplicatesInLibrary(_duplicateIsbns.length),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
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
              ? context.l10n.actionCancel
              : context.l10n.finishScanning(_scannedIsbns.length),
        ),
        icon: Icon(_scannedIsbns.isEmpty ? Icons.close : Icons.check),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
