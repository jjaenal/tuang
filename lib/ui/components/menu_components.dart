import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'neumorphic_button.dart';

class MenuPanel extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onClose;
  // Tambah opsi tampilan gelap sesuai warna dasar
  final bool dark;
  const MenuPanel({
    super.key,
    required this.title,
    required this.children,
    this.onClose,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(maxWidth: 360),
      decoration: BoxDecoration(
        color: dark ? AppTheme.darkBase : AppTheme.lightBase,
        gradient: dark ? AppTheme.darkGradient : AppTheme.lightGradient,
        borderRadius: BorderRadius.circular(12),
        border: dark ? AppTheme.darkBorder : AppTheme.lightBorder,
        boxShadow: dark ? AppTheme.darkShadow : AppTheme.lightShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: dark ? AppTheme.darkHeader : AppTheme.lightHeader,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: dark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onClose != null)
                  InkWell(
                    onTap: onClose,
                    child: Icon(
                      Icons.close,
                      color: dark ? Colors.white70 : Colors.black87,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...children,
          const SizedBox(height: 8),
          // if (onClose != null)
          //   SizedBox(
          //     width: 220,
          //     child: NeumorphicButton(
          //       label: 'Close',
          //       icon: Icons.close,
          //       onPressed: onClose,
          //       primary: false,
          //     ),
          //   ),
        ],
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  const MenuButton({super.key, required this.label, this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: NeumorphicButton(
        label: label,
        onPressed: onPressed,
        icon: icon,
        primary: false,
      ),
    );
  }
}

class OptionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  const OptionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }
}
