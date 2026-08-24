import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedores/estado_global.dart';
import '../servicos/supabase_service.dart';

class TelaMinhasAvaliacoes extends StatefulWidget {
  const TelaMinhasAvaliacoes({super.key});

  @override
  State<TelaMinhasAvaliacoes> createState() => _TelaMinhasAvaliacoesState();
}

class _TelaMinhasAvaliacoesState extends State<TelaMinhasAvaliacoes> {
  final SupabaseService _supabaseService = SupabaseService();

  @override
  Widget build(BuildContext context) {
    final estado = Provider.of<EstadoGlobal>(context);
    final usuario = estado.usuarioLogado;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A3C6E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Minhas Avaliações',
          style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF1A3C6E), fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _supabaseService.obterAvaliacoesPorProfissional(usuario!.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Erro ao carregar avaliações.'));
          }

          final avaliacoes = snapshot.data!;

          if (avaliacoes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Ainda não tens avaliações.',
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // Resumo no topo
          final totalAvaliacoes = avaliacoes.length;
          final mediaGeral = avaliacoes.fold<double>(0, (sum, item) => sum + (item['estrelas'] as int)) / totalAvaliacoes;

          // Agrupar por card
          final agrupadas = <String, List<Map<String, dynamic>>>{};
          for (final av in avaliacoes) {
            final cardNome = av['trabalhadores']['nome_trabalhador'] ?? 'Sem Nome';
            final cardProfissao = av['trabalhadores']['profissao_trabalhador'] ?? 'Trabalhador';
            final chave = '$cardNome ($cardProfissao)';
            if (!agrupadas.containsKey(chave)) {
              agrupadas[chave] = [];
            }
            agrupadas[chave]!.add(av);
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Card de Resumo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem('Média', mediaGeral.toStringAsFixed(1), Icons.star, Colors.amber),
                    _buildSummaryItem('Total', totalAvaliacoes.toString(), Icons.rate_review, Colors.blue),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Detalhes por Card',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A3C6E)),
              ),
              const SizedBox(height: 16),

              ...agrupadas.entries.map((entry) {
                return _buildCardGroup(entry.key, entry.value);
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A3C6E))),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildCardGroup(String cardChave, List<Map<String, dynamic>> avs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            cardChave,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2563EB)),
          ),
        ),
        ...avs.map((av) => _buildAvaliacaoItem(av)).toList(),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildAvaliacaoItem(Map<String, dynamic> av) {
    final nomeAvaliador = av['utilizadores']?['nome_usuario'] ?? av['nome_avaliador'] ?? 'Anónimo';
    final estrelas = av['estrelas'] as int;
    final comentario = av['comentario'] ?? '';
    final data = DateTime.parse(av['criado_em']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(nomeAvaliador, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A3C6E))),
              Row(
                children: List.generate(5, (index) => Icon(
                  index < estrelas ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 14,
                )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comentario, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            '${data.day}/${data.month}/${data.year}',
            style: TextStyle(color: Colors.grey[400], fontSize: 11),
          ),
        ],
      ),
    );
  }
}
