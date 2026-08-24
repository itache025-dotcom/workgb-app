import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedores/estado_global.dart';
import '../servicos/auth_service.dart';
import 'tela_novo_card.dart';
import 'tela_meus_cards.dart';
import 'tela_editar_perfil.dart';
import 'tela_feed.dart';
import 'tela_minhas_avaliacoes.dart';

class TelaPainelProfissional extends StatelessWidget {
  const TelaPainelProfissional({super.key});

  Future<void> _terminarSessao(BuildContext context) async {
    final authService = AuthService();
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Terminar Sessão'),
        content: const Text('Tens a certeza que queres sair da tua conta?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sair', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await authService.logout();
      if (context.mounted) {
        Provider.of<EstadoGlobal>(context, listen: false).limparUsuarioLogado();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const TelaFeed()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = Provider.of<EstadoGlobal>(context);
    final usuario = estado.usuarioLogado;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Painel do Profissional',
          style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF1A3C6E), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => _terminarSessao(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card de Boas-vindas
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      usuario?.nomeUsuario.substring(0, 1).toUpperCase() ?? 'P',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, ${usuario?.nomeUsuario.split(' ')[0] ?? 'Profissional'}!',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Gere os teus serviços e perfil aqui.',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Ferramentas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A3C6E)),
            ),
            const SizedBox(height: 16),

            // Grid de Botões
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildMenuButton(
                  context,
                  icon: Icons.add_business_outlined,
                  label: 'Publicar\nServiço',
                  color: Colors.orange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaNovoCard())),
                ),
                _buildMenuButton(
                  context,
                  icon: Icons.credit_card_outlined,
                  label: 'Meus\nCards',
                  color: Colors.blue,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaMeusCards())),
                ),
                _buildMenuButton(
                  context,
                  icon: Icons.person_search_outlined,
                  label: 'Ver\nTrabalhadores',
                  color: Colors.green,
                  onTap: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaFeed()),
                    (route) => false,
                  ),
                ),
                _buildMenuButton(
                  context,
                  icon: Icons.manage_accounts_outlined,
                  label: 'Editar\nPerfil',
                  color: Colors.purple,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaEditarPerfil())),
                ),
                _buildMenuButton(
                  context,
                  icon: Icons.star_outline,
                  label: 'Minhas\nAvaliações',
                  color: Colors.amber,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaMinhasAvaliacoes())),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Info do Utilizador
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildInfoItem(Icons.email_outlined, usuario?.emailUsuario ?? ''),
                  const Divider(),
                  _buildInfoItem(Icons.phone_outlined, usuario?.telefoneUsuario ?? 'Não definido'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A3C6E)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF1A3C6E))),
      ],
    );
  }
}
