import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ServicoAudio {
  final FlutterSoundRecorder _gravador = FlutterSoundRecorder();
  String? _caminhoAtual;
  bool _isRecorderInitialized = false;

  Future<void> _init() async {
    if (_isRecorderInitialized) return;
    await _gravador.openRecorder();
    _isRecorderInitialized = true;
  }

  Future<bool> temPermissao() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> iniciarGravacao() async {
    try {
      if (!await temPermissao()) {
        print('DEBUG AUDIO: Sem permissão de microfone');
        return false;
      }

      await _init();

      final diretorio = await getApplicationDocumentsDirectory();
      _caminhoAtual = '${diretorio.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      print('DEBUG AUDIO: Iniciando gravação em $_caminhoAtual');
      
      await _gravador.startRecorder(
        toFile: _caminhoAtual!,
        codec: Codec.aacMP4,
      );

      return true;
    } catch (e) {
      print('DEBUG AUDIO: Erro ao iniciar gravação: $e');
      return false;
    }
  }

  Future<String?> pararGravacao() async {
    try {
      print('DEBUG AUDIO: Parando gravação...');
      if (!_isRecorderInitialized) return null;
      
      final caminho = await _gravador.stopRecorder();
      final pathFinal = caminho ?? _caminhoAtual;
      
      if (pathFinal != null) {
        final ficheiro = File(pathFinal);
        if (await ficheiro.exists()) {
          print('DEBUG AUDIO: Gravado com sucesso: $pathFinal (${await ficheiro.length()} bytes)');
          return pathFinal;
        }
      }
      return null;
    } catch (e) {
      print('DEBUG AUDIO: Erro ao parar gravação: $e');
      return null;
    }
  }

  void dispose() {
    if (_isRecorderInitialized) {
      _gravador.closeRecorder();
    }
  }
}
