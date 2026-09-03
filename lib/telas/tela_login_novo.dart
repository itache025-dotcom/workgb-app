import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedores/estado_global.dart';
import '../servicos/auth_service.dart';
import '../servicos/servico_erros.dart';
import '../temas/cores_novo.dart';
import '../widgets/logo_novo.dart';
import '../widgets/botao_novo.dart';
import 'professional/tela_dashboard_novo.dart';
import 'tela_cadastro_novo.dart';
import 'tela_feed_novo.dart';

class TelaLoginNovo extends StatefulWidget {
  const TelaLoginNovo({super.key});

  @override
  State<TelaLoginNovo> createState() => _TelaLoginNovoState();
}

class _TelaLoginNovoState extends State<TelaLoginNovo> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _authService = AuthService();
  
  bool _obscureText = true;
  bool _rememberMe = true;
  bool _carregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      final usuario = await _authService.loginUsuario(
        emailUsuario: email,
        senhaUsuario: senha,
      );

      if (mounted) {
        Provider.of<EstadoGlobal>(context, listen: false).definirUsuarioLogado(usuario);

        if (usuario.tipoUsuario == 'profissional') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TelaDashboardNovo()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TelaFeedNovo()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final erroStr = e.toString();
        String mensagem = ServicoErros.obterMensagemAmigavel(e);
        
        if (erroStr.contains('SocketException') || 
            erroStr.contains('Failed host lookup') ||
            erroStr.contains('No address associated')) {
          mensagem = 'Sem conexão à internet. Verifica a tua ligação.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              const LogoNovo(fontSize: 32, showSubtitle: true),
              const SizedBox(height: 40),
              const Text(
                'Entrar na sua conta',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: CoresNovo.navyPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Acesse os melhores talentos e serviços da Guiné-Bissau',
                style: TextStyle(
                  color: CoresNovo.textSecondary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Email
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: CoresNovo.navyPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'exemplo@email.com',
                  prefixIcon: const Icon(Icons.email, color: CoresNovo.navyPrimary, size: 20),
                ),
              ),
              const SizedBox(height: 20),

              // Palavra-passe
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Palavra-passe',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: CoresNovo.navyPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _senhaController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: 'Digite a sua senha',
                  prefixIcon: const Icon(Icons.lock, color: CoresNovo.navyPrimary, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: CoresNovo.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (v) => setState(() => _rememberMe = v!),
                          activeColor: CoresNovo.navyPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Lembrar-me',
                        style: TextStyle(fontSize: 13, color: CoresNovo.textSecondary),
                      ),
                    ],
                  ),
                  const Text(
                    'Esqueceu a senha?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CoresNovo.blueSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              BotaoNovo(
                texto: 'Entrar',
                isLoading: _carregando,
                onPressed: _carregando ? null : _login,
              ),
              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Ainda não tens conta? ',
                    style: TextStyle(fontSize: 14, color: CoresNovo.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TelaCadastroNovo()),
                      );
                    },
                    child: const Text(
                      'Cria uma',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: CoresNovo.navyPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
