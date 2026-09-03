import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../provedores/estado_global.dart';
import '../servicos/supabase_service.dart';
import '../modelos/trabalhador_model.dart';
import '../temas/cores_novo.dart';
import 'tela_login.dart';
import 'dart:async';

class TelaChatNovo extends StatefulWidget {
  final TrabalhadorModel trabalhador;
  final String? clienteId;
  const TelaChatNovo({super.key, required this.trabalhador, this.clienteId});

  @override
  State<TelaChatNovo> createState() => _TelaChatNovoState();
}

class _TelaChatNovoState extends State<TelaChatNovo> {
  final _mensagemController = TextEditingController();
  final _scrollController = ScrollController();
  final SupabaseService _supabaseService = SupabaseService();
  final SupabaseClient _client = Supabase.instance.client;
  String? _idDoCliente;
  bool _marcandoLidas = false;

  @override
  void initState() {
    super.initState();
    
    final estado = Provider.of<EstadoGlobal>(context, listen: false);
    if (widget.trabalhador != null) {
      final isDono = estado.usuarioLogado?.id == widget.trabalhador!.utilizadorId;
      
      if (widget.clienteId != null) {
        _idDoCliente = widget.clienteId;
      } else if (!isDono) {
        _idDoCliente = estado.usuarioLogado?.id;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _marcarMensagensComoLidas();
    });
  }

  @override
  void dispose() {
    _mensagemController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _marcarMensagensComoLidas() async {
    if (_marcandoLidas || widget.trabalhador == null || _idDoCliente == null) return;
    
    final estado = Provider.of<EstadoGlobal>(context, listen: false);
    if (estado.estaLogado) {
      setState(() => _marcandoLidas = true);
      try {
        await _supabaseService.marcarComoLidas(
          trabalhadorId: int.parse(widget.trabalhador!.id),
          clienteId: _idDoCliente!,
          utilizadorVisualizandoId: estado.usuarioLogado!.id,
        );
        
        final novoTotal = await _supabaseService.obterTotalConversasNaoLidas(estado.usuarioLogado!.id);
        estado.atualizarTotalConversas(novoTotal);
      } catch (e) {
        print('Erro ao marcar como lidas: $e');
      } finally {
        if (mounted) setState(() => _marcandoLidas = false);
      }
    }
  }

  void _rolarParaFim() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  Future<void> _enviarMensagem() async {
    final estado = Provider.of<EstadoGlobal>(context, listen: false);
    final texto = _mensagemController.text.trim();

    if (texto.isEmpty) return;
    if (widget.trabalhador == null) return;

    if (!estado.estaLogado) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaLogin(tipoLogin: 'cliente')));
      return;
    }

    if (_idDoCliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro: Conversa inválida.')));
      return;
    }

    try {
      await _supabaseService.enviarMensagem(
        trabalhadorId: int.parse(widget.trabalhador!.id),
        remetenteId: estado.usuarioLogado?.id,
        remetenteNome: estado.usuarioLogado?.nomeUsuario,
        mensagem: texto,
        clienteId: _idDoCliente,
      );
      _mensagemController.clear();
      _rolarParaFim();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao enviar: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CoresNovo.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CoresNovo.navyPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: widget.trabalhador?.fotoTrabalhador != null && widget.trabalhador!.fotoTrabalhador!.isNotEmpty
                  ? NetworkImage(widget.trabalhador!.fotoTrabalhador!)
                  : const NetworkImage('https://via.placeholder.com/150'),
              child: widget.trabalhador != null && (widget.trabalhador!.fotoTrabalhador == null || widget.trabalhador!.fotoTrabalhador!.isEmpty)
                  ? Text((widget.trabalhador!.nomeTrabalhador.isNotEmpty ? widget.trabalhador!.nomeTrabalhador.substring(0, 1) : 'P').toUpperCase())
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.trabalhador?.nomeTrabalhador ?? 'Braima Cassamá', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CoresNovo.navyPrimary)),
                  Row(
                    children: [
                      Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      const Text('Online agora', style: TextStyle(fontSize: 11, color: CoresNovo.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call_outlined, color: CoresNovo.navyPrimary), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert_outlined, color: CoresNovo.textSecondary), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Mensagens
          Expanded(
            child: widget.trabalhador == null || _idDoCliente == null
              ? const Center(child: Text('Escolha um trabalhador para conversar.'))
              : StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _client
                      .from('mensagens')
                      .stream(primaryKey: ['id'])
                      .eq('trabalhador_id', int.parse(widget.trabalhador!.id))
                      .order('criado_em', ascending: true),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final todasMensagens = snapshot.data ?? [];
                    final mensagens = todasMensagens
                        .where((m) => m['cliente_id'] == _idDoCliente)
                        .toList();

                    if (mensagens.isEmpty) {
                      return ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        children: [
                          _buildSafetyNotice(),
                          const SizedBox(height: 40),
                          const Center(child: Text('Nenhuma mensagem ainda. Inicie a conversa!', style: TextStyle(color: CoresNovo.textSecondary))),
                        ],
                      );
                    }

                    _rolarParaFim();
                    final mensagensInvertidas = mensagens.reversed.toList();
                    final estado = Provider.of<EstadoGlobal>(context, listen: false);

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      reverse: true,
                      itemCount: mensagensInvertidas.length + 1,
                      itemBuilder: (context, index) {
                        if (index == mensagensInvertidas.length) {
                          return _buildSafetyNotice();
                        }
                        final msg = mensagensInvertidas[index];
                        final eMinha = msg['remetente_id'] == estado.usuarioLogado?.id;
                        return _buildMessage(msg['mensagem'], _formatarHora(msg['criado_em']), isMe: eMinha);
                      },
                    );
                  },
                ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)]),
            child: SafeArea(
              child: Row(
                children: [
                  _buildRoundIconButton(Icons.mic_none_outlined, CoresNovo.navyPrimary, const Color(0xFFF1F5F9)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _mensagemController,
                      onChanged: (v) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Escreva uma mensagem...',
                        fillColor: const Color(0xFFF8FAFC),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: CoresNovo.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: CoresNovo.navyPrimary)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _enviarMensagem,
                    child: Container(
                      height: 44, width: 44,
                      decoration: const BoxDecoration(color: CoresNovo.navyPrimary, shape: BoxShape.circle),
                      child: const Icon(Icons.send, color: Colors.white, size: 19),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyNotice() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFFE2E8F0).withOpacity(0.8), borderRadius: BorderRadius.circular(8)),
        child: const Text('🔒 Conversa segura pelo WorkGB Guiné-Bissau', style: TextStyle(fontSize: 11, color: CoresNovo.textSecondary)),
      ),
    );
  }

  String _formatarHora(String iso) {
    try {
      final data = DateTime.parse(iso).toLocal();
      return '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  Widget _buildMessage(String text, String time, {required bool isMe}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? CoresNovo.navyPrimary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 2),
            bottomRight: Radius.circular(isMe ? 2 : 16),
          ),
          boxShadow: isMe ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(text, style: TextStyle(fontSize: 14, color: isMe ? Colors.white : CoresNovo.textPrimary, height: 1.4)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(time, style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : CoresNovo.textSecondary)),
                if (isMe) ...[
                  const SizedBox(width: 3),
                  const Icon(Icons.done_all, size: 13, color: Colors.white70),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundIconButton(IconData icon, Color color, Color bg) {
    return Container(
      height: 42, width: 42,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
