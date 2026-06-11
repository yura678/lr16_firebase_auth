import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  static const Widget _spinner = SizedBox(
    height: 20,
    width: 20,
    child: CircularProgressIndicator(strokeWidth: 2),
  );

  @override
  Widget build(BuildContext context) {
    final style = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
    );
    final onTap = isLoading ? null : onPressed;

    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onTap,
        style: style,
        icon: isLoading ? _spinner : Icon(icon),
        label: Text(label),
      );
    }

    return ElevatedButton(
      onPressed: onTap,
      style: style,
      child: isLoading ? _spinner : Text(label),
    );
  }
}
