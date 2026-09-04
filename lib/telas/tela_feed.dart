import 'package:flutter/material.dart';
import 'tela_novo_card.dart';
import 'package:provider/provider.dart';
import '../provedores/estado_global.dart';
import '../modelos/trabalhador_model.dart';
import '../servicos/supabase_service.dart';
import 'tela_perfil.dart';
import 'tela_perfil_usuario.dart';
import 'tela_login.dart';
import 'tela_painel_profissional.dart';
import 'tela_conversas.dart';
import '../servicos/responsividade.dart';
import 'tela_imagem_ampliada.dart';
import 'tela_video_player.dart';

final SupabaseService _supabaseService = SupabaseService();

/// Tela principal do WorkGB - Feed de trabalhadores estilo Pinterest
/// Mostra grid de cards com foto (placeholder), nome e profissão
class TelaFeed extends StatefulWidget {
  const TelaFeed({super.key});

  @override
  State<TelaFeed> createState() => _TelaFeedState();
}

class _TelaFeedState extends State<TelaFeed> {
  bool _carregando = true;
  String? _erro;
  String _termoPesquisa = '';
  String _profissaoFiltro = 'Todas';
  String _bairroFiltro = 'Todos';

  List<String> _extrairProfissoesUnicas(List<TrabalhadorModel> trabalhadores) {
    final profissoes = <String>{};

    // Adicionar profissões predefinidas
    profissoes.addAll([
      'Canalizador',
      'Eletricista',
      'Motorista',
      'Cozinheira',
      'Cabeleireira',
      'Pintor',
      'Costureira',
      'Babá',
      'Jardineiro',
      'Lavadeira',
    ]);

    // Extrair profissões personalizadas
    for (final t in trabalhadores) {
      if (t.profissaoTrabalhador.isNotEmpty) {
        profissoes.add(t.profissaoTrabalhador);
      }
    }

    return profissoes.toList()..sort();
  }

