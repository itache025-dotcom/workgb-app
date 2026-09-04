import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../provedores/estado_global.dart';
import '../servicos/auth_service.dart';
import '../servicos/supabase_service.dart';
import '../servicos/imagem_service.dart';
import '../modelos/usuario_model.dart';
import '../temas/cores_novo.dart';
import '../widgets/botao_novo.dart';
import 'tela_feed_novo.dart';
import 'tela_novo_card.dart';
import 'tela_conversas_novo.dart';
import 'tela_pesquisa_novo.dart';
import '../widgets/bottom_nav_novo.dart';
import 'professional/tela_dashboard_novo.dart';
import 'professional/tela_negocio_novo.dart';
import 'professional/tela_tornar_pro_novo.dart';
import 'professional/tela_formulario_profissional.dart';

class TelaPerfilUsuarioNovo extends StatefulWidget {
  const TelaPerfilUsuarioNovo({super.key});

  @override
  State<TelaPerfilUsuarioNovo> createState() => _TelaPerfilUsuarioNovoState();
}

class _TelaPerfilUsuarioNovoState extends State<TelaPerfilUsuarioNovo> {
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _senhaController;
  
  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final SupabaseService _supabaseService = SupabaseService();
  bool _processandoModo = false;
  bool _mostrarSenhas = false;
  bool _carregandoSenha = false;
  bool _carregandoPerfil = false;
  File? _novaFoto;

  @override
  void initState() {
    super.initState();
    final estado = Provider.of<EstadoGlobal>(context, listen: false);
    final usuario = estado.usuarioLogado;
    _nomeController = TextEditingController(text: usuario?.nomeUsuario ?? '');
    _emailController = TextEditingController(text: usuario?.emailUsuario ?? '');
    _senhaController = TextEditingController(text: '********');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _escolherFoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (img != null) {
      setState(() => _novaFoto = File(img.path));
    }
  }

  Future<void> _guardarAlteracoes() async {
    final estado = Provider.of<EstadoGlobal>(context, listen: false);
    final usuario = estado.usuarioLogado;
    if (usuario == null) return;

    setState(() => _carregandoPerfil = true);

    try {
      String? fotoUrl = usuario.fotoUsuario;

      if (_novaFoto != null) {
        final comprimida = await ImagemService.comprimirImagem(_novaFoto!);
        if (comprimida != null) {
          fotoUrl = await _supabaseService.uploadFoto(comprimida.path);
          await _supabaseService.atualizarFotoPerfil(usuario.id, fotoUrl!);
        }
      }

      await AuthService().atualizarPerfil(
        id: usuario.id,
        nomeUsuario: _nomeController.text.trim(),
        emailUsuario: _emailController.text.trim(),
        telefoneUsuario: usuario.telefoneUsuario, // Mantém o telefone atual ou edita se houver campo
      );

      // Atualizar objeto local no Provider
      final usuarioAtualizado = UsuarioModel(
        id: usuario.id,
        nomeUsuario: _nomeController.text.trim(),
        emailUsuario: _emailController.text.trim(),
        telefoneUsuario: usuario.telefoneUsuario,
        fotoUsuario: fotoUrl,
        tipoUsuario: usuario.tipoUsuario,
        profissao: usuario.profissao,
        lat: usuario.lat,
        lng: usuario.lng,
        modoProfissional: usuario.modoProfissional,
      );

      estado.definirUsuarioLogado(usuarioAtualizado);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Volta para a tela anterior (Dashboard ou Feed)
      }
    } catch (e) {
      print('Erro ao atualizar perfil: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar perfil. Tente novamente.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _carregandoPerfil = false);
    }
  }

