import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

/// Tela para visualização de imagem em tela cheia com zoom
class TelaImagemAmpliada extends StatelessWidget {
  final String urlImagem;

  const TelaImagemAmpliada({super.key, required this.urlImagem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(urlImagem),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          loadingBuilder: (context, event) => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Text(
              'Erro ao carregar imagem',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
