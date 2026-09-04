import 'package:flutter/material.dart';
import '../temas/cores_novo.dart';

class LogoNovo extends StatelessWidget {
  final double fontSize;
  final bool showSubtitle;

  const LogoNovo({
    super.key,
    this.fontSize = 22,
    this.showSubtitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [CoresNovo.navyPrimary, CoresNovo.blueSecondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                'L',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: fontSize * 0.75,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Liri',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: fontSize,
                color: CoresNovo.navyPrimary,
              ),
            ),
            Text(
              'fy',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: fontSize,
                color: CoresNovo.starYellow,
              ),
            ),
          ],
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 4),
          const Text(
            'Talentos & Serviços da Guiné-Bissau',
            style: TextStyle(
              color: CoresNovo.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
