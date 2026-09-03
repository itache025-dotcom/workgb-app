import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../provedores/estado_global.dart';
import '../servicos/supabase_service.dart';
import '../modelos/trabalhador_model.dart';
import '../temas/cores_novo.dart';
import 'tela_chat_novo.dart';
import 'tela_login_novo.dart';

class TelaConversasNovo extends StatefulWidget {
  const TelaConversasNovo({super.key});

  @override
  State<TelaConversasNovo> createState() => _TelaConversasNovoState();
}

class _TelaConversasNovoState extends State<TelaConversasNovo> {
  final SupabaseService _supabaseService = SupabaseService();
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final estado = Provider.of<EstadoGlobal>(context);
    final usuario = estado.usuarioLogado;

    if (!estado.estaLogado) {
      return Scaffold(
        backgroundColor: CoresNovo.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text('Minhas Conversas', style: TextStyle(fontWeight: FontWeight.bold, color: CoresNovo.navyPrimary)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Faz login para ver as tuas conversas.'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaLoginNovo())),
                style: ElevatedButton.styleFrom(backgroundColor: CoresNovo.navyPrimary),
                child: const Text('Ir para Login'),
              ),
            ],
          ),
        ),
      );
    }

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
          'Minhas Conversas',
          style: TextStyle(fontWeight: FontWeight.bold, color: CoresNovo.navyPrimary),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _supabaseService.obterConversas(usuario?.id ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('ERRO CONVERSAS: ${snapshot.error}');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Erro ao carregar conversas: ${snapshot.error}', textAlign: TextAlign.center),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Sem conversas disponíveis.'));
          }

          final todasMensagens = List<Map<String, dynamic>>.from(snapshot.data!);
          print('DEBUG CONVERSAS: Encontradas ${todasMensagens.length} mensagens para o utilizador ${usuario?.id}');


          if (todasMensagens.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('Ainda não tens conversas.', style: TextStyle(color: CoresNovo.textSecondary)),
                ],
              ),
            );
          }

          final listaFinal = List<Map<String, dynamic>>.from(snapshot.data!);
          print('DEBUG CONVERSAS: Exibindo ${listaFinal.length} conversas para o utilizador ${usuario?.id}');

          if (listaFinal.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('Ainda não tens conversas.', style: TextStyle(color: CoresNovo.textSecondary)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listaFinal.length,
            itemBuilder: (context, index) {
              final item = listaFinal[index];
              final infoTrabalhador = item['trabalhadores'];
              final data = DateTime.parse(item['criado_em']).toLocal();
              final hora = '${data.hour}:${data.minute.toString().padLeft(2, '0')}';
              
              final isMeSender = item['remetente_id'] == usuario?.id;
              
              return _buildConversaItem(
                trabalhador: TrabalhadorModel(
                  id: infoTrabalhador['id'].toString(),
                  nomeTrabalhador: infoTrabalhador['nome_trabalhador'] ?? 'Profissional',
                  profissaoTrabalhador: infoTrabalhador['profissao_trabal_hador'] ?? infoTrabalhador['profissao_trabalhador'] ?? '',
                  utilizadorId: infoTrabalhador['utilizador_id'],
                  fotoTrabalhador: infoTrabalhador['foto_trabalhador'],
                ),
                displayNome: item['display_nome'] ?? 'Utilizador',
                displayFoto: item['display_foto'],
                clienteId: item['cliente_id'],
                ultimaMsg: item['mensagem'],
                hora: hora,
                naoLida: item['lida'] == false && !isMeSender,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildConversaItem({
    required TrabalhadorModel trabalhador, 
    required String displayNome,
    String? displayFoto,
    required String clienteId,
    required String ultimaMsg, 
    required String hora, 
    required bool naoLida,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CoresNovo.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: CoresNovo.blueLight,
            backgroundImage: displayFoto != null ? NetworkImage(displayFoto) : null,
            child: displayFoto == null 
                ? Text(
                    (displayNome.isNotEmpty ? displayNome.substring(0, 1) : 'P').toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: CoresNovo.navyPrimary),
                  )
                : null,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  displayNome,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: CoresNovo.navyPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                hora,
                style: TextStyle(fontSize: 12, color: naoLida ? CoresNovo.blueSecondary : CoresNovo.textSecondary),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    ultimaMsg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: naoLida ? CoresNovo.textPrimary : CoresNovo.textSecondary,
                      fontWeight: naoLida ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (naoLida)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(color: CoresNovo.blueSecondary, shape: BoxShape.circle),
                  ),
              ],
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TelaChatNovo(trabalhador: trabalhador, clienteId: clienteId)),
            );
          },
        ),
      ),
    );
  }
}
