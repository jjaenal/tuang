import 'package:flutter/material.dart';

// Tambah enum untuk varian ukuran
enum ButtonSize { standard, compact }

/// Reusable dark-neumorphic button with animated pressed state.
class NeumorphicButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool primary; // if true, use teal accent gradient
  final double width;
  final double height;
  // Tambah parameter size
  final ButtonSize size;

  const NeumorphicButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.primary = false,
    this.width = 220,
    this.height = 56,
    this.size = ButtonSize.standard,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _pressed = false;
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    const baseSurface = Color(0xFF1A1F24);

    final disabled = widget.onPressed == null;

    return FocusableActionDetector(
      onShowHoverHighlight: (v) => setState(() => _hovered = v),
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      child: Semantics(
        button: true,
        label: widget.label,
        enabled: !disabled,
        child: GestureDetector(
          onTap: disabled ? null : widget.onPressed,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            scale: _pressed ? 0.985 : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              // Gunakan ukuran efektif berdasarkan size variant
              width: widget.size == ButtonSize.standard ? widget.width : 120,
              height: widget.size == ButtonSize.standard ? widget.height : 36,
              decoration: BoxDecoration(
                color: baseSurface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [],
                border: Border.all(
                  color:
                      _focused
                          ? Colors.lightBlueAccent
                          : _hovered
                          ? Colors.white24
                          : Colors.white12,
                ),
              ),
              child: Opacity(
                opacity: disabled ? 0.6 : 1,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF20252B), Color(0xFF1A1F24)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: Colors.white70),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          fontSize: widget.size == ButtonSize.compact ? 14 : 16,
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
    );
  }
}
