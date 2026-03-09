import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    this.size = 28,
    this.strokeWidth = 2.6,
    super.key,
  });

  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(strokeWidth: strokeWidth),
    );
  }
}
