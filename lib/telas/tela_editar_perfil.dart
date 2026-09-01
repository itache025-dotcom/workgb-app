import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedores/estado_global.dart';
import '../servicos/auth_service.dart';
import '../servicos/validacao_service.dart';
import '../servicos/servico_erros.dart';

class TelaEditarPerfil extends StatefulWidget {
  const TelaEditarPerfil({super.key});

  @override
  State<TelaEditarPerfil> createState() => _TelaEditarPerfilState();
}

class _TelaEditarPerfilState extends State<TelaEditarPerfil> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _telefoneController;
  
  final _senhaAntigaController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarNovaSenhaController = TextEditingController();

  bool _carregando = false;
  bool _senhaAntigaVisivel = false;
  bool _novaSenhaVisivel = false;
  bool _confirmarNovaSenhaVisivel = false;

  @override
  void initState() {
    super.initState();
    final usuario = Provider.of<EstadoGlobal>(context, listen: false).usuarioLogado;
    _nomeController = TextEditingController(text: usuario?.nomeUsuario ?? '');
    _emailController = TextEditingController(text: usuario?.emailUsuario ?? '');
    _telefoneController = TextEditingController(text: usuario?.telefoneUsuario ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaAntigaController.dispose();
    _novaSenhaController.dispose();
    _confirmarNovaSenhaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      final estado = Provider.of<EstadoGlobal>(context, listen: false);
      final usuario = estado.usuarioLogado!;

      // 1. Atualizar Perfil
      await _authService.atualizarPerfil(
        id: usuario.id,
        nomeUsuario: _nomeController.text.trim(),
        emailUsuario: _emailController.text.trim(),
        telefoneUsuario: _telefoneController.text.trim(),
      );

      // 2. Mudar Senha (se preenchido)
      if (_senhaAntigaController.text.isNotEmpty && _novaSenhaController.text.isNotEmpty) {
        await _authService.mudarSenha(
          senhaAntiga: _senhaAntigaController.text,
          novaSenha: _novaSenhaController.text,
        );
      }

      // 3. Atualizar Estado Global
      final usuarioAtualizado = await _authService.obterUtilizadorAtual();
      if (usuarioAtualizado != null && mounted) {
        estado.definirUsuarioLogado(usuarioAtualizado);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final mensagem = ServicoErros.obterMensagemAmigavel(e, contexto: 'mudar_senha');

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Editar Perfil', style: TextStyle(fontFamily: 'Poppins', color: Theme.of(context).colorScheme.onSurface)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // NOME
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome completo',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'O nome é obrigatório' : null,
              ),
              const SizedBox(height: 16),

              // EMAIL
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'O email é obrigatório';
                  if (!v.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // TELEFONE
              TextFormField(
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Telefone',
                  hintText: 'Ex: 955123456',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'O telefone é obrigatório';
                  if (!ValidacaoService.validarTelefone(v.trim())) return 'Número inválido (GB: 95/96)';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              Text('Mudar Senha', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 16),

              // SENHA ANTIGA
              TextFormField(
                controller: _senhaAntigaController,
                obscureText: !_senhaAntigaVisivel,
                decoration: InputDecoration(
                  labelText: 'Senha antiga',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_senhaAntigaVisivel ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF2563EB)),
                    onPressed: () => setState(() => _senhaAntigaVisivel = !_senhaAntigaVisivel),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // NOVA SENHA
              TextFormField(
                controller: _novaSenhaController,
                obscureText: !_novaSenhaVisivel,
                decoration: InputDecoration(
                  labelText: 'Nova senha (mínimo 6 caracteres)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.lock_open_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_novaSenhaVisivel ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF2563EB)),
                    onPressed: () => setState(() => _novaSenhaVisivel = !_novaSenhaVisivel),
                  ),
                ),
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // CONFIRMAR NOVA SENHA
              TextFormField(
                controller: _confirmarNovaSenhaController,
                obscureText: !_confirmarNovaSenhaVisivel,
                decoration: InputDecoration(
                  labelText: 'Confirmar nova senha',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.lock_reset_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_confirmarNovaSenhaVisivel ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF2563EB)),
                    onPressed: () => setState(() => _confirmarNovaSenhaVisivel = !_confirmarNovaSenhaVisivel),
                  ),
                ),
                validator: (v) {
                  if (_novaSenhaController.text.isNotEmpty && v != _novaSenhaController.text) {
                    return 'As senhas não coincidem';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // BOTÃO SALVAR
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: _carregando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Salvar Alterações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