  Future<void> _mudarSenha() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregandoSenha = true);

    try {
      await AuthService().mudarSenha(
        senhaAntiga: _senhaAtualController.text,
        novaSenha: _novaSenhaController.text,
      );

      if (mounted) {
        _senhaAtualController.clear();
        _novaSenhaController.clear();
        _confirmarSenhaController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha alterada com sucesso!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        String mensagem = 'Erro ao mudar senha. Tente novamente.';
        if (e.toString().contains('invalid_credentials')) {
          mensagem = 'Senha atual incorreta. Tente novamente.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _carregandoSenha = false);
    }
  }

  Future<void> _alternarModo(bool valor) async {
    final estado = Provider.of<EstadoGlobal>(context, listen: false);
    final usuario = estado.usuarioLogado;

    if (usuario == null) return;

    estado.alternarModo();
    AuthService().atualizarModoUtilizacao(usuario.id, valor);

    if (valor) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => TelaDashboardNovo()),
          (r) => false,
        );
      }
    } else {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => TelaFeedNovo()),
          (r) => false,
        );
      }
    }
  }

  Future<void> _terminarSessao(BuildContext context) async {
    final authService = AuthService();

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
            style: ElevatedButton.styleFrom(backgroundColor: CoresNovo.error),
            child: const Text('Sair', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      // Em modo de teste, apenas limpamos o estado local
      Provider.of<EstadoGlobal>(context, listen: false).limparUsuarioLogado();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => TelaFeedNovo()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = Provider.of<EstadoGlobal>(context);
    final usuario = estado.usuarioLogado;

    return Scaffold(
      backgroundColor: CoresNovo.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CoresNovo.navyPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Meu Perfil',
          style: TextStyle(fontWeight: FontWeight.bold, color: CoresNovo.navyPrimary),
        ),
      ),
      bottomNavigationBar: BottomNavNovo(
        currentIndex: estado.modoProfissional ? 3 : 3, // Perfil é o último em ambos (4º item)
        onTap: (i) {
          if (estado.modoProfissional) {
            if (i == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TelaDashboardNovo()));
            if (i == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TelaConversasNovo()));
            if (i == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TelaNegocioNovo()));
          } else {
            if (i == 0) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => TelaFeedNovo()), (r) => false);
            if (i == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TelaPesquisaNovo()));
            if (i == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TelaConversasNovo()));
          }
        },
        isProfessional: estado.modoProfissional,
        unreadMessages: estado.totalConversasNaoLidas,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                // Foto e Cabeçalho
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: _escolherFoto,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: CoresNovo.navyPrimary,
                              backgroundImage: _novaFoto != null 
                                  ? FileImage(_novaFoto!) 
                                  : (usuario?.fotoUsuario != null ? NetworkImage(usuario!.fotoUsuario!) : null) as ImageProvider?,
                              child: _novaFoto == null && (usuario?.fotoUsuario == null || usuario!.fotoUsuario!.isEmpty)
                                  ? Text(
                                      (usuario?.nomeUsuario != null && usuario!.nomeUsuario.isNotEmpty) ? usuario.nomeUsuario.substring(0, 1).toUpperCase() : 'U',
                                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _escolherFoto,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: CoresNovo.starYellow, shape: BoxShape.circle),
                                child: const Icon(Icons.edit, size: 20, color: CoresNovo.navyPrimary),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        usuario?.nomeUsuario ?? 'Utilizador',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: CoresNovo.navyPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Alternador de Modo
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CoresNovo.border),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: SwitchListTile(
                      title: const Text('Modo Profissional', style: TextStyle(fontWeight: FontWeight.bold, color: CoresNovo.navyPrimary)),
                      subtitle: const Text('Ativa para gerir os teus serviços e receber pedidos'),
                      value: estado.modoProfissional,
                      activeColor: CoresNovo.navyPrimary,
                      onChanged: _processandoModo ? null : (v) => _alternarModo(v),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Campos de Edição
                _buildEditField('Nome', _nomeController, Icons.person_outline),
                const SizedBox(height: 16),
                _buildEditField('Email', _emailController, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildEditField('Palavra-passe', _senhaController, Icons.lock_outline, obscureText: true),
                const SizedBox(height: 24),

                BotaoNovo(
                  texto: 'Guardar Alterações',
                  isLoading: _carregandoPerfil,
                  onPressed: _carregandoPerfil ? null : _guardarAlteracoes,
                ),
                const SizedBox(height: 32),

            // --- SECÇÃO MUDAR SENHA ---
            const Divider(),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Segurança', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CoresNovo.navyPrimary)),
                  SizedBox(height: 4),
                  Text('Altera a tua palavra-passe regularmente para manter a conta segura.', style: TextStyle(fontSize: 13, color: CoresNovo.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildPasswordField('Palavra-passe atual', _senhaAtualController),
            const SizedBox(height: 16),
            _buildPasswordField('Nova Palavra-passe', _novaSenhaController),
            const SizedBox(height: 16),
            _buildPasswordField('Confirmar Nova Palavra-passe', _confirmarSenhaController, isConfirm: true),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _carregandoSenha ? null : _mudarSenha,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CoresNovo.navyPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _carregandoSenha 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Guardar Nova Senha', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            if (!estado.modoProfissional)
                  BotaoOutlinedNovo(
                    texto: 'Tornar-se Profissional',
                    icon: const Icon(Icons.business_center_outlined, size: 18),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => TelaTornarProNovo()));
                    },
                  ),
                
                const SizedBox(height: 32),

                BotaoNovo(
                  texto: 'Terminar Sessão',
                  backgroundColor: CoresNovo.error.withOpacity(0.1),
                  textColor: CoresNovo.error,
                  onPressed: () => _terminarSessao(context),
                ),
              ],
            ),
          ),
        ),
          if (_processandoModo)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType, bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: CoresNovo.navyPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: CoresNovo.navyPrimary, size: 20),
            fillColor: Colors.white,
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, {bool isConfirm = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: CoresNovo.navyPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !_mostrarSenhas,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline, color: CoresNovo.navyPrimary, size: 20),
            suffixIcon: IconButton(
              icon: Icon(_mostrarSenhas ? Icons.visibility : Icons.visibility_off, color: CoresNovo.textSecondary, size: 20),
              onPressed: () => setState(() => _mostrarSenhas = !_mostrarSenhas),
            ),
            fillColor: Colors.white,
            filled: true,
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Este campo é obrigatório';
            if (!isConfirm && v.length < 6) return 'Mínimo 6 caracteres';
            if (isConfirm && v != _novaSenhaController.text) return 'As senhas não coincidem';
            return null;
          },
        ),
      ],
    );
  }
}
