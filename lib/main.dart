import 'package:flutter/material.dart';

import 'scanner_screen.dart';
import 'payment/transaction_store.dart';
import 'payment/transactions_screen.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  await TransactionStore.instance.load();
  runApp(const BankingPrototype());
}

class BankingPrototype extends StatelessWidget {
  const BankingPrototype({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Banking • FYP Prototype',
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Arial',
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff006eaa)),
    ),
    home: const HomeScreen(),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool visible = true;
  void showPanel(String title, String message) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(message, style: const TextStyle(fontSize: 16, height: 1.5)),
              const SizedBox(height: 24),
              const Text(
                'FYP demonstration · Sample data',
                style: TextStyle(color: Colors.blueGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = constraints.maxWidth / 393;
            return Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 306 * scale,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(30 * scale),
                                  ),
                                  child: const CustomPaint(
                                    painter: HeaderPainter(),
                                  ),
                                ),
                              ),

                              Positioned(
                                top: 58 * scale,
                                left: 19 * scale,
                                child: Image.asset(
                                  'assets/images/logo_white.png',
                                  width: 85 * scale,
                                ),
                              ),
                              Positioned(
                                top: 52 * scale,
                                right: 18 * scale,
                                child: Row(
                                  children: [
                                    headerButton(
                                      scale,
                                      Icons.notifications_none_outlined,
                                      'Notifications',
                                      () => showPanel(
                                        'Notifications',
                                        'You’re all caught up. New account updates will appear here.',
                                      ),
                                      badge: true,
                                    ),
                                    SizedBox(width: 9 * scale),
                                    headerButton(
                                      scale,
                                      Icons.logout_outlined,
                                      'Log out',
                                      () => showPanel(
                                        'Demo session',
                                        'This is a local banking prototype. No real banking session is connected.',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 158 * scale,
                                left: 17 * scale,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () => showPanel(
                                        'Savings Pro Account-i',
                                        'Available balance: MYR 388.20\nAccount number: •••• •••• 1234',
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Savings Pro Account-i',
                                            style: TextStyle(
                                              fontSize: 16 * scale,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 6 * scale),
                                          Icon(
                                            Icons.chevron_right,
                                            color: Colors.white,
                                            size: 24 * scale,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 2 * scale),
                                    Row(
                                      children: [
                                        Text(
                                          visible ? 'MYR 388.20' : 'MYR ••••',
                                          style: TextStyle(
                                            fontSize: 22 * scale,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 8 * scale),
                                        SizedBox(
                                          width: 30 * scale,
                                          height: 30 * scale,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            tooltip: visible
                                                ? 'Hide balance'
                                                : 'Show balance',
                                            onPressed: () => setState(
                                              () => visible = !visible,
                                            ),
                                            icon: Icon(
                                              visible
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                        .visibility_off_outlined,
                                              size: 24 * scale,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 228 * scale,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 17 * scale,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 20 * scale),
                                sectionTitle('Top Favourites', scale),
                                SizedBox(height: 34 * scale),
                                Center(
                                  child: GestureDetector(
                                    onTap: () => showPanel(
                                      'Add a favourite',
                                      'Your saved recipients will appear here after you add them.',
                                    ),
                                    child: Image.asset(
                                      'assets/images/favourites.png',
                                      width: 55 * scale,
                                      height: 59 * scale,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 19 * scale),
                                Center(
                                  child: Text(
                                    'You don’t have any Favourites yet.',
                                    style: TextStyle(
                                      fontSize: 16 * scale,
                                      color: const Color(0xff5a646c),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 8 * scale,
                          color: const Color(0xffeff9fc),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: 20 * scale,
                            left: 17 * scale,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              sectionTitle('Offers & Promotion', scale),
                              SizedBox(height: 20 * scale),
                              SizedBox(
                                height: 180 * scale,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 4,
                                  separatorBuilder: (_, _) =>
                                      SizedBox(width: 9 * scale),
                                  itemBuilder: (_, index) => GestureDetector(
                                    onTap: () => showPanel(
                                      'Offers & Promotion',
                                      const [
                                        'Apply online to win Apple products.',
                                        'RHB Personal Financing-i — Online Application Campaign',
                                        'Save towards your next goal.',
                                        'RHB JOY@UNI — Kempen Kad Debit-i RHB (Musim 6)',
                                      ][index],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        18 * scale,
                                      ),
                                      child: Image.asset(
                                        'assets/images/promotion_${index + 1}.png',
                                        width: 300 * scale,
                                        height: 180 * scale,
                                        fit: BoxFit.cover,
                                        alignment: Alignment.topCenter,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            17 * scale,
                            20 * scale,
                            17 * scale,
                            0,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 46 * scale,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xff006eaa),
                              ),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const TransactionsScreen(),
                                ),
                              ),
                              child: Text(
                                'View Transactions',
                                style: TextStyle(fontSize: 15 * scale),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 100 * scale),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: navigation(scale),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
  Widget sectionTitle(String text, double s) => Text(
    text,
    style: TextStyle(
      fontSize: 18 * s,
      fontWeight: FontWeight.w600,
      color: const Color(0xff071b27),
    ),
  );
  Widget headerButton(
    double s,
    IconData icon,
    String label,
    VoidCallback action, {
    bool badge = false,
  }) => SizedBox(
    width: 44 * s,
    height: 44 * s,
    child: IconButton.filled(
      onPressed: action,
      tooltip: label,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff081b25),
        padding: EdgeInsets.zero,
      ),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, size: 25 * s),
          if (badge)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 8 * s,
                height: 8 * s,
                decoration: const BoxDecoration(
                  color: Color(0xffec1833),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    ),
  );
  Widget navigation(double s) => SizedBox(
    height: 106 * s,
    child: Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 75 * s,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xffeeeeee))),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(5, (index) {
                const labels = [
                  'Home',
                  'Accounts',
                  'Services',
                  'Rewards',
                  'Settings',
                ];
                const assets = ['home', 'accounts', '', 'rewards', 'settings'];
                return Expanded(
                  child: Semantics(
                    button: true,
                    selected: index == 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => openNavigation(index),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 43 * s,
                            child: index == 2
                                ? null
                                : Padding(
                                    padding: EdgeInsets.only(top: 12 * s),
                                    child: Image.asset(
                                      'assets/images/${assets[index]}.png',
                                      width: 34 * s,
                                      height: 31 * s,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                          ),
                          SizedBox(height: 3 * s),
                          Text(
                            labels[index],
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 13 * s,
                              fontWeight: index == 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: index == 0
                                  ? const Color(0xff006fa6)
                                  : const Color(0xff5a646c),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Semantics(
              button: true,
              label: 'QR services',
              child: SizedBox(
                width: 74 * s,
                height: 74 * s,
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => openNavigation(2),
                    customBorder: const CircleBorder(),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const CustomPaint(painter: ServicesPainter()),
                        Padding(
                          padding: EdgeInsets.all(14 * s),
                          child: SvgPicture.asset(
                            'assets/icons/banking-icon.svg',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  void openNavigation(int index) {
    if (index == 0) return;
    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const TransactionsScreen()),
      );
      return;
    }
    if (index == 2) {
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => const ScannerScreen()));
      return;
    }
    showPanel(
      const ['Home', 'Accounts', 'Services', 'Rewards', 'Settings'][index],
      const [
        '',
        'Savings Pro Account-i\nAvailable balance: MYR 388.20',
        'Transfer money · Pay bills · DuitNow QR',
        'Your rewards will appear here.',
        'Profile · Security · App preferences',
      ][index],
    );
  }
}

class HeaderPainter extends CustomPainter {
  const HeaderPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 393;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff16214e), Color(0xff003e75), Color(0xff0064a8)],
        ).createShader(Offset.zero & size),
    );
    canvas.save();
    canvas.scale(s);
    final stars = <Offset>[
      const Offset(50, 59),
      const Offset(24, 94),
      const Offset(102, 86),
      const Offset(159, 75),
      const Offset(218, 105),
      const Offset(108, 128),
      const Offset(150, 146),
      const Offset(187, 138),
      const Offset(220, 160),
      const Offset(277, 147),
      const Offset(304, 178),
      const Offset(370, 167),
      const Offset(350, 204),
      const Offset(254, 219),
      const Offset(218, 195),
      const Offset(98, 183),
      const Offset(289, 94),
      const Offset(340, 100),
    ];
    final starPaint = Paint()
      ..color = const Color(0xff93b9d0).withValues(alpha: .65);
    for (final p in stars) {
      final path = Path()
        ..moveTo(p.dx, p.dy - 2)
        ..lineTo(p.dx + .5, p.dy - .5)
        ..lineTo(p.dx + 2, p.dy)
        ..lineTo(p.dx + .5, p.dy + .5)
        ..lineTo(p.dx, p.dy + 2)
        ..lineTo(p.dx - .5, p.dy + .5)
        ..lineTo(p.dx - 2, p.dy)
        ..lineTo(p.dx - .5, p.dy - .5)
        ..close();
      canvas.drawPath(path, starPaint);
    }
    canvas.drawCircle(
      const Offset(319, 164),
      37,
      Paint()
        ..color = const Color(0xff9cddf0).withValues(alpha: .16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
    );
    final outer = Path()
      ..addOval(Rect.fromCircle(center: const Offset(319, 166), radius: 15));
    final inner = Path()
      ..addOval(Rect.fromCircle(center: const Offset(314, 161), radius: 16));
    canvas.drawPath(
      Path.combine(PathOperation.difference, outer, inner),
      Paint()..color = const Color(0xffd4e9ef),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ServicesPainter extends CustomPainter {
  const ServicesPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 74);
    const center = Offset(37, 37);
    canvas.drawCircle(center, 36, Paint()..color = const Color(0xffe1f4fe));
    canvas.drawCircle(center, 33, Paint()..color = const Color(0xffb8e3f9));
    canvas.drawCircle(center, 31, Paint()..color = Colors.white);
    canvas.drawCircle(center, 28.8, Paint()..color = const Color(0xff006eaa));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
