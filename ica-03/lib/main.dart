import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(const ValentineApp());

class ValentineApp extends StatelessWidget {
  const ValentineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ValentineHome(),
      theme: ThemeData(useMaterial3: true),
    );
  }
}

class ValentineHome extends StatefulWidget {
  const ValentineHome({super.key});

  @override
  State<ValentineHome> createState() => _ValentineHomeState();
}

class _ValentineHomeState extends State<ValentineHome>
    with TickerProviderStateMixin {
  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';
  bool isPulsing = false;
  bool showBalloons = false;

  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  late AnimationController _balloonController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Sparkle rotation
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Balloon animation
    _balloonController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sparkleController.dispose();
    _balloonController.dispose();
    super.dispose();
  }

  void _togglePulse() {
    setState(() {
      isPulsing = !isPulsing;
      if (isPulsing) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    });
  }

  void _launchBalloons() {
    setState(() {
      showBalloons = true;
      _balloonController.forward(from: 0);
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => showBalloons = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              const Color(0xFFFFE5F0),
              const Color(0xFFFFCDD2),
              const Color(0xFFE91E63).withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                'Cupid\'s Canvas',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE91E63),
                ),
              ),
              const SizedBox(height: 24),

              // Emoji Selection Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: selectedEmoji,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.favorite, color: Color(0xFFE91E63)),
                  items: emojiOptions
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedEmoji = value ?? selectedEmoji),
                ),
              ),

              const SizedBox(height: 24),

              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _togglePulse,
                    icon: Icon(isPulsing ? Icons.pause : Icons.play_arrow),
                    label: Text(isPulsing ? 'Stop Pulse' : 'Start Pulse'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _launchBalloons,
                    icon: const Icon(Icons.celebration),
                    label: const Text('Balloons!'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF48FB1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Main Heart Display
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _pulseController,
                          _sparkleController,
                        ]),
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: CustomPaint(
                              size: const Size(320, 320),
                              painter: HeartEmojiPainter(
                                type: selectedEmoji,
                                sparkleRotation: _sparkleController.value * 2 * math.pi,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (showBalloons)
                      AnimatedBuilder(
                        animation: _balloonController,
                        builder: (context, child) {
                          return CustomPaint(
                            size: MediaQuery.of(context).size,
                            painter: BalloonPainter(
                              progress: _balloonController.value,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeartEmojiPainter extends CustomPainter {
  HeartEmojiPainter({
    required this.type,
    required this.sparkleRotation,
  });

  final String type;
  final double sparkleRotation;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw love trail (glowing aura)
    _drawLoveTrail(canvas, center);

    // Draw main heart with gradient
    _drawHeart(canvas, center, size);

    // Draw face features
    _drawFace(canvas, center);

    // Draw party-specific elements
    if (type == 'Party Heart') {
      _drawPartyHat(canvas, center);
      _drawConfetti(canvas, center);
    }

    // Draw animated sparkles
    _drawSparkles(canvas, center);
  }

  void _drawLoveTrail(Canvas canvas, Offset center) {
    for (int i = 0; i < 3; i++) {
      final offset = (i + 1) * 8.0;
      final alpha = (255 * (1 - i / 3)).toInt();

      final heartPath = Path()
        ..moveTo(center.dx, center.dy + 60 + offset)
        ..cubicTo(
          center.dx + 110 + offset,
          center.dy - 10 + offset,
          center.dx + 60 + offset,
          center.dy - 120 + offset,
          center.dx,
          center.dy - 40 + offset,
        )
        ..cubicTo(
          center.dx - 60 - offset,
          center.dy - 120 + offset,
          center.dx - 110 - offset,
          center.dy - 10 + offset,
          center.dx,
          center.dy + 60 + offset,
        )
        ..close();

      final paint = Paint()
        ..color = (type == 'Party Heart'
                ? const Color(0xFFF48FB1)
                : const Color(0xFFE91E63))
            .withAlpha(alpha ~/ 2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawPath(heartPath, paint);
    }
  }

  void _drawHeart(Canvas canvas, Offset center, Size size) {
    final heartPath = Path()
      ..moveTo(center.dx, center.dy + 60)
      ..cubicTo(
        center.dx + 110,
        center.dy - 10,
        center.dx + 60,
        center.dy - 120,
        center.dx,
        center.dy - 40,
      )
      ..cubicTo(
        center.dx - 60,
        center.dy - 120,
        center.dx - 110,
        center.dy - 10,
        center.dx,
        center.dy + 60,
      )
      ..close();

    // Gradient fill
    final rect = Rect.fromCircle(center: center, radius: 120);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: type == 'Party Heart'
          ? [
              const Color(0xFFFFA4C9),
              const Color(0xFFF48FB1),
              const Color(0xFFEC407A),
            ]
          : [
              const Color(0xFFFF5777),
              const Color(0xFFE91E63),
              const Color(0xFFC2185B),
            ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawPath(heartPath, paint);

    // Add highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx - 30, center.dy - 50),
      25,
      highlightPaint,
    );
  }

  void _drawFace(Canvas canvas, Offset center) {
    // Eyes
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.black;

    // Left eye
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 12, eyePaint);
    canvas.drawCircle(Offset(center.dx - 28, center.dy - 8), 6, pupilPaint);

    // Right eye
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 12, eyePaint);
    canvas.drawCircle(Offset(center.dx + 32, center.dy - 8), 6, pupilPaint);

    // Rosy cheeks
    final blushPaint = Paint()..color = const Color(0xFFFF8A80).withOpacity(0.4);
    canvas.drawCircle(Offset(center.dx - 60, center.dy + 5), 15, blushPaint);
    canvas.drawCircle(Offset(center.dx + 60, center.dy + 5), 15, blushPaint);

    // Smile
    final mouthPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path()
      ..moveTo(center.dx - 25, center.dy + 20)
      ..quadraticBezierTo(
        center.dx,
        center.dy + 35,
        center.dx + 25,
        center.dy + 20,
      );

    canvas.drawPath(mouthPath, mouthPaint);
  }

  void _drawPartyHat(Canvas canvas, Offset center) {
    // Hat body
    final hatPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color.fromARGB(255, 193, 226, 254),
          const Color.fromARGB(255, 106, 41, 147),
        ],
      ).createShader(Rect.fromLTWH(center.dx - 40, center.dy - 120, 80, 80));

    final hatPath = Path()
      ..moveTo(center.dx, center.dy - 120)
      ..lineTo(center.dx - 40, center.dy - 40)
      ..lineTo(center.dx + 40, center.dy - 40)
      ..close();

    canvas.drawPath(hatPath, hatPaint);

    // Hat stripes
    final stripePaint = Paint()
      ..color = const Color(0xFFFF6F00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (int i = 0; i < 3; i++) {
      final y = center.dy - 110 + i * 22;
      canvas.drawLine(
        Offset(center.dx - 35 + i * 7, y),
        Offset(center.dx + 35 - i * 7, y),
        stripePaint,
      );
    }

    // Pom-pom
    final pomPaint = Paint()..color = const Color(0xFFFF1744);
    canvas.drawCircle(Offset(center.dx, center.dy - 125), 8, pomPaint);
  }

  void _drawConfetti(Canvas canvas, Offset center) {
    final random = math.Random(42); // Fixed seed for consistency
    final confettiColors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFE66D),
      const Color(0xFF95E1D3),
      const Color(0xFFF38181),
    ];

    for (int i = 0; i < 20; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final distance = 130 + random.nextDouble() * 40;
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;

      final paint = Paint()
        ..color = confettiColors[i % confettiColors.length];

      if (i % 3 == 0) {
        // Triangle
        final size = 8.0 + random.nextDouble() * 6;
        final path = Path()
          ..moveTo(x, y - size)
          ..lineTo(x - size, y + size)
          ..lineTo(x + size, y + size)
          ..close();
        canvas.drawPath(path, paint);
      } else if (i % 3 == 1) {
        // Circle
        canvas.drawCircle(
          Offset(x, y),
          4 + random.nextDouble() * 4,
          paint,
        );
      } else {
        // Rectangle
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(x, y),
            width: 8 + random.nextDouble() * 6,
            height: 3 + random.nextDouble() * 3,
          ),
          paint,
        );
      }
    }
  }

  void _drawSparkles(Canvas canvas, Offset center) {
    final sparklePositions = [
      Offset(center.dx - 90, center.dy - 80),
      Offset(center.dx + 90, center.dy - 80),
      Offset(center.dx - 100, center.dy + 20),
      Offset(center.dx + 100, center.dy + 20),
      Offset(center.dx, center.dy - 110),
    ];

    for (int i = 0; i < sparklePositions.length; i++) {
      final rotation = sparkleRotation + (i * math.pi / 3);
      _drawSparkle(canvas, sparklePositions[i], rotation, 12);
    }
  }

  void _drawSparkle(Canvas canvas, Offset position, double rotation, double size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotation);

    // Draw four lines forming a star
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(-size / 2, 0),
        Offset(size / 2, 0),
        paint,
      );
      canvas.rotate(math.pi / 4);
    }

    canvas.restore();

    // Add center dot
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(position, 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.sparkleRotation != sparkleRotation;
}

