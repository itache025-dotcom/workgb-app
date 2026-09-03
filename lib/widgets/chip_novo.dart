import 'package:flutter/material.dart';
import '../temas/cores_novo.dart';

class TagProfissaoNovo extends StatelessWidget {
  final String profissao;
  final Color backgroundColor;
  final Color textColor;

  const TagProfissaoNovo({
    super.key,
    required this.profissao,
    this.backgroundColor = CoresNovo.blueLight,
    this.textColor = CoresNovo.navyPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        profissao,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class EstrelasAvaliacaoNovo extends StatelessWidget {
  final double nota;
  final int? totalAvaliacoes;
  final double starSize;
  final double textSize;
  final Color textColor;

  const EstrelasAvaliacaoNovo({
    super.key,
    required this.nota,
    this.totalAvaliacoes,
    this.starSize = 14,
    this.textSize = 13,
    this.textColor = CoresNovo.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          color: CoresNovo.starYellow,
          size: starSize,
        ),
        const SizedBox(width: 4),
        Text(
          nota.toStringAsFixed(1),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: textSize,
            color: textColor,
          ),
        ),
        if (totalAvaliacoes != null) ...[
          const SizedBox(width: 4),
          Text(
            '($totalAvaliacoes)',
            style: TextStyle(
              fontSize: textSize - 1,
              color: CoresNovo.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
