import 'package:flutter/material.dart';
import '../temas/cores_novo.dart';

class TelaImagemAmpliada extends StatelessWidget {
  final String urlImagem;

  const TelaImagemAmpliada({super.key, required this.urlImagem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            urlImagem,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const CircularProgressIndicator(color: CoresNovo.starYellow);
            },
          ),
        ),
      ),
    );
  }
}
