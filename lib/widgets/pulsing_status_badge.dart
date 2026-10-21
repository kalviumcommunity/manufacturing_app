import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PulsingStatusBadge extends StatefulWidget {
  final String status;
  final bool showLabel;
  final double dotSize;
  final EdgeInsetsGeometry padding;

  const PulsingStatusBadge({
    super.key,
    required this.status,
    this.showLabel = true,
    this.dotSize = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });

  @override
  State<PulsingStatusBadge> createState() => _PulsingStatusBadgeState();
}

class _PulsingStatusBadgeState extends State<PulsingStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.getStatusColor(widget.status);
    final statusBg = AppColors.getStatusLightBg(widget.status);

    final dot = RepaintBoundary(
      child: SizedBox(
        width: widget.dotSize * 1.8,
        height: widget.dotSize * 1.8,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulsing ring
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: widget.dotSize,
                    height: widget.dotSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor.withValues(alpha: _opacityAnimation.value),
                    ),
                  ),
                );
              },
            ),
            // Inner solid dot
            Container(
              width: widget.dotSize,
              height: widget.dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor,
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (!widget.showLabel) {
      return dot;
    }

    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: statusBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          dot,
          const SizedBox(width: 6),
          Text(
            widget.status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
