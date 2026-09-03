import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../provedores/estado_global.dart';
import '../../servicos/supabase_service.dart';
import '../../servicos/validacao_service.dart';
import '../../servicos/imagem_service.dart';
import '../../servicos/auth_service.dart';
import '../../temas/cores_novo.dart';
import '../../widgets/botao_novo.dart';
import '../../widgets/badge_gb_novo.dart';
import 'tela_dashboard_novo.dart';
import '../../modelos/usuario_model.dart';

class TelaFormularioProfissional extends StatefulWidget {
  const TelaFormularioProfissional({super.key});

  @override
  State<TelaFormularioProfissional> createState() => _TelaFormularioProfissionalState();
}

class _TelaFormularioProfissionalState extends State<TelaFormularioProfissional> {
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _outraProfissaoController = TextEditingController();
  final _outroBairroController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _carregando = false;
  File? _imagemSelecionada;
  final ImagePicker _picker = ImagePicker();
  final SupabaseService _supabaseService = SupabaseService();

  final List<String> _profissoes = [
    'Canalizador', 'Eletricista', 'Motorista', 'Cozinheira', 'Cabeleireira',
    'Pintor', 'Costureira', 'Babá', 'Jardineiro', 'Lavadeira', 'Outra',
  ];

  final List<String> _bairros = [
    'Bairro Militar', 'Belém', 'Quelélé', 'Luanda', 'Bairro de Ajuda',
    'Antula', 'Bissalanca', 'Cuntum', 'Pefine', 'Cupelom', 'Outro',
  ];

  String? _profissaoSelecionada;
  String? _bairroSelecionado;

  @override
  void initState() {
    super.initState();
    final usuario = Provider.of<EstadoGlobal>(context, listen: false).usuarioLogado;
    if (usuario != null) {
      _nomeController.text = usuario.nomeUsuario;
      _telefoneController.text = usuario.telefoneUsuario.replaceAll('+245', '').trim();
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _descricaoController.dispose();
    _outraProfissaoController.dispose();
    _outroBairroController.dispose();
    super.dispose();
  }

  Future<void> _escolherFoto() async {
    final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (img != null) setState(() => _imagemSelecionada = File(img.path));
  }

  Future<void> _concluir() async {
    if (!_formKey.currentState!.validate()) return;

    if (_profissaoSelecionada == null || _bairroSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos obrigatórios.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      final estado = Provider.of<EstadoGlobal>(context, listen: false);
      final usuario = estado.usuarioLogado!;

      final profissao = _profissaoSelecionada == 'Outra' ? _outraProfissaoController.text.trim() : _profissaoSelecionada!;
      final bairro = _bairroSelecionado == 'Outro' ? _outroBairroController.text.trim() : _bairroSelecionado!;

      final descricaoCompleta = '${_descricaoController.text.trim()}\n\n'
          '📞 ${_telefoneController.text.trim()}\n'
          '📍 Bairro: $bairro';

      String? fotoUrl;
      if (_imagemSelecionada != null) {
        final imagemComprimida = await ImagemService.comprimirImagem(_imagemSelecionada!);
        if (imagemComprimida != null) {
          fotoUrl = await _supabaseService.uploadFoto(imagemComprimida.path);
        }
      }

      // 1. Criar o registo de trabalhador (Perfil Profissional)
      await _supabaseService.criarTrabalhador(
        nomeTrabalhador: _nomeController.text.trim(),
        profissaoTrabalhador: profissao,
        descricaoTrabalhador: descricaoCompleta,
        lat: usuario.lat ?? 0,
        lng: usuario.lng ?? 0,
        fotoTrabalhador: fotoUrl,
        utilizadorId: usuario.id,
      );

      // 2. Ativar modo profissional no estado e banco
      estado.ativarModoProfissional();
      await AuthService().atualizarModoUtilizacao(usuario.id, true);
      
      // 3. Atualizar profissão e foto no perfil do utilizador
      await _supabaseService.atualizarProfissao(usuario.id, profissao);
      if (fotoUrl != null) {
        await _supabaseService.atualizarFotoPerfil(usuario.id, fotoUrl);
      }

      // 4. Atualizar o objeto local para refletir as mudanças imediatamente no Dashboard
      final usuarioAtualizado = UsuarioModel(
        id: usuario.id,
        nomeUsuario: usuario.nomeUsuario,
        emailUsuario: usuario.emailUsuario,
        telefoneUsuario: usuario.telefoneUsuario,
        fotoUsuario: fotoUrl ?? usuario.fotoUsuario,
        tipoUsuario: 'profissional',
        profissao: profissao,
        lat: usuario.lat,
        lng: usuario.lng,
        modoProfissional: true,
      );
      estado.definirUsuarioLogado(usuarioAtualizado);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const TelaDashboardNovo()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar perfil: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CoresNovo.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CoresNovo.navyPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Perfil de Profissional', style: TextStyle(color: CoresNovo.navyPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Completa os teus dados',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CoresNovo.navyPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Estas informações serão visíveis para os clientes que procurarem os teus serviços.',
                style: TextStyle(fontSize: 14, color: CoresNovo.textSecondary),
              ),
              const SizedBox(height: 32),

              // FOTO
              Center(
                child: GestureDetector(
                  onTap: _escolherFoto,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: CoresNovo.blueLight,
                        backgroundImage: _imagemSelecionada != null ? FileImage(_imagemSelecionada!) : null,
                        child: _imagemSelecionada == null 
                            ? const Icon(Icons.add_a_photo_outlined, size: 32, color: CoresNovo.navyPrimary)
                            : null,
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: CoresNovo.starYellow, shape: BoxShape.circle),
                          child: const Icon(Icons.edit, size: 18, color: CoresNovo.navyPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              _buildLabel('A tua Profissão principal *'),
              DropdownButtonFormField<String>(
                value: _profissaoSelecionada,
                decoration: const InputDecoration(hintText: 'Seleciona a tua área'),
                items: _profissoes.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => setState(() => _profissaoSelecionada = v),
              ),
              if (_profissaoSelecionada == 'Outra') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _outraProfissaoController,
                  decoration: const InputDecoration(hintText: 'Qual a tua profissão?'),
                ),
              ],

              const SizedBox(height: 20),
              _buildLabel('O teu Bairro de atuação *'),
              DropdownButtonFormField<String>(
                value: _bairroSelecionado,
                decoration: const InputDecoration(hintText: 'Seleciona o bairro'),
                items: _bairros.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (v) => setState(() => _bairroSelecionado = v),
              ),
              if (_bairroSelecionado == 'Outro') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _outroBairroController,
                  decoration: const InputDecoration(hintText: 'Nome do bairro'),
                ),
              ],

              const SizedBox(height: 20),
              _buildLabel('Telefone de contacto *'),
              TextFormField(
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '955 123 456',
                  prefixIcon: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: BadgeGBNovo()),
                  prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                ),
                validator: (v) => ValidacaoService.validarTelefone(v ?? '') ? null : 'Número inválido',
              ),

              const SizedBox(height: 20),
              _buildLabel('Descrição do teu serviço (opcional)'),
              TextFormField(
                controller: _descricaoController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Ex: Faço instalações elétricas, reparação de curtos-circuitos e montagem de painéis solares...',
                ),
              ),

              const SizedBox(height: 40),
              BotaoNovo(
                texto: 'Concluir e Ativar Modo Profissional',
                isLoading: _carregando,
                onPressed: _carregando ? null : _concluir,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: CoresNovo.navyPrimary)),
    );
  }
}
