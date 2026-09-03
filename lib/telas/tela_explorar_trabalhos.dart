import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temas/cores_novo.dart';
import '../modelos/trabalhador_model.dart';
import '../provedores/estado_global.dart';
import '../widgets/tela_imagem_ampliada.dart';
import 'tela_perfil_novo.dart';
import 'tela_chat_novo.dart';
import 'tela_login_novo.dart';
import 'tela_cadastro_novo.dart';

class TelaExplorarTrabalhos extends StatelessWidget {
  final List<Map<String, dynamic>> itensGaleria;

  const TelaExplorarTrabalhos({super.key, required this.itensGaleria});

  void _mostrarDialogoLogin(BuildContext context, TrabalhadorModel trabalhador) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.person_add_alt_1, color: CoresNovo.navyPrimary, size: 48),
        title: const Text('Quase lá!', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Para veres o perfil completo de ${trabalhador.nomeTrabalhador}, precisas de uma conta. '
          'É grátis e rápido!',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: CoresNovo.textPrimary),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaCadastroNovo()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CoresNovo.starYellow,
                  foregroundColor: CoresNovo.navyPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                child: const Text('Criar Conta Grátis', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaLoginNovo()));
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: CoresNovo.navyPrimary,
                  side: const BorderSide(color: CoresNovo.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Já tenho conta', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CoresNovo.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CoresNovo.navyPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Explorar Trabalhos',
          style: TextStyle(color: CoresNovo.navyPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: itensGaleria.length,
        itemBuilder: (context, i) {
          final item = itensGaleria[i];
          final url = item['url'] as String;
          final t = item['trabalhador'] as TrabalhadorModel;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TelaImagemAmpliada(urlImagem: url)),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        url,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.nomeTrabalhador,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: CoresNovo.navyPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        t.profissaoTrabalhador,
                        style: const TextStyle(
                          fontSize: 11,
                          color: CoresNovo.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 32,
                              child: ElevatedButton(
                                onPressed: () {
                                  final estado = Provider.of<EstadoGlobal>(context, listen: false);
                                  if (!estado.estaLogado) {
                                    _mostrarDialogoLogin(context, t);
                                  } else {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => TelaPerfilNovo(trabalhador: t)));
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CoresNovo.blueLight,
                                  foregroundColor: CoresNovo.navyPrimary,
                                  padding: EdgeInsets.zero,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Perfil', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              final estado = Provider.of<EstadoGlobal>(context, listen: false);
                              if (!estado.estaLogado) {
                                _mostrarDialogoLogin(context, t);
                              } else {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => TelaChatNovo(trabalhador: t)));
                              }
                            },
                            child: Container(
                              height: 32,
                              width: 32,
                              decoration: BoxDecoration(
                                color: CoresNovo.navyPrimary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
