import 'package:flutter/material.dart';

class OvalFramePainter extends CustomPainter {
  final bool isInside;
  OvalFramePainter({required this.isInside});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(center: center, width: 240, height: 320);

    // Use gradient based on face detection status
    if (isInside) {
      final greenGradient = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF34D399)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect);
      
      greenGradient
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0;
      
      canvas.drawOval(rect, greenGradient);
    } else {
      final blueGradient = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect);
      
      blueGradient
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0;
      
      canvas.drawOval(rect, blueGradient);
    }

    // Draw outer glow effect
    final glowPaint = Paint()
      ..color = isInside 
          ? const Color(0xFF10B981).withOpacity(0.3)
          : const Color(0xFF6366F1).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    final glowRect = Rect.fromCenter(center: center, width: 260, height: 340);
    canvas.drawOval(glowRect, glowPaint);
  }

  @override
  bool shouldRepaint(covariant OvalFramePainter oldDelegate) {
    return oldDelegate.isInside != isInside;
  }
}