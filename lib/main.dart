import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  Size? screenSize;
  Offset paddlePos = Offset.zero;
  Offset targetPos = Offset.zero;
  final double paddleRadius = 35.0;
  final double smoothing = 0.15;

  int frameCount = 0;
  int lastFpsTimeMs = 0;
  double fps = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    lastFpsTimeMs = DateTime.now().millisecondsSinceEpoch;
  }

  void _onTick(Duration elapsed) {
    if (screenSize == null) return;

    final dx = targetPos.dx - paddlePos.dx;
    final dy = targetPos.dy - paddlePos.dy;
    final nextX = paddlePos.dx + dx * smoothing;
    final nextY = paddlePos.dy + dy * smoothing;

    final clampedX = nextX.clamp(
      paddleRadius,
      screenSize!.width - paddleRadius,
    );
    final clampedY = nextY.clamp(
      paddleRadius,
      screenSize!.height - paddleRadius,
    );

    frameCount++;
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - lastFpsTimeMs;
    if (diff >= 1000) {
      fps = frameCount * 1000 / diff;
      frameCount = 0;
      lastFpsTimeMs = now;
    }

    setState(() {
      paddlePos = Offset(clampedX, clampedY);
    });
  }

  void _updateTarget(Offset p) {
    if (screenSize == null) return;
    final clampedX = p.dx.clamp(
      paddleRadius,
      screenSize!.width - paddleRadius,
    );
    final clampedY = p.dy.clamp(
      paddleRadius,
      screenSize!.height - paddleRadius,
    );
    setState(() {
      targetPos = Offset(clampedX, clampedY);
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (screenSize == null) {
          screenSize = size;
          final center = Offset(size.width / 2, size.height / 2);
          paddlePos = center;
          targetPos = center;
        } else {
          screenSize = size;
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (details) => _updateTarget(details.localPosition),
          onPanUpdate: (details) => _updateTarget(details.localPosition),
          child: Stack(
            children: [
              CustomPaint(
                size: Size.infinite,
                painter: GamePainter(
                  paddlePos: paddlePos,
                  paddleRadius: paddleRadius,
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Text(
                  'FPS: ${fps.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GamePainter extends CustomPainter {
  final Offset paddlePos;
  final double paddleRadius;

  GamePainter({
    required this.paddlePos,
    required this.paddleRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF111111);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final paddlePaint = Paint()..color = Colors.blueAccent;
    canvas.drawCircle(paddlePos, paddleRadius, paddlePaint);
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) {
    return oldDelegate.paddlePos != paddlePos ||
        oldDelegate.paddleRadius != paddleRadius;
  }
}
