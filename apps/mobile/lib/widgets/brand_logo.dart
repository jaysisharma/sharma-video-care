import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme_tokens.dart';

/// Professional, timeless brand mark and logo for QuickySewa.
/// Pure geometric camera aperture precision optics craft — no sci-fi or neon.
class SvcBrandLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showSubtitle;
  final bool isHorizontal;
  final Color? textColor;
  final Color? subtitleColor;
  final String? customSubtitle;

  const SvcBrandLogo({
    super.key,
    this.size = 64,
    this.showText = true,
    this.showSubtitle = true,
    this.isHorizontal = false,
    this.textColor,
    this.subtitleColor,
    this.customSubtitle,
  });

  const SvcBrandLogo.markOnly({
    super.key,
    this.size = 48,
  })  : showText = false,
        showSubtitle = false,
        isHorizontal = false,
        textColor = null,
        subtitleColor = null,
        customSubtitle = null;

  const SvcBrandLogo.horizontal({
    super.key,
    this.size = 40,
    this.showText = true,
    this.showSubtitle = true,
    this.textColor,
    this.subtitleColor,
    this.customSubtitle,
  }) : isHorizontal = true;

  @override
  Widget build(BuildContext context) {
    final emblem = _buildEmblem();

    if (!showText) {
      return emblem;
    }

    final brandTitle = Text(
      'QUICKYSEWA',
      style: GoogleFonts.inter(
        fontSize: isHorizontal ? (size * 0.36).clamp(13.0, 16.0) : (size * 0.28).clamp(15.0, 20.0),
        fontWeight: FontWeight.w800,
        letterSpacing: isHorizontal ? 1.0 : 1.8,
        color: textColor ?? SvcColors.ink,
      ),
    );

    final brandSubtitle = Text(
      customSubtitle ?? 'CAMERA CRAFT & ELECTRONICS LAB',
      style: GoogleFonts.inter(
        fontSize: isHorizontal ? (size * 0.22).clamp(9.5, 11.0) : (size * 0.18).clamp(10.0, 12.0),
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
        color: subtitleColor ?? SvcColors.muted,
      ),
    );

    if (isHorizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          emblem,
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              brandTitle,
              if (showSubtitle) ...[
                const SizedBox(height: 2),
                brandSubtitle,
              ],
            ],
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        emblem,
        SizedBox(height: (size * 0.28).clamp(14.0, 24.0)),
        brandTitle,
        if (showSubtitle) ...[
          const SizedBox(height: 6),
          brandSubtitle,
        ],
      ],
    );
  }

  Widget _buildEmblem() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/brand_emblem.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildVectorFallback(),
        ),
      ),
    );
  }

  Widget _buildVectorFallback() {
    return CustomPaint(
      size: Size(size, size),
      painter: _ApertureVectorPainter(),
    );
  }
}

/// Fallback vector aperture mark inspired by optical lens craftsmanship
class _ApertureVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer dark bezel
    final bezelPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bezelPaint);

    // Inner rim line
    final rimPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width * 0.03
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius * 0.88, rimPaint);

    // 6 Aperture blades
    final bladePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width * 0.025
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const bladeCount = 6;
    for (int i = 0; i < bladeCount; i++) {
      final angle = (i * 2 * math.pi) / bladeCount;
      final start = Offset(
        center.dx + radius * 0.82 * math.cos(angle),
        center.dy + radius * 0.82 * math.sin(angle),
      );
      final tangentAngle = angle + (math.pi / 2.8);
      final end = Offset(
        start.dx + radius * 0.65 * math.cos(tangentAngle),
        start.dy + radius * 0.65 * math.sin(tangentAngle),
      );
      canvas.drawLine(start, end, bladePaint);
    }

    // Center warm amber optics focal core
    final coreGlowPaint = Paint()
      ..color = const Color(0xFFE86F1C)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.22, coreGlowPaint);

    final innerCorePaint = Paint()
      ..color = const Color(0xFFFDBA74)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.12, innerCorePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
