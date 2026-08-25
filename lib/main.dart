import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'provedores/estado_global.dart';
import 'telas/tela_feed.dart';
import 'telas/tela_painel_profissional.dart';
import 'servicos/auth_service.dart';
import 'servicos/servico_atualizacao.dart';

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
          brightness: Brightness.light,
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: Colors.white,
          cardColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB),
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: const Color(0xFF121212),
          cardColor: const Color(0xFF2A2D30),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB),
            brightness: Brightness.dark,
          ),
        ),
        themeMode: ThemeMode.system,
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

  Future<void> _verificarAtualizacao() async {
    final atualizacaoDisponivel = await ServicoAtualizacao.verificarAtualizacao();

    if (atualizacaoDisponivel && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Nova versão disponível!'),
          content: const Text('Há uma nova versão do WorkGB com correções e melhorias. Deseja atualizar agora?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Agora não'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ServicoAtualizacao.abrirDownload();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Atualizar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
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
      if (mounted) {
        setState(() => _carregando = false);
        _verificarAtualizacao();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
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
