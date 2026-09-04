import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provedores/estado_global.dart';
import '../../servicos/auth_service.dart';
import '../../servicos/supabase_service.dart';
import '../../temas/cores_novo.dart';
import '../../widgets/bottom_nav_novo.dart';
import 'tela_leads_novo.dart';
import 'tela_negocio_novo.dart';
import '../tela_feed_novo.dart';
import '../tela_chat_novo.dart';
import '../tela_conversas_novo.dart';
import '../tela_perfil_usuario_novo.dart';
import 'dialogo_boost_novo.dart';
import 'dialogo_editar_perfil_novo.dart';

class TelaDashboardNovo extends StatefulWidget {
  const TelaDashboardNovo({super.key});

  @override
  State<TelaDashboardNovo> createState() => _TelaDashboardNovoState();
}

class _TelaDashboardNovoState extends State<TelaDashboardNovo> {
  int _currentIndex = 0;
  int _visualizacoes = 0;
  int _contactos = 0;
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _carregarEstatisticas();
  }

  Future<void> _carregarEstatisticas() async {
    try {
      final estado = Provider.of<EstadoGlobal>(context, listen: false);
      final usuario = estado.usuarioLogado;
      if (usuario == null) return;

      final cards = await _supabaseService.meusCards(usuario.id);
      if (cards.isEmpty) return;

      final ids = cards.map((c) => int.parse(c.id)).toList();
      final stats = await _supabaseService.obterEstatisticas(ids);

      if (mounted) {
        setState(() {
          _visualizacoes = stats['visualizacoes'] ?? 0;
          _contactos = stats['contactos'] ?? 0;
        });
      }
    } catch (e) {
      print('Erro ao carregar estatísticas do dashboard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = Provider.of<EstadoGlobal>(context);
    final usuario = estado.usuarioLogado;

    return Scaffold(
      backgroundColor: CoresNovo.background,
      bottomNavigationBar: BottomNavNovo(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == 0) return;
          if (i == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TelaConversasNovo()));
          } else if (i == 2) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TelaNegocioNovo()));
          } else if (i == 3) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TelaPerfilUsuarioNovo()));
          }
        },
        isProfessional: true,
        newLeads: 0,
        unreadMessages: estado.totalConversasNaoLidas,
      ),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              color: CoresNovo.navyPrimary,
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => TelaPerfilUsuarioNovo()));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: CoresNovo.starYellow, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 23,
                                backgroundColor: Colors.white24,
                                backgroundImage: usuario?.fotoUsuario != null && usuario!.fotoUsuario!.isNotEmpty
                                    ? NetworkImage(usuario.fotoUsuario!)
                                    : null,
                                child: (usuario?.fotoUsuario == null || usuario!.fotoUsuario!.isEmpty)
                                    ? Text(
                                        (usuario?.nomeUsuario != null && usuario!.nomeUsuario.isNotEmpty) ? usuario.nomeUsuario.substring(0, 1).toUpperCase() : 'P',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Olá, ${(usuario?.nomeUsuario != null && usuario!.nomeUsuario.isNotEmpty) ? usuario.nomeUsuario.split(' ')[0] : 'Profissional'} 👋', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              const Text('Profissional • Bissau', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildClientModeButton(estado),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.person_outline, color: Colors.white),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => TelaPerfilUsuarioNovo()));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAvailabilityStatus(),
                      _buildProBadge(),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Banner Novos Pedidos
                // _buildNewLeadsBanner(),
                const SizedBox(height: 24),

                const Text('Resumo do Seu Negócio', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CoresNovo.navyPrimary)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildMetricCard('Visualizações', '$_visualizacoes', '+18% esta semana', Icons.trending_up, const Color(0xFF2563EB))),
                    const SizedBox(width: 10),
                    Expanded(child: _buildMetricCard('Contactos', '$_contactos', 'Taxa resp. 98%', Icons.contact_phone_outlined, CoresNovo.success)),
                  ],
                ),
                const SizedBox(height: 24),

                const Text('Atalhos Rápidos', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CoresNovo.navyPrimary)),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.6,
                  children: [
                    _buildQuickAction(
                      'Meu Negócio', 'Serviços & Galeria', Icons.storefront, const Color(0xFF7C3AED),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => TelaNegocioNovo())),
                    ),
                    _buildQuickAction(
                      'Ver Trabalhadores', 'Feed principal', Icons.people_outline, CoresNovo.success,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => TelaFeedNovo(mostrarBottomNav: false))),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                /* 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pedidos Recentes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CoresNovo.navyPrimary)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TelaLeadsNovo())),
                      child: const Text('Ver todos (4)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: CoresNovo.navyPrimary)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TelaLeadsNovo())),
                  child: _buildLeadCard('Adulai Djaló', 'Instalação de Inversor Solar', 'Hoje, às 14:15', '35.000 FCFA', 'Novo Pedido', CoresNovo.navyPrimary),
                ),
                const SizedBox(height: 24),
                */

                _buildTipCard(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientModeButton(EstadoGlobal estado) {
    return GestureDetector(
      onTap: () {
        if (estado.usuarioLogado != null) {
          estado.alternarModo();
          AuthService().atualizarModoUtilizacao(estado.usuarioLogado!.id, false);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => TelaFeedNovo()),
            (route) => false,
          );
        }
      },
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: CoresNovo.starYellow.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: CoresNovo.starYellow),
        ),
        child: Row(
          children: const [
            Icon(Icons.swap_horiz, color: CoresNovo.starYellow, size: 14),
            SizedBox(width: 6),
            Text('Mudar p/ Cliente', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: CoresNovo.success.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CoresNovo.success),
      ),
      child: Row(
        children: const [
          CircleAvatar(radius: 4, backgroundColor: CoresNovo.success),
          SizedBox(width: 6),
          Text('Disponível', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: CoresNovo.starYellow, borderRadius: BorderRadius.circular(12)),
      child: const Text('Gratis ', style: TextStyle(color: CoresNovo.navyPrimary, fontSize: 11, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildNewLeadsBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            height: 38, width: 38,
            decoration: const BoxDecoration(color: Color(0xFF3B82F6), shape: BoxShape.circle),
            child: const Icon(Icons.notifications_active, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('1 Novo Pedido Recebido!', style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold, fontSize: 13)),
                Text('Clientes em Bissau aguardando seu orçamento', style: TextStyle(color: Color(0xFF1E40AF), fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF3B82F6)),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String trend, IconData icon, Color accent) {
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
              Text(title, style: const TextStyle(color: CoresNovo.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
              Icon(icon, color: accent, size: 18),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: CoresNovo.navyPrimary)),
          Text(trend, style: TextStyle(fontSize: 10, color: accent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String title, String subtitle, IconData icon, Color color, [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CoresNovo.border),
        ),
        child: Column(
          children: [
            Container(
              height: 34, width: 34,
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: CoresNovo.navyPrimary), textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: CoresNovo.textSecondary, fontSize: 9), textAlign: TextAlign.center, maxLines: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadCard(String client, String service, String date, String budget, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(12),
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
                  CircleAvatar(radius: 12, backgroundColor: statusColor.withOpacity(0.15), child: Icon(Icons.person, size: 14, color: statusColor)),
                  const SizedBox(width: 8),
                  Text(client, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: CoresNovo.navyPrimary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(service, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: CoresNovo.textPrimary)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('📍 Santa Luzia • $date', style: const TextStyle(fontSize: 10, color: CoresNovo.textSecondary)),
              Text(budget, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: CoresNovo.navyPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, color: Color(0xFFD97706), size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dica Lirify para mais clientes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF92400E))),
                SizedBox(height: 2),
                Text(
                  'Profissionais que respondem em menos de 10 minutos fecham 3x mais orçamentos.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF78350F), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
