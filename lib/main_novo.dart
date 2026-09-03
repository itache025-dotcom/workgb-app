import 'package:flutter/material.dart';
import 'temas/tema_novo.dart';
import 'telas/tela_feed_novo.dart';
import 'telas/tela_login_novo.dart';
import 'telas/tela_cadastro_novo.dart';
import 'telas/tela_perfil_novo.dart';
import 'telas/tela_chat_novo.dart';
import 'telas/professional/tela_dashboard_novo.dart';
import 'telas/professional/tela_leads_novo.dart';
import 'telas/professional/tela_negocio_novo.dart';
import 'telas/professional/tela_tornar_pro_novo.dart';
import 'modelos/trabalhador_model.dart';

void main() {
  runApp(const WorkGBShowcaseApp());
}

class WorkGBShowcaseApp extends StatelessWidget {
  const WorkGBShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkGB Novo Design Showcase',
      debugShowCheckedModeBanner: false,
      theme: TemaNovo.lightTheme,
      darkTheme: TemaNovo.darkTheme,
      themeMode: ThemeMode.light,
      home: const MenuTesteNovoDesign(),
    );
  }
}

class MenuTesteNovoDesign extends StatelessWidget {
  const MenuTesteNovoDesign({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste Novo Design'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Header('Telas do Cliente'),
          _BotaoMenu('Feed Principal', const TelaFeedNovo(), context),
          _BotaoMenu('Login', const TelaLoginNovo(), context),
          _BotaoMenu('Cadastro', const TelaCadastroNovo(), context),
          _BotaoMenu('Perfil do Profissional', TelaPerfilNovo(trabalhador: TrabalhadorModel(id: '0', nomeTrabalhador: 'Braima Cassamá', profissaoTrabalhador: 'Eletricista')), context),
          _BotaoMenu('Chat Privado', TelaChatNovo(trabalhador: TrabalhadorModel(id: '0', nomeTrabalhador: 'Braima Cassamá', profissaoTrabalhador: 'Eletricista')), context),
          
          const SizedBox(height: 24),
          const _Header('Telas do Profissional'),
          _BotaoMenu('Dashboard (Início)', const TelaDashboardNovo(), context),
          // _BotaoMenu('Gestão de Pedidos (Leads)', const TelaLeadsNovo(), context),
          _BotaoMenu('Meu Negócio (Serviços/Galeria)', const TelaNegocioNovo(), context),
          _BotaoMenu('Tornar-se Profissional', const TelaTornarProNovo(), context),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String titulo;
  const _Header(this.titulo);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        titulo,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

class _BotaoMenu extends StatelessWidget {
  final String label;
  final Widget tela;
  final BuildContext context;

  const _BotaoMenu(this.label, this.tela, this.context);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => tela),
          );
        },
      ),
    );
  }
}
