import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

const demoQrPayload =
    '{"type":"fyp-payment","name":"Demo Recipient","account":"1-62027-0028825-8"}';
const duitNowPink = Color(0xffe60060);

class ReceiveView extends StatelessWidget {
  const ReceiveView({super.key, required this.onClose, required this.footer});
  final VoidCallback onClose;
  final Widget footer;

  Future<void> shareQr(BuildContext context) async {
    try {
      final bytes = await QrPainter(
        data: demoQrPayload,
        version: 8,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: duitNowPink,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: duitNowPink,
        ),
      ).toImageData(900);
      if (bytes == null || !context.mounted) return;
      final box = context.findRenderObject() as RenderBox;
      await SharePlus.instance.share(
        ShareParams(
          title: 'Demo Receive QR',
          text: 'FYP banking prototype — demo QR, not a payment request.',
          files: [
            XFile.fromData(
              bytes.buffer.asUint8List(),
              mimeType: 'image/png',
              name: 'demo-receive-qr.png',
            ),
          ],
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sharing is unavailable in this browser. Try the mobile app.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final s = box.maxWidth / 393;
      final h = box.maxHeight;
      return ColoredBox(
        color: const Color(0xffeff9fd),
        child: Stack(
          children: [
            Positioned.fill(
              bottom: h * .167,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 105 * s,
                      child: Stack(
                        children: [
                          const Positioned.fill(
                            child: CustomPaint(painter: ReceiveHeaderPainter()),
                          ),

                          Positioned(
                            left: 16 * s,
                            right: 16 * s,
                            top: 49 * s,
                            child: SizedBox(
                              height: 43 * s,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Text(
                                    'DuitNow QR',
                                    style: TextStyle(
                                      fontSize: 18 * s,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xff071b27),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: IconButton(
                                      tooltip: 'Close receive screen',
                                      onPressed: onClose,
                                      icon: SvgPicture.asset(
                                        'assets/icons/scan_qr/close.svg',
                                        width: 20 * s,
                                        height: 20 * s,
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xff071b27),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 105 * s,
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 17 * s,
                        vertical: 17 * s,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Receive via',
                                style: TextStyle(
                                  fontSize: 14 * s,
                                  color: const Color(0xff59656e),
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.chevron_right,
                                size: 20 * s,
                                color: const Color(0xff162d3a),
                              ),
                            ],
                          ),
                          SizedBox(height: 9 * s),
                          Text(
                            'Savings Pro Account-i',
                            style: TextStyle(
                              fontSize: 16 * s,
                              height: 1.2,
                              color: const Color(0xff162d3a),
                            ),
                          ),
                          SizedBox(height: 4 * s),
                          Text(
                            '1-62027-0028825-8',
                            style: TextStyle(
                              fontSize: 16 * s,
                              height: 1.2,
                              color: const Color(0xff162d3a),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 43 * s),
                    Semantics(
                      label: 'Demo receive QR code',
                      child: Container(
                        width: 302 * s,
                        height: 310 * s,
                        decoration: BoxDecoration(
                          color: duitNowPink,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18 * s),
                            topRight: Radius.circular(18 * s),
                            bottomRight: Radius.circular(18 * s),
                          ),
                        ),
                        padding: EdgeInsets.fromLTRB(18 * s, 18 * s, 18 * s, 0),
                        child: Column(
                          children: [
                            Container(
                              height: 232 * s,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8 * s),
                                  topRight: Radius.circular(8 * s),
                                  bottomRight: Radius.circular(8 * s),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: QrImageView(
                                data: demoQrPayload,
                                version: 8,
                                size: 176 * s,
                                padding: EdgeInsets.all(5 * s),
                                backgroundColor: Colors.white,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: duitNowPink,
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: duitNowPink,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Malaysia National QR',
                                  style: TextStyle(
                                    fontSize: 22 * s,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: .2 * s,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 39 * s),
                    TextButton(
                      onPressed: () => shareQr(context),
                      child: Text(
                        'Share QR',
                        style: TextStyle(
                          fontSize: 16 * s,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff006eaa),
                        ),
                      ),
                    ),
                    SizedBox(height: 10 * s),
                    Text(
                      'Show this QR to friends and family to\nreceive payment',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16 * s,
                        height: 1.4,
                        color: const Color(0xff59656e),
                      ),
                    ),
                    SizedBox(height: 18 * s),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: h * .167,
              child: Container(
                padding: EdgeInsets.only(
                  top: 24 * s,
                  bottom: MediaQuery.paddingOf(context).bottom + 12 * s,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(18 * s),
                  ),
                ),
                child: footer,
              ),
            ),
          ],
        ),
      );
    },
  );
}

class ReceiveHeaderPainter extends CustomPainter {
  const ReceiveHeaderPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff54bedc), Color(0xfff2fbfe)],
        ).createShader(Offset.zero & size),
    );
    final path = Path()
      ..moveTo(0, size.height * .56)
      ..quadraticBezierTo(
        size.width * .25,
        size.height * .42,
        size.width * .48,
        size.height * .63,
      )
      ..quadraticBezierTo(
        size.width * .8,
        size.height * .2,
        size.width,
        size.height * .27,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: .1));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
