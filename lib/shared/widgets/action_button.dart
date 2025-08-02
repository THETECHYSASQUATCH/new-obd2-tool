import 'package:flutter/material.dart';

/// A reusable action button widget for triggering operations
class ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;

  const ActionButton({
    Key? key,
    required this.title,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor ?? Theme.of(context).colorScheme.primaryContainer,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: foregroundColor ?? Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                )
              else
                Icon(
                  icon,
                  size: 24,
                  color: foregroundColor ?? Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: foregroundColor ?? Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.medium,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}