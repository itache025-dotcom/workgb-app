import '../servicos/conversao.dart';

/// Modelo que representa um utilizador do WorkGB
class UsuarioModel {
  final String id;
  final String nomeUsuario;
  final String emailUsuario;
  final String telefoneUsuario;
  final String? fotoUsuario;
  final String? tipoUsuario;
  final double? lat;
  final double? lng;

  UsuarioModel({
    required this.id,
    required this.nomeUsuario,
    required this.emailUsuario,
    required this.telefoneUsuario,
    this.fotoUsuario,
    this.tipoUsuario,
    this.lat,
    this.lng,
  });

  /// Converte JSON do backend para um objeto UsuarioModel
  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    try {
      return UsuarioModel(
        id: json['id'].toString(),
        nomeUsuario: json['nome_usuario'] ?? '',
        emailUsuario: json['email_usuario'] ?? '',
        telefoneUsuario: json['telefone_usuario'] ?? '',
        fotoUsuario: json['foto_usuario'],
        tipoUsuario: json['tipo_usuario'],
        lat: Conversao.converterParaDouble(json['lat']),
        lng: Conversao.converterParaDouble(json['lng']),
      );
    } catch (e) {
      print('ERRO EM UsuarioModel.fromJson: $e');
      print('JSON COM PROBLEMA: $json');
      rethrow;
    }
  }

  /// Converte UsuarioModel para JSON (para enviar ao backend Python)
  Map<String, dynamic> toJson() {
    return {
      'nome_usuario': nomeUsuario,
      'email_usuario': emailUsuario,
      'telefone_usuario': telefoneUsuario,
      'foto_usuario': fotoUsuario,
      'tipo_usuario': tipoUsuario,
      'lat': lat,
      'lng': lng,
    };
  }
}