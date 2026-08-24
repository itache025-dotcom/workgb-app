import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Serviço para comprimir imagens antes do upload
class ImagemService {
  /// Comprime uma imagem para reduzir o tamanho
  /// Retorna o caminho do ficheiro comprimido
  static Future<File?> comprimirImagem(File imagem) async {
    try {
      final caminhoComprimido = imagem.path.replaceFirst(
        RegExp(r'\.\w+$'),
        '_comprimida.jpg',
      );

      final resultado = await FlutterImageCompress.compressAndGetFile(
        imagem.path,
        caminhoComprimido,
        quality: 70, // Qualidade de 0 a 100 (70 = boa qualidade)
        minWidth: 600, // Largura máxima
        minHeight: 600, // Altura máxima
        format: CompressFormat.jpeg,
      );

      // No flutter_image_compress 2.x, compressAndGetFile retorna um XFile?
      // Precisamos converter para File se não for nulo
      if (resultado == null) return imagem;
      return File(resultado.path);
    } catch (e) {
      // Se falhar, retorna a imagem original
      return imagem;
    }
  }
}
