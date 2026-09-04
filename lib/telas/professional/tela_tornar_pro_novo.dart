import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provedores/estado_global.dart';
import '../../temas/cores_novo.dart';
import '../../widgets/botao_novo.dart';
import '../../widgets/logo_novo.dart';
import '../tela_cadastro_novo.dart';
import '../tela_login_novo.dart';
import '../tela_novo_card.dart';
import 'tela_formulario_profissional.dart';

class TelaTornarProNovo extends StatefulWidget {
  const TelaTornarProNovo({super.key});

  @override
  State<TelaTornarProNovo> createState() => _TelaTornarProNovoState();
}

class _TelaTornarProNovoState extends State<TelaTornarProNovo> {
  @override
  Widget build(BuildContext context) {
    final estado = Provider.of<EstadoGlobal>(context);
    final estaLogado = estado.estaLogado;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CoresNovo.navyPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const LogoNovo(fontSize: 28),
              const SizedBox(height: 40),
              const Text(
                'Tornar-me Profissional',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: CoresNovo.navyPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Aumente os seus ganhos e visibilidade no maior marketplace da Guiné-Bissau.',
                style: TextStyle(color: CoresNovo.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Benefícios
              _buildBenefitRow(Icons.rocket_launch_outlined, 'Destaque no Feed', 'Seja visto por mais clientes.'),
              const SizedBox(height: 20),
              _buildBenefitRow(Icons.chat_bubble_outline, 'Chat Direto', 'Negoceie com clientes em tempo real.'),
              const SizedBox(height: 20),
              _buildBenefitRow(Icons.star_outline, 'Reputação', 'Ganhe selos de confiança e avaliações.'),
              
              const SizedBox(height: 56),

              BotaoNovo(
                texto: estaLogado ? 'Completar Perfil Profissional' : 'Criar Conta de Profissional',
                onPressed: () {
                  if (estaLogado) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TelaFormularioProfissional()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TelaCadastroNovo(profissional: true)),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              if (!estaLogado)
                BotaoOutlinedNovo(
                  texto: 'Já tenho conta',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TelaLoginNovo()),
                    );
                  },
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String title, String desc) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: CoresNovo.navyPrimary.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: CoresNovo.navyPrimary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: CoresNovo.navyPrimary)),
              Text(desc, style: const TextStyle(fontSize: 12, color: CoresNovo.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}
