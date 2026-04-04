import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedFarmLogo extends StatefulWidget {
  final double size;
  const AnimatedFarmLogo({super.key, this.size = 200});

  @override
  State<AnimatedFarmLogo> createState() => _AnimatedFarmLogoState();
}

class _AnimatedFarmLogoState extends State<AnimatedFarmLogo> with TickerProviderStateMixin {
  late AnimationController _continuousController;
  late AnimationController _blinkController;
  late AnimationController _shutterController;

  @override
  void initState() {
    super.initState();

    // 1. Continuous movement (breathing, elephant trunk swaying)
    _continuousController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // 2. Eye Blinking (sporadic snapping)
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _triggerRandomBlink();

    // 3. Camera Shutting (mechanical snapping open and closed)
    _shutterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _triggerRandomShutter();
  }

  void _triggerRandomBlink() async {
    while (mounted) {
      // Wait for a random duration between 1 to 4 seconds
      await Future.delayed(Duration(milliseconds: 1000 + math.Random().nextInt(3000)));
      if (mounted) {
        await _blinkController.forward();
        await _blinkController.reverse();
      }
    }
  }

  void _triggerRandomShutter() async {
    while (mounted) {
      // Shutter clicks mechanically every 2-5 seconds
      await Future.delayed(Duration(milliseconds: 2000 + math.Random().nextInt(3000)));
      if (mounted) {
        // Snap close
        await _shutterController.forward();
        await Future.delayed(const Duration(milliseconds: 100)); // hold it shut briefly
        // Snap open
        await _shutterController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _continuousController.dispose();
    _blinkController.dispose();
    _shutterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _continuousController,
        _blinkController,
        _shutterController,
      ]),
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: FarmLogoPainter(
            continuousPhase: _continuousController.value * 2 * math.pi, // 0 to 2pi
            blinkValue: _blinkController.value, // 0.0 (open) to 1.0 (closed)
            shutterValue: _shutterController.value, // 0.0 (open) to 1.0 (closed)
          ),
        );
      },
    );
  }
}

class FarmLogoPainter extends CustomPainter {
  final double continuousPhase;
  final double blinkValue;
  final double shutterValue;

  FarmLogoPainter({
    required this.continuousPhase,
    required this.blinkValue,
    required this.shutterValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // We design the logo in a 200x200 logic space and scale it to fit the widget bounds
    final double scale = size.width / 200.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Color Palette
    final Paint darkGreen = Paint()..color = const Color(0xFF042116)..style = PaintingStyle.fill;
    final Paint teal = Paint()..color = const Color(0xFF14B8A6)..style = PaintingStyle.fill;
    final Paint softTeal = Paint()..color = const Color(0xFF2DD4BF)..style = PaintingStyle.fill;
    final Paint neonGreen = Paint()..color = const Color(0xFF34D399)..style = PaintingStyle.fill;
    
    final Paint strokeTeal = Paint()
      ..color = const Color(0xFF2DD4BF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // ── 1. Background Shield ──
    Path shield = Path()
      ..moveTo(100, 20)
      ..lineTo(145, 40)
      ..lineTo(145, 100)
      ..quadraticBezierTo(145, 140, 100, 175)
      ..quadraticBezierTo(55, 140, 55, 100)
      ..lineTo(55, 40)
      ..close();
    
    final Rect shieldRect = Rect.fromLTRB(55, 20, 145, 175);
    final Paint shieldPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0B3D2E), Color(0xFF031510)],
      ).createShader(shieldRect)
      ..style = PaintingStyle.fill;
      
    // The entire shield has a very gentle, subtle float (breathing)
    final double shieldPulse = math.sin(continuousPhase) * 1.5;
    canvas.save();
    canvas.translate(0, shieldPulse);
    
    // Draw shield shadow, fill, and stroke
    canvas.drawPath(shield.shift(const Offset(0, 4)), Paint()..color = Colors.black.withOpacity(0.3));
    canvas.drawPath(shield, shieldPaint);
    canvas.drawPath(shield, Paint()..color=const Color(0xFF14B8A6)..style=PaintingStyle.stroke..strokeWidth=1.5);
    
    // ── Farm Fields (Base) ──
    Path fields = Path()
      ..moveTo(55, 120)
      ..quadraticBezierTo(80, 110, 110, 130)
      ..quadraticBezierTo(130, 145, 145, 130)
      ..lineTo(145, 100)
      ..quadraticBezierTo(145, 140, 100, 175)
      ..quadraticBezierTo(55, 140, 55, 100)
      ..close();
    canvas.drawPath(fields, darkGreen);
    canvas.drawPath(fields, strokeTeal);

    // ── 2. Elephant (Right Side) ──
    // The trunk gently sways left and right using continuousPhase
    final double trunkSway = math.sin(continuousPhase + math.pi/2) * 6.0;
    
    // Elephant Head & Ear
    Path elephantHead = Path()
      ..moveTo(130, 60) // Top of head
      ..quadraticBezierTo(115, 60, 115, 80) // Forehead down
      ..quadraticBezierTo(115, 100, 125, 120); // Down to trunk base
      
    // Trunk curve controlled by sway variable for organic movement
    elephantHead.quadraticBezierTo(130 + trunkSway, 145, 110 + trunkSway * 1.5, 155); // Trunk tip
    // Inner trunk curve back up
    elephantHead.quadraticBezierTo(145 + trunkSway, 135, 135, 115);
    // Connecting upwards
    elephantHead.lineTo(140, 75);
    elephantHead.close();
    
