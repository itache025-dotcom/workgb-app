import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temas/cores_novo.dart';
import '../modelos/trabalhador_model.dart';
import '../servicos/supabase_service.dart';
import '../provedores/estado_global.dart';
import '../widgets/chip_novo.dart';
import 'tela_perfil_novo.dart';
import 'tela_login_novo.dart';
import 'tela_cadastro_novo.dart';

class TelaDestaques extends StatefulWidget {
  const TelaDestaques({super.key});

  @override
  State<TelaDestaques> createState() => _TelaDestaquesState();
}

class _TelaDestaquesState extends State<TelaDestaques> {
  final SupabaseService _supabaseService = SupabaseService();
  List<TrabalhadorModel> _destaques = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDestaques();
  }

  Future<void> _carregarDestaques() async {
    setState(() => _carregando = true);
    try {
      final estado = Provider.of<EstadoGlobal>(context, listen: false);
      final usuario = estado.usuarioLogado;
      
      final trabalhadores = await _supabaseService.listarTrabalhadores(
        lat: usuario?.lat ?? 0.0,
        lng: usuario?.lng ?? 0.0,
      );

      // Critério: Mostrar TODOS os profissionais ordenados por média
      // (As médias já vêm carregadas do listarTrabalhadores otimizado)
      final filtrados = [...trabalhadores]
        ..sort((a, b) => b.mediaAvaliacoes.compareTo(a.mediaAvaliacoes));

      if (mounted) {
        setState(() {
          _destaques = filtrados;
          _carregando = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar destaques: $e');
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _mostrarDialogoLogin(BuildContext context, TrabalhadorModel trabalhador) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.person_add_alt_1, color: CoresNovo.navyPrimary, size: 48),
        title: const Text('Quase lá!', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Para veres o perfil completo de ${trabalhador.nomeTrabalhador}, precisas de uma conta.',
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
                  Navigator.push(context, MaterialPageRoute(builder: (_) => TelaCadastroNovo()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CoresNovo.starYellow,
                  foregroundColor: CoresNovo.navyPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Criar Conta Grátis', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => TelaLoginNovo()));
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: CoresNovo.navyPrimary,
                  side: const BorderSide(color: CoresNovo.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        title: const Text('Profissionais em Destaque', style: TextStyle(color: CoresNovo.navyPrimary, fontWeight: FontWeight.bold)),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _destaques.isEmpty
              ? const Center(child: Text('Nenhum profissional em destaque no momento.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: _destaques.length,
                  itemBuilder: (context, index) => _buildProfessionalCard(_destaques[index]),
                ),
    );
  }

  Widget _buildProfessionalCard(TrabalhadorModel t) {
    return GestureDetector(
      onTap: () {
        final estado = Provider.of<EstadoGlobal>(context, listen: false);
        if (!estado.estaLogado) {
          _mostrarDialogoLogin(context, t);
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => TelaPerfilNovo(trabalhador: t)));
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: t.fotoTrabalhador != null && t.fotoTrabalhador!.isNotEmpty
                    ? Image.network(t.fotoTrabalhador!, fit: BoxFit.cover, width: double.infinity)
                    : Container(
                        color: CoresNovo.blueLight,
                        child: Center(
                          child: Text(
                            (t.nomeTrabalhador.isNotEmpty ? t.nomeTrabalhador.substring(0, 1) : 'P').toUpperCase(),
                            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: CoresNovo.navyPrimary),
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.nomeTrabalhador, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: CoresNovo.navyPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  TagProfissaoNovo(profissao: t.profissaoTrabalhador),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: CoresNovo.starYellow, size: 14),
                          const SizedBox(width: 2),
                          Text(t.mediaAvaliacoes.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text('(${t.totalAvaliacoes})', style: const TextStyle(fontSize: 11, color: CoresNovo.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
