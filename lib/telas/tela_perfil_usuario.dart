import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedores/estado_global.dart';
import '../servicos/auth_service.dart';
import 'tela_editar_perfil.dart';
import 'tela_feed.dart';
import '../main.dart';

/// Tela de perfil do utilizador logado
/// Mostra dados e permite terminar sessão
class TelaPerfilUsuario extends StatelessWidget {
  const TelaPerfilUsuario({super.key});

  Future<void> _terminarSessao(BuildContext context) async {
    final authService = AuthService();

    // Confirmação
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Terminar Sessão'),
        content: const Text('Tens a certeza que queres sair da tua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
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
      pararNotificacoesTempoReal(); // Parar o stream global do Supabase

      if (context.mounted) {
        Provider.of<EstadoGlobal>(context, listen: false).limparUsuarioLogado();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => TelaFeed()),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Meu Perfil',
          style: TextStyle(fontFamily: 'Poppins', color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Foto de perfil (placeholder)
            Center(
              child: CircleAvatar(
                radius: 56,
                backgroundColor: const Color(0xFF2563EB),
                child: Text(
                  usuario?.nomeUsuario.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Nome
            Center(
              child: Text(
                usuario?.nomeUsuario ?? 'Utilizador',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Card com informações
            Container(
              padding: const EdgeInsets.all(16),
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
                children: [
                  _buildInfoRow(context, Icons.email_outlined, 'Email', usuario?.emailUsuario ?? ''),
                  const Divider(height: 24),
                  _buildInfoRow(context, Icons.phone_outlined, 'Telefone', usuario?.telefoneUsuario ?? ''),
                  const Divider(height: 24),
                  _buildInfoRow(context, Icons.location_on_outlined, 'Localização', 'Guiné-Bissau'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Botão editar perfil
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TelaEditarPerfil()),
                  );
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  'Editar Perfil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Botão Ver Trabalhadores
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => TelaFeed()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.people_outline, color: Colors.white),
                label: const Text(
                  'Ver Trabalhadores',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Botão terminar sessão
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _terminarSessao(context),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Terminar Sessão',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String valor) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2563EB), size: 22),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              valor.isEmpty ? 'Não definido' : valor,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
