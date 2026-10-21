import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MachineStatusSummaryCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isSelected;

  const MachineStatusSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.isSelected = false,
  });

  @override
  State<MachineStatusSummaryCard> createState() => _MachineStatusSummaryCardState();
}

class _MachineStatusSummaryCardState extends State<MachineStatusSummaryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isSelected;
    final elevated = active || _isHovered;

    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(0, elevated ? -3 : 0, 0),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: active ? widget.color.withValues(alpha: 0.12) : AppColors.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active
                    ? widget.color
                    : (_isHovered ? widget.color.withValues(alpha: 0.4) : AppColors.border),
                width: active ? 1.8 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: active
                      ? widget.color.withValues(alpha: 0.22)
                      : (_isHovered
                          ? widget.color.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.03)),
                  blurRadius: elevated ? 10 : 6,
                  offset: Offset(0, elevated ? 3 : 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: active
                            ? widget.color.withValues(alpha: 0.2)
                            : widget.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(widget.icon, color: widget.color, size: 18),
                    ),
                    AnimatedScale(
                      scale: active ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutBack,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: widget.color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: active ? widget.color : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