class BalloonPainter extends CustomPainter {
  BalloonPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(100); // Fixed seed
    final balloonColors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFE66D),
      const Color(0xFFF38181),
      const Color(0xFF95E1D3),
      const Color(0xFFFFA07A),
    ];

    for (int i = 0; i < 12; i++) {
      final startY = size.height + 100 + random.nextDouble() * 100;
      final currentY = startY - (progress * (size.height + 200));
      final x = (size.width / 13) * (i + 1) + random.nextDouble() * 30 - 15;
      final sway = math.sin(progress * 4 * math.pi + i) * 20;

      if (currentY > -100 && currentY < size.height + 100) {
        _drawBalloon(
          canvas,
          Offset(x + sway, currentY),
          balloonColors[i % balloonColors.length],
        );
      }
    }
  }

  void _drawBalloon(Canvas canvas, Offset position, Color color) {
    // Balloon body
    final balloonPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.8),
          color,
          color.withOpacity(0.6),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: position, radius: 25));

    final balloonPath = Path()
      ..moveTo(position.dx, position.dy + 30)
      ..quadraticBezierTo(
        position.dx - 20,
        position.dy + 20,
        position.dx - 20,
        position.dy,
      )
      ..quadraticBezierTo(
        position.dx - 20,
        position.dy - 25,
        position.dx,
        position.dy - 30,
      )
      ..quadraticBezierTo(
        position.dx + 20,
        position.dy - 25,
        position.dx + 20,
        position.dy,
      )
      ..quadraticBezierTo(
        position.dx + 20,
        position.dy + 20,
        position.dx,
        position.dy + 30,
      )
      ..close();

    canvas.drawPath(balloonPath, balloonPaint);

    // String
    final stringPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final stringPath = Path()
      ..moveTo(position.dx, position.dy + 30)
      ..quadraticBezierTo(
        position.dx + 5,
        position.dy + 50,
        position.dx - 3,
        position.dy + 70,
      );

    canvas.drawPath(stringPath, stringPaint);

    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4);
    canvas.drawCircle(
      Offset(position.dx - 8, position.dy - 15),
      6,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant BalloonPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
