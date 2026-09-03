import '../servicos/conversao.dart';

/// Modelo que representa um trabalhador disponível no marketplace
class TrabalhadorModel {
  final String id;
  final String nomeTrabalhador;
  final String profissaoTrabalhador;
  final String? fotoTrabalhador;
  final String? descricaoTrabalhador;
  final double? lat;
  final double? lng;
  final double? distanciaKm;
  final List<String> disponibilidadeDias;
  final String? disponibilidadeInicio;
  final String? disponibilidadeFim;
  final List<String> documentos;
  final List<String> galeria;
  double mediaAvaliacoes;
  int totalAvaliacoes;
  final String? utilizadorId;

  TrabalhadorModel({
    required this.id,
    required this.nomeTrabalhador,
    required this.profissaoTrabalhador,
    this.fotoTrabalhador,
    this.descricaoTrabalhador,
    this.lat,
    this.lng,
    this.distanciaKm,
    this.disponibilidadeDias = const [],
    this.disponibilidadeInicio,
    this.disponibilidadeFim,
    this.documentos = const [],
    this.galeria = const [],
    this.mediaAvaliacoes = 0.0,
    this.totalAvaliacoes = 0,
    this.utilizadorId,
  });

  /// Converte JSON do backend para um objeto TrabalhadorModel
  factory TrabalhadorModel.fromJson(Map<String, dynamic> json) {
    try {
      return TrabalhadorModel(
        id: json['id'].toString(),
        nomeTrabalhador: json['nome_trabalhador'] ?? '',
        profissaoTrabalhador: json['profissao_trabalhador'] ?? '',
        fotoTrabalhador: json['foto_trabalhador'],
        descricaoTrabalhador: json['descricao_trabalhador'],
        lat: Conversao.converterParaDouble(json['lat']),
        lng: Conversao.converterParaDouble(json['lng']),
        distanciaKm: Conversao.converterParaDouble(json['distancia_km']),
        disponibilidadeDias: List<String>.from(json['disponibilidade_dias'] ?? []),
        disponibilidadeInicio: json['disponibilidade_inicio'],
        disponibilidadeFim: json['disponibilidade_fim'],
        documentos: List<String>.from(json['documentos'] ?? []),
        galeria: List<String>.from(json['galeria'] ?? []),
        mediaAvaliacoes: (json['media_avaliacoes'] as num?)?.toDouble() ?? 0.0,
        totalAvaliacoes: (json['total_avaliacoes'] as num?)?.toInt() ?? 0,
        utilizadorId: json['utilizador_id']?.toString(),
      );
    } catch (e) {
      print('ERRO EM TrabalhadorModel.fromJson: $e');
      print('JSON COM PROBLEMA: $json');
      rethrow;
    }
  }

  /// Converte TrabalhadorModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'nome_trabalhador': nomeTrabalhador,
      'profissao_trabalhador': profissaoTrabalhador,
      'foto_trabalhador': fotoTrabalhador,
      'descricao_trabalhador': descricaoTrabalhador,
      'lat': lat,
      'lng': lng,
      'distancia_km': distanciaKm,
      'disponibilidade_dias': disponibilidadeDias,
      'disponibilidade_inicio': disponibilidadeInicio,
      'disponibilidade_fim': disponibilidadeFim,
      'documentos': documentos,
      'galeria': galeria,
      'media_avaliacoes': mediaAvaliacoes,
      'total_avaliacoes': totalAvaliacoes,
      'utilizador_id': utilizadorId,
    };
  }
}