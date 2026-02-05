import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String text;

  const LoadingButton({super.key, required this.isLoading, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
      child: isLoading
          ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary)))
          : Text(text),
    );
  }
}