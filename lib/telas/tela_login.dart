import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'tela_cadastro.dart';
import '../provedores/estado_global.dart';
import '../servicos/auth_service.dart';
import '../servicos/supabase_service.dart';
import '../main.dart';
import 'tela_painel_profissional.dart';
import '../servicos/responsividade.dart';
import '../servicos/servico_erros.dart';

final AuthService _authService = AuthService();

/// Tela de login do Lirify
/// Permite entrar com email ou telefone e senha
class TelaLogin extends StatefulWidget {
  final String tipoLogin; // 'cliente' ou 'profissional'

  const TelaLogin({super.key, this.tipoLogin = 'cliente'});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _emailOuTelefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;
  bool _senhaVisivel = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailOuTelefoneController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  /// Função que executa o login ao pressionar o botão
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      final usuario = await _authService.loginUsuario(
        emailUsuario: _emailOuTelefoneController.text.trim(),
        senhaUsuario: _senhaController.text,
      );

      print('DEBUG LOGIN: Tela de login: ${widget.tipoLogin}');
      print('DEBUG LOGIN: Conta do usuário: ${usuario.tipoUsuario}');
      print('DEBUG LOGIN: Coincidem? ${usuario.tipoUsuario == widget.tipoLogin}');

      // LÓGICA DE BLOQUEIO: Se o tipo da conta NÃO coincide com o tipo da tela, NEGA o login
      if (usuario.tipoUsuario != widget.tipoLogin) {
        throw Exception('Esta conta não é de ${widget.tipoLogin}.');
      }

      if (mounted) {
        Provider.of<EstadoGlobal>(context, listen: false)
            .definirUsuarioLogado(usuario);

        // Buscar notificações pendentes imediatamente após login bem-sucedido
        _verificarNotificacoesPendentes(usuario.id);

        // Recalcular total de badges após login para sincronizar Provider
        Future.delayed(const Duration(milliseconds: 500), () async {
          final total = await SupabaseService().obterTotalConversasNaoLidas(usuario.id);
          if (mounted) {
            Provider.of<EstadoGlobal>(context, listen: false).atualizarTotalConversas(total);
          }
        });

        if (usuario.tipoUsuario == 'profissional') {
          // Navega para o Painel do Profissional
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => TelaPainelProfissional()),
          );
        } else {
          // Navega para o Feed
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        final mensagem = ServicoErros.obterMensagemAmigavel(e);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensagem),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  /// Função que busca e mostra notificações pendentes acumuladas enquanto offline
  Future<void> _verificarNotificacoesPendentes(String utilizadorId) async {
    final supabaseService = SupabaseService();
    
    try {
      print('DEBUG: Buscando pendentes para: $utilizadorId');
      final pendentes = await supabaseService.obterNotificacoesPendentes(utilizadorId);
      print('DEBUG: Pendentes encontradas: ${pendentes.length}');

      if (pendentes.isNotEmpty) {
        for (final pendente in pendentes) {
          print('DEBUG: Mostrando notificação pendente...');
          
          const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
            'mensagens_channel',
            'Mensagens',
            channelDescription: 'Notificações de mensagens do Lirify',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          );

          final NotificationDetails details = NotificationDetails(android: androidDetails);

          // Mostrar notificação local
          await flutterLocalNotificationsPlugin.show(
            DateTime.now().millisecondsSinceEpoch ~/ 1000,
            pendente['titulo'].toString(),
            pendente['mensagem'].toString(),
            details,
          );

          print('DEBUG: Notificação mostrada');
          
          // Apagar do banco após mostrar
          await supabaseService.apagarNotificacaoPendente(pendente['id']);
          print('DEBUG: Pendente apagada');
          
          // Intervalo de 3 segundos entre notificações para o utilizador conseguir ler
          await Future.delayed(const Duration(seconds: 3));
        }
      }
    } catch (e) {
      print('Erro ao buscar notificações pendentes no login: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: Responsividade.paddingHorizontal(context),
                vertical: 40,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ---------- TÍTULO ----------
                    Text(
                      'Lirify',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.tipoLogin == 'profissional'
                          ? 'Entra como Profissional'
                          : 'Entra na tua conta',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // ---------- CAMPO EMAIL OU TELEFONE ----------
                    TextFormField(
                      controller: _emailOuTelefoneController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email ou Telefone',
                        hintText: 'Ex: joao@email.com ou 955123456',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.trim().isEmpty) {
                          return 'Campo obrigatório';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ---------- CAMPO SENHA ----------
                    TextFormField(
                      controller: _senhaController,
                      obscureText: !_senhaVisivel,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _senhaVisivel ? Icons.visibility : Icons.visibility_off,
                            color: const Color(0xFF2563EB),
                          ),
                          onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
                        ),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.isEmpty) {
                          return 'A senha é obrigatória';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // ---------- BOTÃO ENTRAR ----------
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _carregando ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFF2563EB).withOpacity(0.3),
                        ),
                        child: _carregando
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ---------- LINK PARA CADASTRO ----------
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _TelaCadastroWrapper(tipoLogin: widget.tipoLogin),
                          ),
                        );
                      },
                      child: Text(
                        'Ainda não tens conta? Cria uma',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Wrapper que usa a TelaCadastro existente
class _TelaCadastroWrapper extends StatelessWidget {
  final String tipoLogin;
  const _TelaCadastroWrapper({required this.tipoLogin});

  @override
  Widget build(BuildContext context) {
    return TelaCadastro(tipoLogin: tipoLogin);
  }
}