    Path elephantEar = Path()
      ..moveTo(132, 65)
      ..quadraticBezierTo(160, 55, 170, 80)
      ..quadraticBezierTo(175, 110, 140, 115)
      ..quadraticBezierTo(130, 110, 132, 85)
      ..close();

    canvas.drawPath(elephantEar, teal);
    canvas.drawPath(elephantHead, softTeal);
    
    // Elephant Eye
    canvas.drawCircle(const Offset(123, 75), 1.5, darkGreen);

    // Elephant Tusk (Moving organically with the trunk base)
    Path tusk = Path()
      ..moveTo(125, 120)
      ..quadraticBezierTo(110, 125, 105, 115)
      ..quadraticBezierTo(115, 115, 125, 115)
      ..close();
    canvas.drawPath(tusk, Paint()..color = Colors.white.withOpacity(0.95));

    // ── 3. Farmer (Center/Top) ──
    // Farmer body slightly breathes (bobs) up and down
    final double farmerBreath = math.sin(continuousPhase * 2) * 1.5;
    canvas.save();
    canvas.translate(0, farmerBreath);
    
    // Shoulders / Overalls
    Path shoulders = Path()
      ..moveTo(75, 120)
      ..quadraticBezierTo(75, 85, 100, 85)
      ..quadraticBezierTo(125, 85, 125, 120)
      ..close();
    canvas.drawPath(shoulders, darkGreen);
    canvas.drawPath(shoulders, strokeTeal);
    
    // Overalls straps details
    canvas.drawLine(const Offset(85, 85), const Offset(85, 120), strokeTeal);
    canvas.drawLine(const Offset(115, 85), const Offset(115, 120), strokeTeal);
    
    // Head/Face
    canvas.drawCircle(const Offset(100, 70), 16, teal);
    
    // Hat
    canvas.drawOval(Rect.fromCenter(center: const Offset(100, 55), width: 55, height: 12), softTeal);
    Path hatTop = Path()
      ..moveTo(85, 55)
      ..quadraticBezierTo(85, 35, 100, 35)
      ..quadraticBezierTo(115, 35, 115, 55)
      ..close();
    canvas.drawPath(hatTop, softTeal);
    
    // Eyes (Blinking Animation!)
    // blinkValue ranges from 0.0 (fully open) to 1.0 (fully closed)
    double eyeHeight = 4.0 * (1.0 - blinkValue);
    if (eyeHeight < 0.5) eyeHeight = 0.5; // leaving a small slit when tightly closed
    
    canvas.drawOval(Rect.fromCenter(center: const Offset(93, 70), width: 4, height: eyeHeight), Paint()..color = Colors.white);
    canvas.drawOval(Rect.fromCenter(center: const Offset(107, 70), width: 4, height: eyeHeight), Paint()..color = Colors.white);
    
    // Restore farmer local breath
    canvas.restore(); 
    
    // ── 4. AI Camera (Bottom Left) ──
    // Dynamic Camera Shutter that rotates and tightly closes
    final Offset cameraCenter = const Offset(70, 115);
    final double cameraRadius = 24.0;
    
    // Camera body circle with drop shadow
    canvas.drawCircle(cameraCenter, cameraRadius + 3, Paint()..color=Colors.black.withOpacity(0.3));
    canvas.drawCircle(cameraCenter, cameraRadius + 3, neonGreen);
    canvas.drawCircle(cameraCenter, cameraRadius, Paint()..color = const Color(0xFF031510)..style = PaintingStyle.fill);
    
    // Shutter Blades
    // shutterValue ranges from 0.0 (open) to 1.0 (firmly closed)
    final double shutterAperture = 12.0 - (shutterValue * 11.0); // Aperture hole shrinks to nearly 1.0
    final double rotationOffset = shutterValue * (math.pi / 2.5); // Mechanical Twist while closing
    
    canvas.save();
    canvas.translate(cameraCenter.dx, cameraCenter.dy);
    canvas.rotate(rotationOffset);
    
    Paint bladePaint = Paint()
      ..color = const Color(0xFF2DD4BF).withOpacity(0.9)
      ..style = PaintingStyle.fill;
      
    // Draw 6 interconnecting blades
    for (int i = 0; i < 6; i++) {
        canvas.rotate(math.pi / 3);
        Path blade = Path()
          ..moveTo(shutterAperture, 1)
          ..lineTo(cameraRadius, -10)
          ..lineTo(cameraRadius, 10)
          ..close();
        
        canvas.drawPath(blade, bladePaint);
        // Blade border defining the mechanical lines
        canvas.drawLine(Offset(shutterAperture, 1), Offset(cameraRadius, -10), Paint()..color=const Color(0xFF042116)..strokeWidth=1.5);
    }
    
    // The glowing AI inner sensor lens
    canvas.drawCircle(Offset.zero, shutterAperture - 1, Paint()..color = const Color(0xFF34D399));
    
    // Inner glass glint
    if (shutterAperture > 4) {
      canvas.drawCircle(Offset(shutterAperture * -0.3, shutterAperture * -0.3), shutterAperture * 0.2, Paint()..color=Colors.white.withOpacity(0.6));
    }
    
    canvas.restore(); // Restore camera rotation

    // Final restore of the entire shield context
    canvas.restore();
    
    // Outer canvas bounds restore
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FarmLogoPainter oldDelegate) {
    // Highly efficient selective repainting
    return continuousPhase != oldDelegate.continuousPhase ||
           blinkValue != oldDelegate.blinkValue ||
           shutterValue != oldDelegate.shutterValue;
  }
}
