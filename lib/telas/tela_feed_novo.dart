import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedores/estado_global.dart';
import '../servicos/auth_service.dart';
import '../servicos/supabase_service.dart';
import '../modelos/trabalhador_model.dart';
import '../temas/cores_novo.dart';
import '../widgets/chip_novo.dart';
import '../widgets/bottom_nav_novo.dart';
import 'tela_perfil_novo.dart';
import 'tela_login_novo.dart';
import 'tela_chat_novo.dart';
import 'tela_cadastro_novo.dart';
import 'tela_perfil_usuario_novo.dart';
import 'tela_conversas_novo.dart';
import 'professional/tela_dashboard_novo.dart';
import 'professional/tela_tornar_pro_novo.dart';
import '../widgets/tela_imagem_ampliada.dart';
import 'tela_explorar_trabalhos.dart';
import 'tela_destaques.dart';
import 'tela_pesquisa_novo.dart';

class TelaFeedNovo extends StatefulWidget {
  final bool mostrarBottomNav;

  const TelaFeedNovo({super.key, this.mostrarBottomNav = true});

  @override
  State<TelaFeedNovo> createState() => _TelaFeedNovoState();
}

class _TelaFeedNovoState extends State<TelaFeedNovo> {
  int _currentIndex = 0;
  bool _carregando = true;
  String? _erro;
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarTrabalhadores();
    });
  }

  Future<void> _carregarTrabalhadores() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final estado = Provider.of<EstadoGlobal>(context, listen: false);
      final usuario = estado.usuarioLogado;
      
      final trabalhadores = await _supabaseService.listarTrabalhadores(
        lat: usuario?.lat ?? 0.0,
        lng: usuario?.lng ?? 0.0,
      );

      if (mounted) {
        estado.definirListaTrabalhadores(trabalhadores);
      }
    } catch (e) {
      print('Erro ao carregar trabalhadores: $e');
      if (mounted) {
        final erroStr = e.toString();
        if (erroStr.contains('SocketException') || 
            erroStr.contains('Failed host lookup') ||
            erroStr.contains('No address associated')) {
          setState(() => _erro = 'offline');
        } else {
          setState(() => _erro = 'erro');
        }
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  List<Map<String, dynamic>> _extrairFotosGaleria(List<TrabalhadorModel> trabalhadores) {
    final fotos = <Map<String, dynamic>>[];
    for (final t in trabalhadores) {
      for (final foto in t.galeria) {
        fotos.add({
          'url': foto,
          'trabalhador': t,
        });
      }
    }
    return fotos;
  }

  String _extrairBairro(String descricao) {
    final match = RegExp(r'📍 Bairro:\s*(.+)').firstMatch(descricao);
    return match?.group(1)?.trim() ?? 'Bissau';
  }

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
                  Navigator.push(context, MaterialPageRoute(builder: (_) => TelaCadastroNovo()));
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
                  Navigator.push(context, MaterialPageRoute(builder: (_) => TelaLoginNovo()));
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: CoresNovo.navyPrimary,
                  side: const BorderSide(color: CoresNovo.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Já tenho conta', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Agora não', style: TextStyle(color: CoresNovo.textSecondary)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'Sem conexão à internet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CoresNovo.navyPrimary),
            ),
            const SizedBox(height: 12),
            const Text(
              'Verifica a tua ligação e tenta novamente para carregar os serviços.',
              textAlign: TextAlign.center,
              style: TextStyle(color: CoresNovo.textSecondary),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _carregarTrabalhadores,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CoresNovo.navyPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Tentar novamente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterleavedProfessionalGrid(List<TrabalhadorModel> trabalhadores) {
    if (trabalhadores.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20),
        child: Text('Nenhum trabalhador encontrado com estes filtros.', style: TextStyle(color: CoresNovo.textSecondary)),
      ));
    }

    List<Widget> gridItems = [];
    for (int i = 0; i < trabalhadores.length; i += 10) {
      int end = (i + 10 < trabalhadores.length) ? i + 10 : trabalhadores.length;
      List<TrabalhadorModel> chunk = trabalhadores.sublist(i, end);
      
      gridItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: chunk.length,
            itemBuilder: (context, index) => _buildProfessionalCard(chunk[index]),
          ),
        ),
      );
      
      if (end < trabalhadores.length) {
        gridItems.add(const SizedBox(height: 24));
        gridItems.add(_buildBecomeProBanner());
        gridItems.add(const SizedBox(height: 24));
      }
    }

    return Column(children: gridItems);
  }

  @override
  Widget build(BuildContext context) {
    final estado = Provider.of<EstadoGlobal>(context);
    final trabalhadores = estado.listaTrabalhadores;

    final trabalhadoresDescoberta = [...trabalhadores]
      ..sort((a, b) => b.mediaAvaliacoes.compareTo(a.mediaAvaliacoes));

    return Scaffold(
      backgroundColor: CoresNovo.background,
      appBar: widget.mostrarBottomNav 
        ? AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            title: Row(
              children: const [
                Text('Lirify', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: CoresNovo.navyPrimary)),
              ],
            ),
            actions: [
              _buildActionIcon(Icons.search, TelaPesquisaNovo()),
              _buildActionIcon(Icons.chat_bubble_outline, TelaConversasNovo(), badgeCount: estado.totalConversasNaoLidas),
              _buildActionIcon(Icons.person_outline, estado.estaLogado ? TelaPerfilUsuarioNovo() : TelaTornarProNovo()),
              const SizedBox(width: 8),
            ],
          )
        : AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: CoresNovo.navyPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Ver Trabalhadores', style: TextStyle(color: CoresNovo.navyPrimary, fontWeight: FontWeight.bold)),
          ),
      bottomNavigationBar: widget.mostrarBottomNav 
        ? BottomNavNovo(
            currentIndex: _currentIndex,
            onTap: (i) {
              setState(() => _currentIndex = i);
              if (i == 1) {
                // Pesquisa
                Navigator.push(context, MaterialPageRoute(builder: (_) => TelaPesquisaNovo()));
              } else if (i == 2) {
                // Conversas
                Navigator.push(context, MaterialPageRoute(builder: (_) => TelaConversasNovo()));
              } else if (i == 3) {
                // Perfil do Utilizador
                Navigator.push(context, MaterialPageRoute(builder: (_) => estado.estaLogado ? TelaPerfilUsuarioNovo() : TelaTornarProNovo()));
              }
            },
            unreadMessages: estado.totalConversasNaoLidas,
          )
        : null,
      body: _erro == 'offline' 
        ? _buildOfflineView()
        : ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
          const SizedBox(height: 8),
          
          // Banner de Alternância de Modo (Rápido)
          if (estado.estaLogado)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GestureDetector(
                onTap: () {
                  final novoModo = !estado.modoProfissional;
                  estado.alternarModo();
                  AuthService().atualizarModoUtilizacao(estado.usuarioLogado!.id, novoModo);
                  
                  if (novoModo) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => TelaDashboardNovo()),
                      (r) => false,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CoresNovo.blueLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: CoresNovo.navyPrimary.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.swap_horiz, color: CoresNovo.navyPrimary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Modo Cliente Ativo',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: CoresNovo.navyPrimary),
                            ),
                            Text(
                              'Tocar para mudar para Painel Profissional',
                              style: TextStyle(fontSize: 11, color: CoresNovo.navyPrimary.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: CoresNovo.navyPrimary, size: 20),
                    ],
                  ),
                ),
              ),
            ),

          // Secção Explorar Trabalhos (Galeria Pública)
          _buildSectionHeader(
            'Explorar Trabalhos', 
            'Ver tudo',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TelaExplorarTrabalhos(itensGaleria: _extrairFotosGaleria(trabalhadores)),
                ),
              );
            }
          ),
          const SizedBox(height: 12),
          _carregando 
            ? const Center(child: CircularProgressIndicator())
            : _buildExploreWorksSection(_extrairFotosGaleria(trabalhadores)),
          const SizedBox(height: 24),

          // Secção Descobrir Trabalhos
          _buildSectionHeader(
            'Descobrir Trabalhos', 
            'Em destaque',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TelaDestaques()),
              );
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: trabalhadoresDescoberta.length > 5 ? 5 : trabalhadoresDescoberta.length,
              itemBuilder: (context, index) {
                final t = trabalhadoresDescoberta[index];
                return _buildDiscoverCard(t, t.mediaAvaliacoes.toStringAsFixed(1));
              },
            ),
          ),
          const SizedBox(height: 24),

          // Secção Profissionais
          _buildSectionHeader('Profissionais', '${trabalhadores.length} disponíveis'),
          const SizedBox(height: 12),
          _carregando 
            ? const Center(child: CircularProgressIndicator())
            : _buildInterleavedProfessionalGrid(trabalhadores),
          const SizedBox(height: 24),

          // Banner Pro Final (Apenas se houver poucos profissionais ou nenhum)
          if (trabalhadores.length <= 10) ...[
            _buildBecomeProBanner(),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildExploreWorksSection(List<Map<String, dynamic>> itensGaleria) {
    if (itensGaleria.isEmpty) {
      return const Center(
        child: Text('Nenhum trabalho na galeria ainda.', style: TextStyle(color: CoresNovo.textSecondary, fontSize: 13)),
      );
    }

    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: itensGaleria.length,
        itemBuilder: (context, i) {
          final item = itensGaleria[i];
          final url = item['url'] as String;
          final t = item['trabalhador'] as TrabalhadorModel;

          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TelaImagemAmpliada(urlImagem: url),
                      ),
                    );
                  },
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(url),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    t.nomeTrabalhador,
                    style: const TextStyle(
                      color: CoresNovo.navyPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 28,
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
                          child: const Text('Perfil', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: SizedBox(
                        height: 28,
                        child: ElevatedButton(
                        onPressed: () {
                          final estado = Provider.of<EstadoGlobal>(context, listen: false);
                          if (!estado.estaLogado) {
                            _mostrarDialogoLogin(context, t);
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => TelaChatNovo(trabalhador: t)));
                          }
                        },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CoresNovo.navyPrimary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Chat', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Widget target, {int badgeCount = 0}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        icon: badgeCount > 0 
          ? Badge(
              label: Text('$badgeCount', style: const TextStyle(fontSize: 10)),
              backgroundColor: CoresNovo.navyPrimary,
              child: Icon(icon, color: CoresNovo.textSecondary),
            )
          : Icon(icon, color: CoresNovo.textSecondary),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => target));
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CoresNovo.navyPrimary)),
          GestureDetector(
            onTap: onTap,
            child: Text(subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: CoresNovo.blueSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverCard(TrabalhadorModel t, String rating) {
    final fotoUrl = t.fotoTrabalhador != null && t.fotoTrabalhador!.isNotEmpty 
        ? t.fotoTrabalhador! 
        : (t.galeria.isNotEmpty ? t.galeria.first : 'https://via.placeholder.com/140x180');

    return GestureDetector(
      onTap: () {
        final estado = Provider.of<EstadoGlobal>(context, listen: false);
        if (!estado.estaLogado) {
          _mostrarDialogoLogin(context, t);
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => TelaPerfilNovo(trabalhador: t)));
        }
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(fotoUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 8, right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(6)),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: CoresNovo.starYellow, size: 10),
                    const SizedBox(width: 2),
                    Text(rating, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 10, left: 10, right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.profissaoTrabalhador, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), maxLines: 2),
                  const SizedBox(height: 2),
                  Text(t.nomeTrabalhador, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 10), maxLines: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalCard(TrabalhadorModel t) {
    final bairro = _extrairBairro(t.descricaoTrabalhador ?? '');
    
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
        elevation: 2.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
                  const SizedBox(height: 6),
                  TagProfissaoNovo(profissao: t.profissaoTrabalhador),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: CoresNovo.textSecondary),
                      const SizedBox(width: 3),
                      Expanded(child: Text(bairro, style: const TextStyle(fontSize: 11, color: CoresNovo.textSecondary), maxLines: 1)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  EstrelasAvaliacaoNovo(
                    nota: t.mediaAvaliacoes, 
                    totalAvaliacoes: t.totalAvaliacoes, 
                    starSize: 13, 
                    textSize: 12
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBecomeProBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CoresNovo.navyPrimary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: CoresNovo.starYellow, shape: BoxShape.circle),
                child: const Icon(Icons.storefront, color: CoresNovo.navyPrimary, size: 18),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('É Profissional em Bissau?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('Receba orçamentos e novos clientes', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Cadastre os seus serviços no Lirify, mostre fotos do seu trabalho e responda aos clientes diretamente pelo WhatsApp ou Chat.',
            style: TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => TelaTornarProNovo()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: CoresNovo.starYellow, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Aceder ao Painel do Profissional', style: TextStyle(color: CoresNovo.navyPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
