import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'provedores/estado_global.dart';
import 'telas/tela_feed.dart';
import 'telas/tela_painel_profissional.dart';
import 'servicos/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kmtrhcuarprwovueqnmg.supabase.co',
    anonKey: 'sb_publishable_nQRcQO49GKcYXHeO4JBZkg_qkryHtMU',
  );

  runApp(const WorkGBApp());
}

class WorkGBApp extends StatelessWidget {
  const WorkGBApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EstadoGlobal(),
      child: MaterialApp(
        title: 'WorkGB',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB),
          ),
        ),
        home: const RotaInicial(),
      ),
    );
  }
}

class RotaInicial extends StatefulWidget {
  const RotaInicial({super.key});

  @override
  State<RotaInicial> createState() => _RotaInicialState();
}

class _RotaInicialState extends State<RotaInicial> {
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _verificarSessao();
  }

  Future<void> _verificarSessao() async {
    final authService = AuthService();

    try {
      final utilizador = await authService.obterUtilizadorAtual();

      if (utilizador != null && mounted) {
        Provider.of<EstadoGlobal>(context, listen: false)
            .definirUsuarioLogado(utilizador);
      }
    } catch (e) {
      // Sessão não existe ou expirou — continua sem login
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2563EB)),
        ),
      );
    }

    final estado = Provider.of<EstadoGlobal>(context);

    if (estado.estaLogado) {
      return const TelaPainelProfissional();
    } else {
      return const TelaFeed();
    }
  }
}
