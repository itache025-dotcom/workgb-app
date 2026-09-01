import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../modelos/trabalhador_model.dart';
import '../provedores/estado_global.dart';
import '../servicos/supabase_service.dart';
import 'tela_login.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'tela_imagem_ampliada.dart';
import 'tela_video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import '../servicos/servico_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'dart:io';

class TelaChat extends StatefulWidget {
  final TrabalhadorModel trabalhador;
  final String? clienteId; // Opcional: ID do cliente se for o profissional a abrir o chat

  const TelaChat({super.key, required this.trabalhador, this.clienteId});

  @override
  State<TelaChat> createState() => _TelaChatState();
}

class _TelaChatState extends State<TelaChat> {
  final _mensagemController = TextEditingController();
  final _scrollController = ScrollController();
  final SupabaseService _supabaseService = SupabaseService();
  final SupabaseClient _client = Supabase.instance.client;
  String? _idDoCliente;
  bool _marcandoLidas = false;

  final ServicoAudio _servicoAudio = ServicoAudio();
  bool _gravando = false;
  DateTime? _inicioGravacao;
  Timer? _timerGravacao;
  String _tempoGravacao = '0:00';
  bool _carregandoMidia = false;

  @override
  void initState() {
    super.initState();
    
    final estado = Provider.of<EstadoGlobal>(context, listen: false);
    final isDono = estado.usuarioLogado?.id == widget.trabalhador.utilizadorId;

    // LÓGICA RIGOROSA:
    // 1. Se foi passado um clienteId (pelo profissional na lista), usa esse.
    // 2. Se eu SOU o dono do card e NÃO passei um clienteId, estou em modo inválido (chat comigo mesmo).
    // 3. Caso contrário, eu sou o cliente, usa o meu ID logado.
    if (widget.clienteId != null) {
      _idDoCliente = widget.clienteId;
    } else if (isDono) {
      _idDoCliente = null; // Impede marcar como lida e enviar mensagens para si mesmo
      print('AVISO: Profissional abriu o próprio chat a partir do feed. Chat desativado.');
    } else {
      _idDoCliente = estado.usuarioLogado?.id;
    }

    // Marcar mensagens como lidas ao abrir a conversa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _marcarMensagensComoLidas();
      _pedirPermissaoMicrofone();
    });
  }

  Future<void> _pedirPermissaoMicrofone() async {
    await _servicoAudio.temPermissao();
  }

  Future<void> _marcarMensagensComoLidas() async {
    if (_marcandoLidas) return;
    
    final estado = Provider.of<EstadoGlobal>(context, listen: false);
    if (estado.estaLogado && _idDoCliente != null) {
      setState(() => _marcandoLidas = true);
      try {
        print('DEBUG CHAT: Tentando marcar como lidas para cliente: $_idDoCliente');
        await _supabaseService.marcarComoLidas(
          trabalhadorId: int.parse(widget.trabalhador.id),
          clienteId: _idDoCliente!,
          utilizadorVisualizandoId: estado.usuarioLogado!.id,
        );
        
        // Atualiza o total global após marcar como lida
        int novoTotal = 0;
        if (estado.usuarioLogado!.tipoUsuario == 'profissional') {
          novoTotal = await _supabaseService.obterTotalConversasNaoLidas(estado.usuarioLogado!.id);
        } else {
          novoTotal = await _supabaseService.obterTotalMensagensNaoLidasCliente(estado.usuarioLogado!.id);
        }
        estado.atualizarTotalConversas(novoTotal);
      } catch (e) {
        print('Erro ao marcar como lidas: $e');
      } finally {
        if (mounted) setState(() => _marcandoLidas = false);
      }
    } else {
      print('DEBUG CHAT: Não marcou como lidas. Logado: ${estado.estaLogado}, ClienteID: $_idDoCliente');
    }
  }

  @override
  void dispose() {
    _mensagemController.dispose();
    _scrollController.dispose();
    _timerGravacao?.cancel();
    _servicoAudio.dispose();
    super.dispose();
  }

  void _rolarParaFim() {
    if (!_scrollController.hasClients) return;
    
    // Com reverse: true, a posição da última mensagem é o 0.0 (topo visual da lista invertida)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
        print('DEBUG SCROLL: Rolou para o fundo (posição 0 com reverse:true)');
      }
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  Future<void> _iniciarGravacao() async {
    final ok = await _servicoAudio.iniciarGravacao();
    if (ok) {
      setState(() {
        _gravando = true;
        _inicioGravacao = DateTime.now();
        _tempoGravacao = '0:00';
      });
      
      _timerGravacao = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_inicioGravacao != null) {
          final duracao = DateTime.now().difference(_inicioGravacao!);
          setState(() {
            _tempoGravacao = '${duracao.inMinutes}:${(duracao.inSeconds % 60).toString().padLeft(2, '0')}';
          });
        }
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao iniciar gravação ou permissão negada.')),
        );
      }
    }
  }

  Future<void> _pararEEnviarGravacao() async {
    if (!_gravando) return;

    _timerGravacao?.cancel();
    final caminho = await _servicoAudio.pararGravacao();
    
    setState(() {
      _gravando = false;
      _timerGravacao = null;
    });

    if (caminho != null) {
      _enviarMidia(caminho, 'audio', duracao: _tempoGravacao);
    }
  }

  Future<void> _anexarMidia() async {
    final picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF2563EB)),
              title: const Text('Galeria de Fotos'),
              onTap: () async {
                Navigator.pop(ctx);
                final xf = await picker.pickImage(source: ImageSource.gallery);
                if (xf != null) _enviarMidia(xf.path, 'imagem');
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library, color: Color(0xFF2563EB)),
              title: const Text('Galeria de Vídeos'),
              onTap: () async {
                Navigator.pop(ctx);
                final xf = await picker.pickVideo(source: ImageSource.gallery);
                if (xf != null) _enviarMidia(xf.path, 'video');
              },
            ),
            ListTile(
              leading: const Icon(Icons.audiotrack, color: Color(0xFF2563EB)),
              title: const Text('Ficheiro de Áudio'),
              onTap: () async {
                Navigator.pop(ctx);
                final result = await FilePicker.platform.pickFiles(type: FileType.audio);
                if (result != null && result.files.single.path != null) {
                  _enviarMidia(result.files.single.path!, 'audio');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF2563EB)),
              title: const Text('Tirar Foto'),
              onTap: () async {
                Navigator.pop(ctx);
                final xf = await picker.pickImage(source: ImageSource.camera);
                if (xf != null) _enviarMidia(xf.path, 'imagem');
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Color(0xFF2563EB)),
              title: const Text('Gravar Vídeo'),
              onTap: () async {
                Navigator.pop(ctx);
                final xf = await picker.pickVideo(source: ImageSource.camera);
                if (xf != null) _enviarMidia(xf.path, 'video');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _enviarMidia(String path, String tipo, {String? duracao}) async {
    setState(() => _carregandoMidia = true);
    try {
      final estado = Provider.of<EstadoGlobal>(context, listen: false);
      String? url;
      if (tipo == 'audio') {
        url = await _supabaseService.uploadAudio(path);
      } else {
        url = await _supabaseService.uploadMidia(path, tipo);
      }
      
      if (url != null) {
        String msgTxt = '📷 Foto';
        if (tipo == 'video') msgTxt = '🎥 Vídeo';
        if (tipo == 'audio') msgTxt = '🎤 Áudio';

        await _supabaseService.enviarMensagem(
          trabalhadorId: int.parse(widget.trabalhador.id),
          remetenteId: estado.usuarioLogado?.id,
          remetenteNome: estado.usuarioLogado?.nomeUsuario,
          mensagem: msgTxt,
          clienteId: _idDoCliente,
          tipo: tipo,
          urlMidia: url,
          duracaoAudio: duracao,
        );
        _rolarParaFim();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar $tipo: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _carregandoMidia = false);
    }
  }

  Future<void> _enviarMensagem() async {
    final estado = Provider.of<EstadoGlobal>(context, listen: false);
    final texto = _mensagemController.text.trim();

    if (texto.isEmpty) return;

    if (!estado.estaLogado) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const TelaLogin(tipoLogin: 'cliente')));
      return;
    }

    if (_idDoCliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não podes enviar mensagens para ti mesmo.')),
      );
      return;
    }

    try {
      await _supabaseService.enviarMensagem(
        trabalhadorId: int.parse(widget.trabalhador.id),
        remetenteId: estado.usuarioLogado?.id,
        remetenteNome: estado.usuarioLogado?.nomeUsuario,
        mensagem: texto,
        clienteId: _idDoCliente,
      );
      _mensagemController.clear();
      _rolarParaFim();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = Provider.of<EstadoGlobal>(context);
    final isDono = estado.usuarioLogado?.id == widget.trabalhador.utilizadorId;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF2563EB),
              backgroundImage: widget.trabalhador.fotoTrabalhador != null && widget.trabalhador.fotoTrabalhador!.isNotEmpty
                  ? NetworkImage(widget.trabalhador.fotoTrabalhador!)
                  : null,
              child: widget.trabalhador.fotoTrabalhador == null || widget.trabalhador.fotoTrabalhador!.isEmpty
                  ? Text(widget.trabalhador.nomeTrabalhador.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.trabalhador.nomeTrabalhador,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Chat Privado',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Mensagens em Tempo Real
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _client
                  .from('mensagens')
                  .stream(primaryKey: ['id'])
                  .eq('trabalhador_id', int.parse(widget.trabalhador.id))
                  .order('criado_em', ascending: true),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                if (_idDoCliente == null) {
                  return const Center(child: Text('Chat desativado para o próprio profissional.'));
                }

                // FILTRAGEM MANUAL por cliente_id
                final todasMensagens = snapshot.data ?? [];
                final mensagens = todasMensagens
                    .where((m) => m['cliente_id'] == _idDoCliente)
                    .toList();

                if (mensagens.isNotEmpty) {
                  // Só marca como lida se houver mensagens NÃO LIDAS enviadas pela OUTRA pessoa
                  final temNovas = mensagens.any((m) => 
                      m['lida'] == false && 
                      m['remetente_id'] != estado.usuarioLogado?.id
                  );
                  
                  if (temNovas) {
                    _marcarMensagensComoLidas();
                  }
                }

                if (mensagens.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('Nenhuma mensagem ainda.', style: TextStyle(color: Colors.grey[500])),
                        Text('Inicia a conversa!', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                      ],
                    ),
                  );
                }

                print('DEBUG: Total de mensagens: ${mensagens.length}');
                
                // Auto-scroll ao receber dados novos
                _rolarParaFim();

                // Reverter a lista para que a última mensagem (mais recente) seja o índice 0
                final mensagensInvertidas = mensagens.reversed.toList();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  reverse: true, // ÚLTIMA MENSAGEM NO FUNDO (ÍNDICE 0)
                  itemCount: mensagensInvertidas.length,
                  itemBuilder: (context, index) {
                    final msg = mensagensInvertidas[index];
                    final remetenteId = msg['remetente_id'];
                    final eMinha = (remetenteId == estado.usuarioLogado?.id &&
                        remetenteId != null);

                    // Se o remetente da mensagem é o dono deste perfil profissional
                    final eProfissional =
                        remetenteId == widget.trabalhador.utilizadorId;

                    return _buildChatBubble(msg, eMinha, eProfissional, isDono);
                  },
                );
              },
            ),
          ),

          // Input
          if (_carregandoMidia)
            const LinearProgressIndicator(minHeight: 2, color: Color(0xFF2563EB)),
            
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Row(
              children: [
                if (!_gravando)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFF2563EB)),
                    onPressed: _carregandoMidia ? null : _anexarMidia,
                  ),
                Expanded(
                  child: _gravando 
                    ? Row(
                        children: [
                          const Icon(Icons.mic, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Text('Gravando... $_tempoGravacao', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          const Text('Solta para enviar', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      )
                    : TextField(
                        controller: _mensagemController,
                        onChanged: (v) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Escreve a tua mensagem...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                        ),
                        maxLines: null,
                      ),
                ),
                if (_mensagemController.text.trim().isEmpty || _gravando)
                  GestureDetector(
                    onTapDown: (_) => _iniciarGravacao(),
                    onTapUp: (_) => _pararEEnviarGravacao(),
                    onTapCancel: () {
                      if (_gravando) {
                        _timerGravacao?.cancel();
                        _servicoAudio.pararGravacao();
                        setState(() => _gravando = false);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        _gravando ? Icons.mic : Icons.mic_none, 
                        color: _gravando ? Colors.red : const Color(0xFF2563EB),
                        size: _gravando ? 30 : 24,
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF2563EB)),
                    onPressed: _enviarMensagem,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg, bool eMinha, bool eProfissional, bool souODono) {
    // A lógica deve ser: se a mensagem é MINHA, vai para a DIREITA (AZUL)
    // Se a mensagem é do OUTRO, vai para a ESQUERDA (CINZA)
    final cor = eMinha ? const Color(0xFF2563EB) : Colors.grey[300];
    final corTexto = eMinha ? Colors.white : Colors.black87;
    final alinhamento = eMinha ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bordas = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(eMinha ? 16 : 0),
      bottomRight: Radius.circular(eMinha ? 0 : 16),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: alinhamento,
        children: [
          // Mostrar nome apenas se a mensagem NÃO for minha
          if (!eMinha)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                eProfissional ? '${msg['remetente_nome']} (Profissional)' : (msg['remetente_nome'] ?? 'Anônimo'),
                style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: eProfissional ? FontWeight.bold : FontWeight.normal),
              ),
            ),
          GestureDetector(
            onLongPress: souODono ? () => _confirmarEliminar(msg['id']) : null,
            onTap: () {
              if (msg['tipo'] == 'imagem' && msg['url_midia'] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TelaImagemAmpliada(urlImagem: msg['url_midia'])),
                );
              } else if (msg['tipo'] == 'video' && msg['url_midia'] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TelaVideoPlayer(urlVideo: msg['url_midia'])),
                );
              }
            },
            child: Container(
              padding: msg['tipo'] == 'texto' 
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                  : EdgeInsets.zero,
              decoration: BoxDecoration(
                color: cor, 
                borderRadius: bordas,
                border: msg['tipo'] != 'texto' ? Border.all(color: Colors.grey.shade300, width: 0.5) : null,
              ),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              child: _buildConteudoMensagem(msg, corTexto),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatarData(msg['criado_em']),
                style: TextStyle(fontSize: 9, color: eMinha ? Colors.white70 : Colors.grey[500]),
              ),
              if (eMinha) ...[
                const SizedBox(width: 4),
                Icon(
                  msg['estado'] == 'lido'
                      ? Icons.done_all
                      : msg['estado'] == 'entregue'
                          ? Icons.done_all
                          : Icons.done,
                  size: 13,
                  color: msg['estado'] == 'lido' ? Colors.cyanAccent : Colors.white70,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Mensagem'),
        content: const Text('Queres apagar esta mensagem?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Não')),
          TextButton(
            onPressed: () async {
              await _supabaseService.apagarMensagem(id);
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text('Sim, eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatarData(String iso) {
    final data = DateTime.parse(iso).toLocal();
    return '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildConteudoMensagem(Map<String, dynamic> msg, Color corTexto) {
    final tipo = msg['tipo'] ?? 'texto';
    final url = msg['url_midia'];

    if (tipo == 'imagem' && url != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              width: 200,
              height: 200,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          },
          errorBuilder: (_, __, ___) => Container(
            width: 200,
            height: 200,
            color: Colors.grey[200],
            child: const Center(child: Text('Erro ao carregar imagem', style: TextStyle(fontSize: 10))),
          ),
        ),
      );
    } else if (tipo == 'video' && url != null) {
      return VideoPlayerWidget(url: url);
    } else if (tipo == 'audio' && url != null) {
      return AudioPlayerWidget(
        url: url, 
        duracao: msg['duracao_audio'],
        corPrincipal: corTexto,
      );
    } else {
      return Text(
        msg['mensagem'] ?? '',
        style: TextStyle(color: corTexto, fontSize: 14),
      );
    }
  }
}

