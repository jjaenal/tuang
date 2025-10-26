import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'neumorphic_button.dart';

/// Panel konten untuk dialog/overlay dengan tema terang/gelap.
class MenuPanel extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onClose;
  // Tambah opsi tampilan gelap sesuai warna dasar
  final bool dark;
  // Mode khusus untuk bottom sheet agar tidak terlihat seperti dialog modal
  final bool asSheet;
  // Konten tambahan di header panel (mis. jumlah koin)
  final Widget? headerTrailing;
  const MenuPanel({
    super.key,
    required this.title,
    required this.children,
    this.onClose,
    this.dark = false,
    this.asSheet = false,
    this.headerTrailing,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 400 ? 360.0 : screenWidth * 0.9;

    // Penyesuaian gaya ketika ditampilkan sebagai bottom sheet di mobile
    final BorderRadius panelRadius =
        asSheet
            ? const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            )
            : BorderRadius.circular(12);

    return Container(
      padding: EdgeInsets.all(screenWidth > 400 ? 12 : 8),
      // Untuk sheet, paksa lebar penuh agar menempel di sisi bawah
      width: asSheet ? double.infinity : null,
      constraints: BoxConstraints(
        maxWidth: asSheet ? double.infinity : maxWidth,
      ),
      decoration: BoxDecoration(
        color: dark ? AppTheme.darkBase : AppTheme.lightBase,
        // Hindari gradient yang kuat saat sebagai sheet agar tidak seperti dialog mengambang
        gradient:
            asSheet
                ? null
                : (dark ? AppTheme.darkGradient : AppTheme.lightGradient),
        borderRadius: panelRadius,
        border: dark ? AppTheme.darkBorder : AppTheme.lightBorder,
        // Hilangkan shadow di mode sheet agar tidak tampak seperti modal overlay
        boxShadow:
            asSheet
                ? const []
                : (dark ? AppTheme.darkShadow : AppTheme.lightShadow),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth > 400 ? 12 : 8,
              vertical: screenWidth > 400 ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: dark ? AppTheme.darkHeader : AppTheme.lightHeader,
              borderRadius:
                  asSheet
                      ? const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      )
                      : BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: dark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth > 400 ? 16 : 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (headerTrailing != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: headerTrailing!,
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
              ],
            ),
          ),
          SizedBox(height: screenWidth > 400 ? 12 : 8),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: asSheet ? MediaQuery.of(context).size.height * 0.8 : double.infinity,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...children,
                  SizedBox(height: screenWidth > 400 ? 8 : 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tombol menu berlebar tetap yang membungkus `NeumorphicButton`.
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

/// Baris opsi dengan ikon, label, dan kontrol trailing.
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth <= 400;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isCompact ? 4 : 6),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            flex: isCompact ? 2 : 3,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white70, size: isCompact ? 16 : 18),
                SizedBox(width: isCompact ? 6 : 8),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isCompact ? 13 : 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(flex: isCompact ? 3 : 2, child: trailing),
        ],
      ),
    );
  }
}
