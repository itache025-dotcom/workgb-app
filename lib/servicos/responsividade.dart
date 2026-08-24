import 'package:flutter/material.dart';

/// Classe para responsividade do WorkGB
class Responsividade {
  /// Obtém o número de colunas para a grid de cards
  static int numeroColunas(BuildContext context) {
    final largura = MediaQuery.of(context).size.width;

    if (largura >= 1200) return 6;      // PC grande
    if (largura >= 900) return 4;       // Tablet paisagem / PC
    if (largura >= 600) return 3;       // Tablet retrato
    return 2;                            // Telemóvel
  }

  /// Obtém o padding horizontal adequado
  static double paddingHorizontal(BuildContext context) {
    final largura = MediaQuery.of(context).size.width;
    if (largura >= 1200) return 48;
    if (largura >= 900) return 32;
    if (largura >= 600) return 24;
    return 16;
  }

  /// Obtém o tamanho máximo do conteúdo central
  static double larguraMaxima(BuildContext context) {
    final largura = MediaQuery.of(context).size.width;
    if (largura >= 1200) return 1200;
    return largura;
  }

  /// Verifica se é um ecrã grande (tablet/PC)
  static bool isTabletOuPc(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }
}
