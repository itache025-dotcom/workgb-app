import 'package:flutter/material.dart';
import '../temas/cores_novo.dart';

class BadgeGBNovo extends StatelessWidget {
  const BadgeGBNovo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bandeira simplificada GB
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              width: 18,
              height: 12,
              child: Row(
                children: [
                  Container(width: 6, color: const Color(0xFFCE1126)), // Vermelho
                  Expanded(
                    child: Column(
                      children: [
                        Container(height: 6, color: const Color(0xFFFCD116)), // Amarelo
                        Container(height: 6, color: const Color(0xFF007A3D)), // Verde
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            '+245',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: CoresNovo.navyPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
