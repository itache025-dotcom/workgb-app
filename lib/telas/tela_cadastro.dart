import '../servicos/localizacao_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedores/estado_global.dart';
import '../servicos/auth_service.dart';
import '../servicos/validacao_service.dart';
import 'tela_feed.dart';
import '../servicos/responsividade.dart';

/// Tela de cadastro do WorkGB
/// Recolhe nome, email, telefone, senha e localização GPS do utilizador
class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  // Controladores para os campos de texto
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  // Estado de carregamento
  final AuthService _authService = AuthService();
  bool _carregando = false;
  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;

  // Chave do formulário para validação
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  /// Função que executa o cadastro ao pressionar o botão
  Future<void> _cadastrar() async {
    // Valida o formulário
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      // Tenta obter localização, mas continua sem ela caso falhe
      double lat = 0;
      double lng = 0;
      try {
        final localizacao = await LocalizacaoService.obterLocalizacao();
        lat = localizacao['lat']!;
        lng = localizacao['lng']!;
      } catch (e) {
        // Localização negada ou desativada — continua sem ela
      }

      // Chama o AuthService para cadastrar
      final usuario = await _authService.cadastrarUsuario(
        nomeUsuario: _nomeController.text.trim(),
        emailUsuario: _emailController.text.trim(),
        telefoneUsuario: _telefoneController.text.trim(),
        senhaUsuario: _senhaController.text,
        lat: lat,
        lng: lng,
      );

      // Guarda o utilizador no EstadoGlobal
      // Guarda o utilizador no EstadoGlobal e navega para a TelaFeed
      if (mounted) {
        Provider.of<EstadoGlobal>(context, listen: false)
            .definirUsuarioLogado(usuario);

        // Navega para a TelaFeed e remove todas as telas anteriores
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const TelaFeed()),
              (route) => false,
        );
      }
    } catch (e) {
      // Mostra erro se algo correr mal
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A3C6E)),
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
                  'WorkGB',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A3C6E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Cria a tua conta',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // ---------- CAMPO NOME ----------
                TextFormField(
                  controller: _nomeController,
                  decoration: InputDecoration(
                    labelText: 'Nome completo',
                    hintText: 'Ex: João Mendes',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'O nome é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ---------- CAMPO EMAIL ----------
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Ex: joao@email.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'O email é obrigatório';
                    }
                    if (!valor.contains('@')) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ---------- CAMPO TELEFONE ----------
                TextFormField(
                  controller: _telefoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Telefone',
                    hintText: 'Ex: 955123456',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'O telefone é obrigatório';
                    }
                    if (!ValidacaoService.validarTelefone(valor.trim())) {
                      return 'Número inválido. Use formato GB: 955 123 456';
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
                    if (valor.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ---------- CAMPO CONFIRMAR SENHA ----------
                TextFormField(
                  controller: _confirmarSenhaController,
                  obscureText: !_confirmarSenhaVisivel,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _confirmarSenhaVisivel ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFF2563EB),
                      ),
                      onPressed: () => setState(() => _confirmarSenhaVisivel = !_confirmarSenhaVisivel),
                    ),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Confirma a tua senha';
                    }
                    if (valor != _senhaController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // ---------- BOTÃO CADASTRAR ----------
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _cadastrar,
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
                      'Criar Conta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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