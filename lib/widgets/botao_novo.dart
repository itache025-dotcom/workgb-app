import 'package:flutter/material.dart';
import '../temas/cores_novo.dart';

class BotaoNovo extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Widget? icon;
  final bool isLoading;

  const BotaoNovo({
    super.key,
    required this.texto,
    this.onPressed,
    this.backgroundColor = CoresNovo.navyPrimary,
    this.textColor = Colors.white,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 2,
          shadowColor: backgroundColor.withOpacity(0.3),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    texto,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class BotaoOutlinedNovo extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final Color color;
  final Widget? icon;

  const BotaoOutlinedNovo({
    super.key,
    required this.texto,
    this.onPressed,
    this.color = CoresNovo.navyPrimary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 8),
            ],
            Text(
              texto,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