class AudioPlayerWidget extends StatefulWidget {
  final String url;
  final String? duracao;
  final Color corPrincipal;
  const AudioPlayerWidget({super.key, required this.url, this.duracao, required this.corPrincipal});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.onPositionChanged.listen((p) { if (mounted) setState(() => _position = p); });
    _player.onDurationChanged.listen((d) { if (mounted) setState(() => _duration = d); });
    _player.onPlayerComplete.listen((_) { if (mounted) setState(() => _isPlaying = false); });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            color: widget.corPrincipal,
            onPressed: () async {
              if (_isPlaying) {
                await _player.pause();
              } else {
                await _player.play(UrlSource(widget.url));
              }
              setState(() => _isPlaying = !_isPlaying);
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Slider(
                  value: _position.inMilliseconds.toDouble(),
                  max: _duration.inMilliseconds.toDouble() > 0 
                      ? _duration.inMilliseconds.toDouble() 
                      : 1.0,
                  activeColor: widget.corPrincipal,
                  inactiveColor: widget.corPrincipal.withOpacity(0.3),
                  onChanged: (v) => _player.seek(Duration(milliseconds: v.toInt())),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    _isPlaying 
                        ? '${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')}'
                        : (widget.duracao ?? '0:00'),
                    style: TextStyle(fontSize: 10, color: widget.corPrincipal.withOpacity(0.7)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;
  const VideoPlayerWidget({super.key, required this.url});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _inicializado = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() => _inicializado = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_inicializado) {
      return const SizedBox(
        width: 200,
        height: 150,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            Icon(
              Icons.play_circle_fill, 
              size: 50, 
              color: Colors.white.withOpacity(0.8)
            ),
          ],
        ),
      ),
    );
  }
}
