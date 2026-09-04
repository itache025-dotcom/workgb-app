import 'package:flutter/material.dart';
import '../../temas/cores_novo.dart';
import '../../modelos/trabalhador_model.dart';
import '../tela_chat_novo.dart';

class TelaLeadsNovo extends StatefulWidget {
  const TelaLeadsNovo({super.key});

  @override
  State<TelaLeadsNovo> createState() => _TelaLeadsNovoState();
}

class _TelaLeadsNovoState extends State<TelaLeadsNovo> {
  String? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CoresNovo.background,
      appBar: AppBar(
        backgroundColor: CoresNovo.navyPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pedidos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Header
          Container(
            color: CoresNovo.navyPrimary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('4 solicitações de clientes em Bissau', style: TextStyle(fontSize: 12, color: Colors.white70)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(color: CoresNovo.starYellow, shape: BoxShape.circle),
                  child: const Text('1', style: TextStyle(color: CoresNovo.navyPrimary, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ],
            ),
          ),

          // Filtros
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _buildFilterChip('Todos (4)', true),
                _buildFilterChip('Novo Pedido (1)', false, CoresNovo.navyPrimary),
                _buildFilterChip('Em Negociação (1)', false, const Color(0xFFD97706)),
                _buildFilterChip('Visita Agendada (1)', false, const Color(0xFF7C3AED)),
              ],
            ),
          ),

          // Lista
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildLeadCard('Adulai Djaló', 'Santa Luzia', 'Instalação de Inversor Solar 5kVA', 'Comprei um inversor solar e 4 baterias. Preciso da montagem...', '35.000 FCFA', 'Novo Pedido', CoresNovo.navyPrimary),
                const SizedBox(height: 10),
                _buildLeadCard('Soraia Baldé', 'Bandim', 'Curto-circuito e Troca de Disjuntores', 'Tivemos um curto-circuito na cozinha ontem e ficamos sem luz...', '12.500 FCFA', 'Em Negociação', const Color(0xFFD97706)),
                const SizedBox(height: 10),
                _buildLeadCard('Malam Seidi', 'Bissau Velho', 'Iluminação LED para Boutique', 'Projeto de iluminação para nova boutique em Bissau Velho...', '50.000 FCFA', 'Visita Agendada', const Color(0xFF7C3AED)),
                const SizedBox(height: 10),
                _buildLeadCard('Fatu Cassamá', 'Antula', 'Instalação de Tomadas', 'Instalação de 6 novas tomadas aterradas e ventiladores...', '15.000 FCFA', 'Trabalho Concluído', CoresNovo.success),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, [Color? color]) {
    final bgColor = isSelected ? (color ?? CoresNovo.navyPrimary) : Colors.transparent;
    final txtColor = isSelected ? Colors.white : CoresNovo.textPrimary;
    final borderColor = isSelected ? Colors.transparent : CoresNovo.border;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Text(label, style: TextStyle(color: txtColor, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
    );
  }

  Widget _buildLeadCard(String name, String neighborhood, String title, String desc, String budget, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CoresNovo.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 16, backgroundColor: CoresNovo.blueContainer, child: Text(name.isNotEmpty ? name[0] : '?', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: CoresNovo.navyPrimary))),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: CoresNovo.navyPrimary)),
                      Text('📍 $neighborhood • Hoje', style: const TextStyle(fontSize: 11, color: CoresNovo.textSecondary)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: CoresNovo.textPrimary)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 12, color: CoresNovo.textSecondary, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [const Icon(Icons.account_balance_wallet, size: 14, color: CoresNovo.navyPrimary), const SizedBox(width: 4), Text(budget, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: CoresNovo.navyPrimary))]),
              const Text('Via Chat Lirify', style: TextStyle(fontSize: 11, color: CoresNovo.textSecondary, fontWeight: FontWeight.w500)),
            ],
          ),
          const Divider(height: 24, thickness: 0.5),
          Row(
            children: [
              Expanded(child: _buildMiniAction(Icons.call, 'Ligar', CoresNovo.navyPrimary, Colors.white, false)),
              const SizedBox(width: 8),
              Expanded(child: _buildMiniAction(Icons.chat, 'WhatsApp', CoresNovo.whatsApp, Colors.white, true)),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    final t = TrabalhadorModel(
                      id: '0', 
                      nomeTrabalhador: name, 
                      profissaoTrabalhador: 'Cliente'
                    );
                    Navigator.push(context, MaterialPageRoute(builder: (_) => TelaChatNovo(trabalhador: t)));
                  },
                  child: _buildMiniAction(Icons.forum, 'Chat Lirify', CoresNovo.blueSecondary, Colors.white, false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAction(IconData icon, String label, Color color, Color txtColor, bool isFilled) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: isFilled ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: isFilled ? null : Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: isFilled ? Colors.white : color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: isFilled ? Colors.white : color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
