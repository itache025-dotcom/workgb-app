import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedores/estado_global.dart';
import '../servicos/supabase_service.dart';
import '../modelos/trabalhador_model.dart';
import 'tela_chat.dart';
import 'tela_login.dart';

class TelaConversas extends StatefulWidget {
  const TelaConversas({super.key});

  @override
  State<TelaConversas> createState() => _TelaConversasState();
}

class _TelaConversasState extends State<TelaConversas> {
  final SupabaseService _supabaseService = SupabaseService();

  @override
  Widget build(BuildContext context) {
    final estado = Provider.of<EstadoGlobal>(context);
    // Escuta o total global para disparar rebuild da lista em tempo real
    final _ = estado.totalConversasNaoLidas;

    if (!estado.estaLogado) {
      return Scaffold(
        appBar: AppBar(title: const Text('Minhas Conversas')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Faz login para ver as tuas conversas.'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => TelaLogin(tipoLogin: 'cliente'))),
                child: const Text('Ir para Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Minhas Conversas',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _supabaseService.obterConversasCliente(
          utilizadorId: estado.usuarioLogado?.id,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Erro ao carregar conversas.'));
          }

          final mensagens = snapshot.data!;

          if (mensagens.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('Ainda não tens conversas.'),
                ],
              ),
            );
          }

          // Agrupar por trabalhador para mostrar uma conversa por profissional
          final conversasUnicas = <int, Map<String, dynamic>>{};
          for (final msg in mensagens) {
            final idTrabalhador = msg['trabalhador_id'] as int;
            if (!conversasUnicas.containsKey(idTrabalhador)) {
              conversasUnicas[idTrabalhador] = msg;
            }
          }

          final listaFinal = conversasUnicas.values.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listaFinal.length,
            itemBuilder: (context, index) {
              final item = listaFinal[index];
              final infoTrabalhador = item['trabalhadores'];
              final data = DateTime.parse(item['criado_em']).toLocal();

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200.withOpacity(0.2)),
                ),
                color: Theme.of(context).cardColor,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF2563EB),
                    backgroundImage: infoTrabalhador['foto_trabalhador'] != null
                        ? NetworkImage(infoTrabalhador['foto_trabalhador'])
                        : null,
                    child: infoTrabalhador['foto_trabalhador'] == null
                        ? Text(
                            infoTrabalhador['nome_trabalhador'].substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  title: Text(
                    infoTrabalhador['nome_trabalhador'],
                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (item['remetente_id'] == estado.usuarioLogado!.id) ...[
                            Icon(
                              item['estado'] == 'lido'
                                  ? Icons.done_all
                                  : item['estado'] == 'entregue'
                                      ? Icons.done_all
                                      : Icons.done,
                              size: 14,
                              color: item['estado'] == 'lido' ? Colors.blue : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              item['mensagem'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data.day}/${data.month} às ${data.hour}:${data.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                  trailing: FutureBuilder<int>(
                    future: _supabaseService.obterMensagensNaoLidasConversa(
                      trabalhadorId: item['trabalhador_id'],
                      clienteId: estado.usuarioLogado!.id,
                      utilizadorId: estado.usuarioLogado!.id,
                    ),
                    builder: (context, snapshot) {
                      final n = snapshot.data ?? 0;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (n > 0)
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                              child: Text('$n', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, size: 20),
                        ],
                      );
                    },
                  ),
                  onTap: () {
                    final trabalhador = TrabalhadorModel(
                      id: infoTrabalhador['id'].toString(),
                      nomeTrabalhador: infoTrabalhador['nome_trabalhador'],
                      profissaoTrabalhador: infoTrabalhador['profissao_trabalhador'],
                      utilizadorId: infoTrabalhador['utilizador_id'],
                      fotoTrabalhador: infoTrabalhador['foto_trabalhador'],
                      descricaoTrabalhador: infoTrabalhador['descricao_trabalhador'],
                      disponibilidadeDias: [],
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TelaChat(trabalhador: trabalhador)),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
