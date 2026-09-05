import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ServicoAtualizacao {
  static String get _urlVersao {
    return 'https://raw.githubusercontent.com/itache025-dotcom/workgb-app/main/versao.json?t=${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Verifica se há nova versão disponível
  static Future<bool> verificarAtualizacao() async {
    try {
      print('DEBUG SERV_ATUALIZACAO: Consultando $_urlVersao');
      final resposta = await http.get(Uri.parse(_urlVersao)).timeout(const Duration(seconds: 15));
      if (resposta.statusCode != 200) {
        print('DEBUG SERV_ATUALIZACAO: Erro na resposta: ${resposta.statusCode}');
        return false;
      }

      final dados = json.decode(resposta.body);
      final versaoRemota = dados['versao'].toString();

      final info = await PackageInfo.fromPlatform();
      final versaoLocal = info.version;

      print('DEBUG SERV_ATUALIZACAO: Local: $versaoLocal | Remota: $versaoRemota');

      // Comparar versões
      final resultado = _compararVersoes(versaoRemota, versaoLocal) > 0;
      print('DEBUG SERV_ATUALIZACAO: Resultado comparação: $resultado');
      return resultado;
    } catch (e) {
      print('DEBUG SERV_ATUALIZACAO ERRO: $e');
      return false;
    }
  }

  /// Obtém o URL do APK mais recente
  static Future<String?> obterUrlApk() async {
    try {
      final resposta = await http.get(Uri.parse(_urlVersao)).timeout(const Duration(seconds: 15));
      if (resposta.statusCode != 200) return null;

      final dados = json.decode(resposta.body);
      return dados['url_apk'];
    } catch (e) {
      return null;
    }
  }

  /// Compara duas versões. Retorna 1 se v1 > v2, -1 se v1 < v2, 0 se iguais
  static int _compararVersoes(String v1, String v2) {
    try {
      final partes1 = v1.split('.').map(int.parse).toList();
      final partes2 = v2.split('.').map(int.parse).toList();

      for (int i = 0; i < partes1.length && i < partes2.length; i++) {
        if (partes1[i] > partes2[i]) return 1;
        if (partes1[i] < partes2[i]) return -1;
      }
      
      if (partes1.length > partes2.length) return 1;
      if (partes1.length < partes2.length) return -1;
      
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Abre o link do APK
  static Future<void> abrirDownload() async {
    final url = await obterUrlApk();
    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
}
