import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedores/estado_global.dart';
import '../servicos/supabase_service.dart';
import '../modelos/trabalhador_model.dart';
import 'tela_chat.dart';

class TelaMensagensProfissional extends StatefulWidget {
  const TelaMensagensProfissional({super.key});

  @override
  State<TelaMensagensProfissional> createState() => _TelaMensagensProfissionalState();
}

class _TelaMensagensProfissionalState extends State<TelaMensagensProfissional> {
  final SupabaseService _supabaseService = SupabaseService();
  int _nivel = 1; // 1: Cards, 2: Clientes, 3: Chat (Navegação interna ou via push)
  Map<String, dynamic>? _cardSelecionado;
  
  @override
  Widget build(BuildContext context) {
    // Escuta mudanças globais (ex: novas mensagens chegando via Realtime no main.dart)
    final totalNaoLidas = Provider.of<EstadoGlobal>(context).totalConversasNaoLidas;

    return WillPopScope(
      onWillPop: () async {
        if (_nivel > 1) {
          setState(() => _nivel--);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            _nivel == 1 ? 'Mensagens por Card' : 'Clientes em ${_cardSelecionado?['nome_trabalhador']}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_nivel > 1) setState(() => _nivel--);
              else Navigator.pop(context);
            },
          ),
        ),
        body: _nivel == 1 ? _buildListaCards() : _buildListaClientes(),
      ),
    );
  }

  Widget _buildListaCards() {
    final usuario = Provider.of<EstadoGlobal>(context, listen: false).usuarioLogado;
    if (usuario == null) return const Center(child: Text('Erro: Utilizador não logado.'));
    
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _supabaseService.obterCardsComMensagens(usuario.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Ainda não tens mensagens em nenhum card.'));
        }

        final cards = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                title: Text(card['nome_trabalhador'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(card['profissao_trabalhador']),
                trailing: FutureBuilder<int>(
                  future: _supabaseService.obterClientesNaoLidosPorCard(card['id'], usuario.id),
                  builder: (context, snapshot) {
                    final n = snapshot.data ?? 0;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (n > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                            child: Text('$n', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right),
                      ],
                    );
                  }
                ),
                onTap: () {
                  setState(() {
                    _cardSelecionado = card;
                    _nivel = 2;
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListaClientes() {
    final usuario = Provider.of<EstadoGlobal>(context, listen: false).usuarioLogado;
    if (usuario == null) return const Center(child: Text('Erro: Utilizador não logado.'));

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _supabaseService.obterClientesPorCard(_cardSelecionado!['id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Sem clientes registados para este card.'));
        }

        final clientes = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: clientes.length,
          itemBuilder: (context, index) {
            final cliente = clientes[index];
            final data = DateTime.parse(cliente['criado_em']).toLocal();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text((cliente['nome_cliente'] != null && cliente['nome_cliente'].toString().isNotEmpty) ? cliente['nome_cliente'].toString().substring(0, 1).toUpperCase() : '?'),
                ),
                title: Text(cliente['nome_cliente'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Row(
                  children: [
                    if (cliente['remetente_id'] == usuario?.id) ...[
                      Icon(
                        cliente['estado'] == 'lido'
                            ? Icons.done_all
                            : cliente['estado'] == 'entregue'
                                ? Icons.done_all
                                : Icons.done,
                        size: 14,
                        color: cliente['estado'] == 'lido' ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(cliente['ultima_mensagem'], maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                trailing: FutureBuilder<int>(
                  future: _supabaseService.obterMensagensNaoLidasConversa(
                    trabalhadorId: _cardSelecionado!['id'], 
                    clienteId: cliente['cliente_id'],
                    utilizadorId: usuario.id,
                  ),
                  builder: (context, snapshot) {
                    final n = snapshot.data ?? 0;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${data.day}/${data.month}', style: const TextStyle(fontSize: 10)),
                        const SizedBox(height: 4),
                        if (n > 0)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                            child: Text('$n', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    );
                  }
                ),
                onTap: () {
                  // Abrir Chat Privado
                  final profissionalId = Provider.of<EstadoGlobal>(context, listen: false).usuarioLogado!.id;
                  final trabalhador = TrabalhadorModel(
                    id: _cardSelecionado!['id'].toString(),
                    nomeTrabalhador: _cardSelecionado!['nome_trabalhador'],
                    profissaoTrabalhador: _cardSelecionado!['profissao_trabalhador'],
                    utilizadorId: profissionalId,
                    disponibilidadeDias: [],
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TelaChat(
                        trabalhador: trabalhador,
                        clienteId: cliente['cliente_id'],
                      ),
                    ),
                  ).then((_) {
                    // Atualizar lista ao voltar para limpar badges
                    setState(() {});
                  });
                },
              ),
            );
          },
        );
      },
    );
  }
}
