import 'package:flutter/material.dart';

class MenuPanel extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onClose;
  const MenuPanel({super.key, required this.title, required this.children, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(maxWidth: 360),
      decoration: BoxDecoration(
        color: const Color(0xFF5B3A1A),
        gradient: const LinearGradient(
          colors: [Color(0xFF6B481F), Color(0xFF4A2F14)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB2834A), width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFCC9A53),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onClose != null)
                  InkWell(
                    onTap: onClose,
                    child: const Icon(Icons.close, color: Colors.black87),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...children,
          const SizedBox(height: 8),
          if (onClose != null)
            TextButton.icon(
              onPressed: onClose,
              icon: const Icon(Icons.close, color: Colors.white70),
              label: const Text('Close', style: TextStyle(color: Colors.white70)),
            ),
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
      width: 280,
      child: ElevatedButton.icon(
        icon: icon != null ? Icon(icon) : const Icon(Icons.circle, size: 0),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class OptionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  const OptionRow({super.key, required this.icon, required this.label, required this.trailing});

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