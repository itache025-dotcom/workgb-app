import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../provedores/estado_global.dart';
import '../../servicos/auth_service.dart';
import '../../servicos/supabase_service.dart';
import '../../modelos/trabalhador_model.dart';
import '../../temas/cores_novo.dart';
import '../../widgets/chip_novo.dart';
import '../../widgets/botao_novo.dart';
import '../tela_feed_novo.dart';
import '../tela_perfil_usuario_novo.dart';
import '../tela_editar_card.dart';
import '../tela_novo_card.dart';
import '../tela_imagem_ampliada.dart';
import 'dialogo_editar_perfil_novo.dart';
import 'dialogo_servico_novo.dart';

class TelaNegocioNovo extends StatefulWidget {
  const TelaNegocioNovo({super.key});

  @override
  State<TelaNegocioNovo> createState() => _TelaNegocioNovoState();
}

class _TelaNegocioNovoState extends State<TelaNegocioNovo> {
  final SupabaseService _supabaseService = SupabaseService();
  List<TrabalhadorModel> _cards = [];
  List<Map<String, dynamic>> _avaliacoes = [];
  int _totalVis = 0;
  int _totalCon = 0;
  bool _carregando = true;
  bool _carregandoFoto = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    await _carregarCards();
    await _carregarAvaliacoes();
    await _carregarEstatisticas();
  }

  Future<void> _carregarCards() async {
    setState(() => _carregando = true);

    try {
      final estado = Provider.of<EstadoGlobal>(context, listen: false);
      final usuario = estado.usuarioLogado;
      if (usuario != null) {
        final cards = await _supabaseService.meusCards(usuario.id);
        if (mounted) setState(() => _cards = cards);
      }
    } catch (e) {
      print('Erro ao carregar cards: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _carregarEstatisticas() async {
    try {
      if (_cards.isEmpty) return;
      final ids = _cards.map((c) => int.parse(c.id)).toList();
      final res = await _supabaseService.obterEstatisticas(ids);
      if (mounted) {
        setState(() {
          _totalVis = res['visualizacoes'] ?? 0;
          _totalCon = res['contactos'] ?? 0;
        });
      }
    } catch (e) {
      print('Erro ao carregar estatísticas: $e');
    }
  }

  Future<void> _carregarAvaliacoes() async {
    try {
      final estado = Provider.of<EstadoGlobal>(context, listen: false);
      final usuario = estado.usuarioLogado;
      if (usuario != null) {
        final lista = await _supabaseService.obterAvaliacoesPorProfissional(usuario.id);
        if (mounted) setState(() => _avaliacoes = lista);
      }
    } catch (e) {
      print('Erro ao carregar avaliações: $e');
    }
  }

  Future<void> _eliminarCard(TrabalhadorModel card) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar Card'),
        content: const Text('Tens a certeza que queres eliminar este card?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _supabaseService.eliminarCard(card.id);
        _carregarCards();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Card eliminado'), backgroundColor: CoresNovo.navyPrimary),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao eliminar'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _adicionarFotosGaleria() async {
    if (_cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cria primeiro um serviço para poderes adicionar fotos.')),
      );
      return;
    }

    final picker = ImagePicker();
    final fotos = await picker.pickMultiImage(imageQuality: 70);

    if (fotos.isNotEmpty) {
      setState(() => _carregandoFoto = true);
      try {
        final cardId = _cards.first.id;
        for (final foto in fotos) {
          final url = await _supabaseService.uploadFotoGaleria(File(foto.path));
          await _supabaseService.adicionarFotoGaleria(cardId, url);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${fotos.length} fotos adicionadas ao portfólio!'), backgroundColor: Colors.green),
          );
          _carregarCards();
        }
      } catch (e) {
        print('Erro ao adicionar fotos: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao carregar fotos.'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _carregandoFoto = false);
      }
    }
  }

  Future<void> _confirmarEliminarFoto(String url) async {
    final cardComFoto = _cards.firstWhere((c) => c.galeria.contains(url), orElse: () => _cards.first);

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar foto?'),
        content: const Text('Esta ação removerá a foto permanentemente do teu portfólio.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _supabaseService.removerFotoGaleria(cardComFoto.id, url);
        _carregarCards();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto removida.'), backgroundColor: CoresNovo.navyPrimary),
          );
        }
      } catch (e) {
        print('Erro ao eliminar foto: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = Provider.of<EstadoGlobal>(context);
    final usuario = estado.usuarioLogado;

    return Scaffold(
      backgroundColor: CoresNovo.background,
      appBar: AppBar(
        backgroundColor: CoresNovo.navyPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Meu Negócio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              color: CoresNovo.navyPrimary,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPanelTag(),
                      _buildSwitchModeButton(estado),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaPerfilUsuarioNovo()));
                        },
                        child: _buildAvatarWithVerifiedBadge(usuario?.nomeUsuario),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(usuario?.nomeUsuario ?? 'Braima Cassamá', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
                            const Text('Profissional • Bissau', style: TextStyle(fontSize: 12, color: Colors.white70)),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Estatísticas
                _buildStatsSection(),
                const SizedBox(height: 18),

                // Ações Rápidas
                _buildQuickActions(),
                const SizedBox(height: 18),

                // Serviços
                _buildServicesSection(),
                const SizedBox(height: 18),

                // Galeria
                _buildGallerySection(),
                const SizedBox(height: 18),

                // Avaliações
                _buildReviewsSection(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: CoresNovo.starYellow, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: const [
          Icon(Icons.storefront, size: 12, color: CoresNovo.navyPrimary),
          SizedBox(width: 4),
          Text('PAINEL PROFISSIONAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: CoresNovo.navyPrimary)),
        ],
      ),
    );
  }

  Widget _buildSwitchModeButton(EstadoGlobal estado) {
    return GestureDetector(
      onTap: () {
        if (estado.usuarioLogado != null) {
          estado.alternarModo();
          AuthService().atualizarModoUtilizacao(estado.usuarioLogado!.id, false);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const TelaFeedNovo()),
            (route) => false,
          );
        }
      },
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.5))),
        child: Row(
          children: const [
            Icon(Icons.swap_horiz, color: Colors.white, size: 14),
            SizedBox(width: 4),
            Text('Modo Cliente', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarWithVerifiedBadge(String? nome) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(color: CoresNovo.starYellow, shape: BoxShape.circle),
          child: CircleAvatar(
            radius: 30, 
            backgroundColor: Colors.white24,
            child: Text((nome != null && nome.isNotEmpty) ? nome.substring(0, 1).toUpperCase() : 'P', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        Positioned(
          bottom: 0, right: 0,
          child: Container(
            height: 20, width: 20,
            decoration: const BoxDecoration(color: CoresNovo.success, shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Colors.white, size: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Estatisticas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: CoresNovo.navyPrimary)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildStatMiniCard(Icons.visibility_outlined, '$_totalVis', 'Visualizações', const Color(0xFF2563EB))),
            const SizedBox(width: 8),
            Expanded(child: _buildStatMiniCard(Icons.chat_outlined, '$_totalCon', 'Contactos', CoresNovo.success)),
            const SizedBox(width: 8),
            Expanded(child: _buildStatMiniCard(Icons.star, '${_avaliacoes.length}', 'Avaliações', const Color(0xFFD97706))),
            const SizedBox(width: 8),
            Expanded(child: _buildStatMiniCard(Icons.speed_outlined, '98%', 'Taxa Resp.', const Color(0xFF7C3AED))),
          ],
        ),
      ],
    );
  }

  Widget _buildStatMiniCard(IconData icon, String val, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: CoresNovo.border)),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 2),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: CoresNovo.navyPrimary)),
          Text(label, style: const TextStyle(fontSize: 9, color: CoresNovo.textSecondary), maxLines: 1),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: CoresNovo.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ações Rápidas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: CoresNovo.navyPrimary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildActionBtn(Icons.rocket_launch, 'Impulsionar', const Color(0xFFD97706))),
              const SizedBox(width: 8),
              Expanded(child: _buildActionBtnOutlined(Icons.preview, 'Ver Perfil Público')),
              const SizedBox(width: 8),
              _buildShareBtn(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, Color color) {
    return Container(
      height: 40,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionBtnOutlined(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => TelaFeedNovo(mostrarBottomNav: false)));
      },
      child: Container(
        height: 40,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: CoresNovo.navyPrimary)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.preview, color: CoresNovo.navyPrimary, size: 14),
            const SizedBox(width: 4),
            const Text('Ver Perfil Público', style: TextStyle(color: CoresNovo.navyPrimary, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildShareBtn() {
    return Container(
      height: 40, width: 40,
      decoration: BoxDecoration(color: CoresNovo.blueContainer, borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.share, color: CoresNovo.navyPrimary, size: 18),
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Meus Serviços (${_cards.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: CoresNovo.navyPrimary)),
                const Text('Plano Pro: Serviços ilimitados', style: TextStyle(fontSize: 11, color: CoresNovo.textSecondary)),
              ],
            ),
            _buildAddBtn('+ Adicionar Serviço'),
          ],
        ),
        const SizedBox(height: 8),
        if (_carregando)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
        else if (_cards.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Ainda não tens serviços cadastrados.', style: TextStyle(color: CoresNovo.textSecondary))))
        else
          ..._cards.map((card) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildServiceCard(card),
          )).toList(),
      ],
    );
  }

  Widget _buildAddBtn(String label) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaNovoCard())).then((_) => _carregarCards());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: CoresNovo.navyPrimary, borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildServiceCard(TrabalhadorModel card) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: CoresNovo.border)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8), 
            child: card.fotoTrabalhador != null && card.fotoTrabalhador!.isNotEmpty
              ? Image.network(card.fotoTrabalhador!, width: 60, height: 60, fit: BoxFit.cover)
              : Container(width: 60, height: 60, color: CoresNovo.blueLight, child: Center(child: Text((card.nomeTrabalhador.isNotEmpty ? card.nomeTrabalhador.substring(0,1) : 'P').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(card.nomeTrabalhador, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: CoresNovo.navyPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    _buildActiveBadge(true),
                  ],
                ),
                Text('${card.profissaoTrabalhador} • Preço sob consulta', style: const TextStyle(fontSize: 11, color: CoresNovo.textSecondary)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Ativo no marketplace', style: TextStyle(fontSize: 10, color: CoresNovo.textSecondary)),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TelaEditarCard(card: card))).then((_) => _carregarCards()),
                          child: const Icon(Icons.edit, size: 16, color: CoresNovo.navyPrimary),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _eliminarCard(card),
                          child: const Icon(Icons.delete, size: 16, color: CoresNovo.error),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBadge(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: (active ? CoresNovo.success : const Color(0xFFD97706)).withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
      child: Text(active ? 'Ativo' : 'Pausado', style: TextStyle(color: active ? CoresNovo.success : const Color(0xFFD97706), fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildGallerySection() {
    final todasFotos = _cards.expand((c) => c.galeria).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Portfólio & Galeria (${todasFotos.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: CoresNovo.navyPrimary)),
            _buildAddOutlinedBtn('+ Adicionar Fotos', onTap: _carregandoFoto ? null : _adicionarFotosGaleria),
          ],
        ),
        const SizedBox(height: 8),
        if (_carregando)
          const Center(child: CircularProgressIndicator())
        else if (todasFotos.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Ainda não tens fotos no portfólio.', style: TextStyle(color: CoresNovo.textSecondary))))
        else
          SizedBox(
            height: 105,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: todasFotos.length,
              itemBuilder: (context, i) => _buildPortfolioItem(todasFotos[i]),
            ),
          ),
      ],
    );
  }

  Widget _buildAddOutlinedBtn(String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: CoresNovo.navyPrimary)),
        child: _carregandoFoto 
          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
          : Text(label, style: const TextStyle(color: CoresNovo.navyPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPortfolioItem(String url) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => TelaImagemAmpliada(urlImagem: url)));
          },
          child: Container(
            width: 120,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(10), 
              border: Border.all(color: CoresNovo.border),
              image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
            ),
          ),
        ),
        Positioned(
          top: 5,
          right: 15,
          child: GestureDetector(
            onTap: () => _confirmarEliminarFoto(url),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.delete, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Avaliações dos Clientes (${_avaliacoes.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: CoresNovo.navyPrimary)),
        const SizedBox(height: 8),
        if (_avaliacoes.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Ainda não tens avaliações.', style: TextStyle(color: CoresNovo.textSecondary))))
        else
          ..._avaliacoes.map((av) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildReviewCard(av),
          )).toList(),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> av) {
    final nome = (av['utilizadores'] != null) 
        ? av['utilizadores']['nome_usuario'] 
        : (av['nome_avaliador'] ?? 'Utilizador');
    final comentario = av['comentario'] ?? '';
    final resposta = av['resposta'];
    final estrelas = (av['estrelas'] as num?)?.toDouble() ?? 5.0;
    final id = av['id'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: CoresNovo.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: CoresNovo.navyPrimary)),
              EstrelasAvaliacaoNovo(nota: estrelas, starSize: 12),
            ],
          ),
          const SizedBox(height: 6),
          Text(comentario, style: const TextStyle(fontSize: 12, color: CoresNovo.textPrimary)),
          if (resposta != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: CoresNovo.blueContainer.withOpacity(0.6), borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: const [Icon(Icons.reply, size: 12, color: CoresNovo.navyPrimary), SizedBox(width: 4), Text('Sua Resposta Pública:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: CoresNovo.navyPrimary))]),
                  Text(resposta, style: const TextStyle(fontSize: 11, color: CoresNovo.textPrimary)),
                ],
              ),
            ),
          ] else
            TextButton(
              onPressed: () {
                _mostrarDialogoResposta(id);
              }, 
              child: const Text('Responder a esta avaliação', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CoresNovo.blueSecondary))
            ),
        ],
      ),
    );
  }

  void _mostrarDialogoResposta(int avaliacaoId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Responder Avaliação', style: TextStyle(fontWeight: FontWeight.bold, color: CoresNovo.navyPrimary)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Escreve a tua resposta pública...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await _supabaseService.responderAvaliacao(avaliacaoId: avaliacaoId, resposta: controller.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
              _carregarAvaliacoes();
            },
            style: ElevatedButton.styleFrom(backgroundColor: CoresNovo.navyPrimary),
            child: const Text('Enviar Resposta', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