  List<String> _extrairBairrosUnicos(List<TrabalhadorModel> trabalhadores) {
    final bairros = <String>{};

    // Adicionar bairros predefinidos
    bairros.addAll([
      'Bairro Militar',
      'Belém',
      'Quelélé',
      'Luanda',
      'Bairro de Ajuda',
      'Antula',
      'Bissalanca',
      'Cuntum',
      'Pefine',
      'Cupelom',
    ]);

    // Extrair bairros personalizados das descrições
    for (final t in trabalhadores) {
      final bairro = _extrairBairro(t.descricaoTrabalhador ?? '');
      if (bairro.isNotEmpty && bairro != 'Bissau') {
        bairros.add(bairro);
      }
    }

    return bairros.toList()..sort();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarTrabalhadores();
      _atualizarBadgeConversas();
    });
  }

  Future<void> _atualizarBadgeConversas() async {
    final estado = Provider.of<EstadoGlobal>(context, listen: false);
    if (!estado.estaLogado) return;

    final usuario = estado.usuarioLogado!;
    // Busca o total atualizado no servidor (Universal: Cliente ou Profissional)
    final total = await _supabaseService.obterTotalConversasNaoLidas(usuario.id);
    
    if (mounted) {
      estado.atualizarTotalConversas(total);
    }
  }

  /// Carrega os trabalhadores do backend
  Future<void> _carregarTrabalhadores() async {
    print('DEBUG: Iniciando carregamento de trabalhadores...');
    
    // Pequena tolerância para garantir que o contexto/sessão estão estáveis
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final estado = Provider.of<EstadoGlobal>(context, listen: false);
      final usuario = estado.usuarioLogado;
      print('DEBUG: Usuário logado: ${usuario?.nomeUsuario ?? "Nenhum"} (ID: ${usuario?.id ?? "N/A"})');

      // Chamada ao serviço com tratamento de erro interno
      final trabalhadores = await _supabaseService.listarTrabalhadores(
        lat: usuario?.lat ?? 0.0,
        lng: usuario?.lng ?? 0.0,
      );

      print('DEBUG: ${trabalhadores.length} trabalhadores carregados com sucesso');
      
      if (mounted) {
        estado.definirListaTrabalhadores(trabalhadores);
        // Também atualiza os badges caso o utilizador tenha logado recentemente
        _atualizarBadgeConversas();
      }
    } catch (e) {
      print('ERRO EXATO EM _carregarTrabalhadores: $e');
      print('ERRO TIPO: ${e.runtimeType}');
      
      if (mounted) {
        setState(() {
          _erro = 'Erro ao carregar trabalhadores. Verifique a sua ligação ou permissões.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = Provider.of<EstadoGlobal>(context);
    final usuario = estado.usuarioLogado;
    final trabalhadores = estado.listaTrabalhadores;
    
    final profissoesDisponiveis = _extrairProfissoesUnicas(trabalhadores);
    final bairrosDisponiveis = _extrairBairrosUnicos(trabalhadores);
    
    // Garantir que os filtros selecionados ainda existem na lista
    if (_profissaoFiltro != 'Todas' && !profissoesDisponiveis.contains(_profissaoFiltro)) {
      _profissaoFiltro = 'Todas';
    }
    if (_bairroFiltro != 'Todos' && !bairrosDisponiveis.contains(_bairroFiltro)) {
      _bairroFiltro = 'Todos';
    }

    final trabalhadoresFiltrados = trabalhadores.where((t) {
      final termo = _termoPesquisa.toLowerCase();
      final matchPesquisa = _termoPesquisa.isEmpty ||
          t.nomeTrabalhador.toLowerCase().contains(termo) ||
          t.profissaoTrabalhador.toLowerCase().contains(termo) ||
          (t.descricaoTrabalhador ?? '').toLowerCase().contains(termo);

      final matchProfissao = _profissaoFiltro == 'Todas' ||
          t.profissaoTrabalhador == _profissaoFiltro;

      final matchBairro = _bairroFiltro == 'Todos' ||
          _extrairBairro(t.descricaoTrabalhador ?? '') == _bairroFiltro;

      return matchPesquisa && matchProfissao && matchBairro;
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'WorkGB',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        shadowColor: const Color(0xFF2563EB).withOpacity(0.1),
        actions: [
          Consumer<EstadoGlobal>(
            builder: (context, estado, child) {
              print('DEBUG UI: Badge total no Feed: ${estado.totalConversasNaoLidas}');
              return Badge(
                label: Text('${estado.totalConversasNaoLidas}'),
                isLabelVisible: estado.totalConversasNaoLidas > 0,
                child: IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF2563EB)),
                  tooltip: 'Minhas Conversas',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TelaConversas()),
                    ).then((_) {
                      // Recalcular ao voltar da tela de conversas caso tenha lido algo
                      if (estado.estaLogado) {
                        _atualizarBadgeConversas();
                      }
                    });
                  },
                ),
              );
            },
          ),
          if (estado.estaLogado) ...[
            if (usuario?.tipoUsuario == 'profissional')
              IconButton(
                icon: const Icon(Icons.dashboard_outlined,
                    color: Color(0xFF2563EB)),
                tooltip: 'Painel',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TelaPainelProfissional()),
                  );
                },
              ),
            IconButton(
              icon: const Icon(Icons.account_circle, color: Color(0xFF2563EB)),
              tooltip: 'Meu Perfil',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TelaPerfilUsuario()),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  usuario?.nomeUsuario.split(' ')[0] ?? 'Utilizador',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TelaLogin(tipoLogin: 'profissional'),
                    ),
                  );
                },
                icon: const Icon(Icons.business_center, size: 18),
                label: const Text('Profissional?',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: (estado.estaLogado && usuario?.tipoUsuario == 'profissional')
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TelaNovoCard()),
                ).then((_) {
                  _carregarTrabalhadores();
                });
              },
              backgroundColor: const Color(0xFF2563EB),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Criar Card',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            )
          : (!estado.estaLogado || (estado.estaLogado && usuario?.tipoUsuario == 'cliente'))
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TelaLogin(tipoLogin: 'profissional'),
                      ),
                    );
                  },
                  backgroundColor: const Color(0xFF2563EB),
                  icon: const Icon(Icons.star, color: Colors.white),
                  label: const Text(
                    'Tornar-se Profissional',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                )
              : null,
      body: _carregando
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFF2563EB)),
      )
          : _erro != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(_erro!, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarTrabalhadores,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
              ),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      )
          : trabalhadores.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Nenhum trabalhador disponível', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _carregarTrabalhadores,
        color: const Color(0xFF2563EB),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    onChanged: (valor) {
                      setState(() => _termoPesquisa = valor);
                    },
                    decoration: InputDecoration(
                      hintText: 'Pesquisar por profissão, bairro ou nome...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF2563EB)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _profissaoFiltro,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Profissão',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: 'Todas',
                              child: Text(
                                'Todas',
                                style: TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            ...profissoesDisponiveis.map((p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(
                                    p,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                )),
                          ],
                          onChanged: (v) => setState(() => _profissaoFiltro = v!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _bairroFiltro,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Bairro',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: 'Todos',
                              child: Text(
                                'Todos',
                                style: TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            ...bairrosDisponiveis.map((b) => DropdownMenuItem(
                                  value: b,
                                  child: Text(
                                    b,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                )),
                          ],
                          onChanged: (v) => setState(() => _bairroFiltro = v!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsividade.larguraMaxima(context),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: Responsividade.paddingHorizontal(context)),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: Responsividade.numeroColunas(context),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: trabalhadoresFiltrados.length,
                      itemBuilder: (context, index) {
                        return _buildCardTrabalhador(trabalhadoresFiltrados[index]);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Abre a mídia (imagem ou vídeo) em tela cheia
  void _abrirMidia(String url) {
    final uri = url.toLowerCase();
    if (uri.endsWith('.mp4') || uri.endsWith('.mov') || uri.endsWith('.avi')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TelaVideoPlayer(urlVideo: url)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TelaImagemAmpliada(urlImagem: url)),
      );
    }
  }

  /// Constrói um card de trabalhador estilo Pinterest
  Widget _buildCardTrabalhador(TrabalhadorModel trabalhador) {
    return GestureDetector(
      onTap: () {
        final estado = Provider.of<EstadoGlobal>(context, listen: false);

        if (!estado.estaLogado) {
          // Redirecionar para login de cliente
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TelaLogin(tipoLogin: 'cliente'),
            ),
          );
        } else {
          // Já logado — abre perfil normalmente
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TelaPerfil(trabalhador: trabalhador),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Foto placeholder com iniciais
            // Foto do trabalhador
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: trabalhador.fotoTrabalhador != null && trabalhador.fotoTrabalhador!.isNotEmpty
                      ? GestureDetector(
                          onTap: () => _abrirMidia(trabalhador.fotoTrabalhador!),
                          child: Image.network(
                            trabalhador.fotoTrabalhador!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, __, ___) => _buildPlaceholderInicial(trabalhador),
                          ),
                        )
                      : _buildPlaceholderInicial(trabalhador),
                ),
              ),
            ),
            // Informações
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      trabalhador.nomeTrabalhador,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        trabalhador.profissaoTrabalhador,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Avaliação
                    FutureBuilder<Map<String, dynamic>>(
                      future: _supabaseService.obterMediaAvaliacoes(trabalhador.id),
                      builder: (ctx, snapshot) {
                        if (!snapshot.hasData || snapshot.data!['total'] == 0) return const SizedBox.shrink();
                        final media = snapshot.data!['media'] as double;
                        final total = snapshot.data!['total'] as int;
                        return Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              media.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              ' ($total)',
                              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '📍 ${_extrairBairro(trabalhador.descricaoTrabalhador ?? "")}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _extrairBairro(String descricao) {
    final match = RegExp(r'📍 Bairro:\s*(.+)').firstMatch(descricao);
    return match?.group(1)?.trim() ?? 'Bissau';
  }

  /// Placeholder com a inicial do trabalhador (quando não tem foto)
  Widget _buildPlaceholderInicial(TrabalhadorModel trabalhador) {
    return Center(
      child: CircleAvatar(
        radius: 32,
        backgroundColor: const Color(0xFF2563EB),
        child: Text(
          trabalhador.nomeTrabalhador.substring(0, 1).toUpperCase(),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }


}