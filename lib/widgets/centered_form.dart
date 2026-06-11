import 'package:flutter/material.dart';

class CenteredForm extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const CenteredForm({super.key, required this.child, this.maxWidth = 680});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
