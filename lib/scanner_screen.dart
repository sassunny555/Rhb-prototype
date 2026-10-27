import 'dart:async';

import 'receive_view.dart';
import 'ocr/ocr.dart';
import 'payment/recipient.dart';
import 'payment/payment_screen.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  final controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.normal,
    returnImage: true,
  );
  bool processing = false;
  bool receive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.hasCameraPermission) return;
    if (state == AppLifecycleState.resumed && !receive && !processing) {
      unawaited(startCamera());
    } else if (state != AppLifecycleState.resumed) {
      unawaited(controller.stop());
    }
  }

  Future<void> startCamera() async {
    try {
      await controller.start();
    } catch (_) {
      if (mounted) {
        notice(
          'Unable to start camera. Check camera permission and try again.',
        );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(controller.dispose());
    super.dispose();
  }

  void notice(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> detected(BarcodeCapture capture, {Uint8List? imageBytes}) async {
    if (processing || receive || !mounted) return;
    final values = capture.barcodes
        .map((b) => b.rawValue)
        .whereType<String>()
        .where((v) => v.isNotEmpty);
    if (values.isEmpty) return;
    setState(() => processing = true);
    var recipient = parsePaymentQr(values.first);
    String? ocrMessage;
    try {
      if (recipient.name == null) {
        // Capture before stopping the live video so browser OCR has a full frame.
        final bytes = imageBytes ?? capture.image ?? await captureCameraFrame();
        final text = await recognizeText(bytes: bytes)
            .timeout(const Duration(seconds: 30));
        final name = nameFromOcr(text);
        recipient = Recipient(
          name: name,
          account: recipient.account,
          amount: recipient.amount,
          source: name == null
              ? 'Manual entry required'
              : 'Camera OCR — please verify',
        );
        if (name == null) ocrMessage = 'No clear recipient name found. Enter it manually or scan again with the printed name visible above the QR.';
      }
    } catch (_) {
      ocrMessage = 'Text recognition was unavailable. Enter the name manually or try scanning again.';
    }
    if (!mounted) return;
    await controller.stop();
    if (!mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PaymentScreen(recipient: recipient, ocrMessage: ocrMessage),
      ),
    );
    if (!mounted) return;
    setState(() => processing = false);
    if (!receive) await startCamera();
  }

  Future<void> gallery() async {
    if (kIsWeb) {
      notice(
        'Scan with the live camera here. Importing a QR image is available in the Android and iOS app.',
      );
      return;
    }
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null || !mounted) return;
      final result = await controller.analyzeImage(image.path);
      if (!mounted) return;
      if (result == null || result.barcodes.isEmpty) {
        notice('No QR code found in this image.');
      } else {
        await detected(result, imageBytes: await image.readAsBytes());
      }
    } catch (_) {
      if (mounted) notice('Unable to read this image. Try another QR image.');
    }
  }

  Future<void> torch() async {
    if (controller.value.torchState == TorchState.unavailable) {
      notice('Flashlight is unavailable on this camera.');
      return;
    }
    try {
      await controller.toggleTorch();
    } catch (_) {
      if (mounted) notice('This camera does not support a flashlight.');
    }
  }

  Future<void> selectTab(bool value) async {
    if (receive == value) return;
    setState(() => receive = value);
    if (value) {
      await controller.stop();
    } else {
      await startCamera();
    }
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light,
    child: Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: LayoutBuilder(
            builder: (context, box) {
              final w = box.maxWidth;
              final h = box.maxHeight;
              final s = w / 393;
              if (receive) {
                return ReceiveView(
                  onClose: () => Navigator.pop(context),
                  footer: Row(
                    children: [tab('Pay', false, s), tab('Receive', true, s)],
                  ),
                );
              }
              final frame = Rect.fromLTWH(w * .08, h * .274, w * .84, h * .388);
              return Stack(
                children: [
                  Positioned.fill(
                    child: receive
                        ? const ColoredBox(color: Colors.black)
                        : MobileScanner(
                            controller: controller,
                            fit: BoxFit.cover,
                            onDetect: detected,
                            errorBuilder: (context, error) => ColoredBox(
                              color: Colors.black,
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 42 * s,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.no_photography_outlined,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Camera unavailable',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Allow camera access in your browser or device settings. Check that another app is not using the camera.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      const SizedBox(height: 16),
                                      OutlinedButton(
                                        onPressed: startCamera,
                                        child: const Text('Try again'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                  if (!receive)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(painter: ScannerFramePainter(frame)),
                      ),
                    ),
                  if (processing)
                    const Positioned.fill(
                      child: ColoredBox(
                        color: Color(0x99000000),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 16),
                              Text(
                                'Reading recipient…',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (!receive)
                    Positioned.fromRect(
                      rect: frame,
                      child: IgnorePointer(
                        child: SvgPicture.asset(
                          'assets/icons/scan_qr/scan-frame.svg',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),

                  Positioned(
                    top: MediaQuery.paddingOf(context).top + 44 * s,
                    left: 16 * s,
                    right: 16 * s,
                    child: SizedBox(
                      height: 50 * s,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            receive ? 'Receive QR' : 'Scan QR',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18 * s,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              tooltip: 'Close scanner',
                              onPressed: () => Navigator.pop(context),
                              icon: scannerIcon('close', 20 * s),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!receive)
                    Positioned(
                      top: h * .735,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            tooltip: 'Choose QR image',
                            onPressed: gallery,
                            icon: scannerIcon('gallery', 21 * s),
                          ),
                          SizedBox(width: 24 * s),
                          ValueListenableBuilder(
                            valueListenable: controller,
                            builder: (_, state, _) => IconButton(
                              tooltip: 'Toggle flashlight',
                              onPressed: torch,
                              icon: scannerIcon('flashlight', 21 * s),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (receive)
                    Positioned(
                      top: h * .32,
                      left: 24,
                      right: 24,
                      child: Column(
                        children: [
                          Icon(
                            Icons.qr_code_2,
                            color: Colors.white,
                            size: 120 * s,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Receive payments',
                            style: TextStyle(color: Colors.white, fontSize: 22),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'A personal payment QR will appear here once a payment service is connected.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: h * .167,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(18 * s),
                        ),
                      ),
                      padding: EdgeInsets.only(
                        top: 24 * s,
                        bottom: MediaQuery.paddingOf(context).bottom + 12 * s,
                      ),
                      child: Row(
                        children: [
                          tab('Pay', false, s),
                          tab('Receive', true, s),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
  Widget scannerIcon(String name, double size) => SvgPicture.asset(
    'assets/icons/scan_qr/$name.svg',
    width: size,
    height: size,
  );

  Widget tab(String label, bool value, double s) {
    final active = receive == value;
    return Expanded(
      child: InkWell(
        onTap: () => selectTab(value),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            scannerIcon(value ? 'receive' : 'pay', 30 * s),
            SizedBox(height: 17 * s),
            Text(
              label,
              style: TextStyle(
                fontSize: 14 * s,
                color: active
                    ? const Color(0xff006eaa)
                    : const Color(0xff162d3a),
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            SizedBox(height: 7 * s),
            Container(
              height: 2 * s,
              width: 53 * s,
              color: active ? const Color(0xff006eaa) : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

class ScannerFramePainter extends CustomPainter {
  const ScannerFramePainter(this.frame);
  final Rect frame;
  @override
  void paint(Canvas canvas, Size size) {
    final shade = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(
        RRect.fromRectAndRadius(frame, Radius.circular(frame.width * .1)),
      )
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(shade, Paint()..color = Colors.black.withValues(alpha: .3));
  }

  @override
  bool shouldRepaint(ScannerFramePainter oldDelegate) =>
      oldDelegate.frame != frame;
}
