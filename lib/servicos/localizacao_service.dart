import 'package:geolocator/geolocator.dart';

/// Serviço responsável por obter a localização GPS do dispositivo
class LocalizacaoService {
  /// Obtém a posição atual do utilizador
  /// Retorna um mapa com 'lat' e 'lng'
  /// Lança exceção se a localização estiver desativada ou for negada
  static Future<Map<String, double>> obterLocalizacao() async {
    // Verifica se o serviço de localização está ativo
    bool servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) {
      throw Exception('Ativa a localização nas definições do telemóvel');
    }

    // Verifica e pede permissão de localização
    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        throw Exception('Permissão de localização foi negada');
      }
    }
    if (permissao == LocationPermission.deniedForever) {
      throw Exception('Permissão de localização bloqueada. Ativa nas definições');
    }

    // Obtém a posição atual
    Position posicao = await Geolocator.getCurrentPosition();
    return {'lat': posicao.latitude, 'lng': posicao.longitude};
  }
}