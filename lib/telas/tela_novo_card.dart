import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../provedores/estado_global.dart';
import '../servicos/supabase_service.dart';
import '../servicos/validacao_service.dart';
import '../servicos/imagem_service.dart';
import 'package:file_picker/file_picker.dart';
import '../servicos/responsividade.dart';

final SupabaseService _supabaseService = SupabaseService();


/// Tela profissional para criar um novo card de trabalhador
/// Com nome, foto, profissão, bairro, telefone e descrição
class TelaNovoCard extends StatefulWidget {
  const TelaNovoCard({super.key});


  @override
  State<TelaNovoCard> createState() => _TelaNovoCardState();
}

class _TelaNovoCardState extends State<TelaNovoCard> {
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _outraProfissaoController = TextEditingController();
  final _outroBairroController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _carregando = false;
  File? _imagemSelecionada;
  final ImagePicker _picker = ImagePicker();

  // Lista de profissões predefinidas
  final List<String> _profissoes = [
    'Canalizador',
    'Eletricista',
    'Motorista',
    'Cozinheira',
    'Cabeleireira',
    'Pintor',
    'Costureira',
    'Babá',
    'Jardineiro',
    'Lavadeira',
    'Outra',
  ];

  // Lista de bairros de Bissau
  final List<String> _bairros = [
    'Bairro Militar',
    'Belém',
    'Quelélé',
    'Luanda',
    'Bairro de Ajuda',
    'Antula',
    'Bissalanca',
    'Cuntum',
    'Pefine',
    'Cupelom',
    'Outro',
  ];

  String? _profissaoSelecionada;
  String? _bairroSelecionado;

  // Disponibilidade
  final List<String> _diasSemana = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
  final Set<String> _diasSelecionados = {};
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFim;

  // Documentos
  final List<File> _documentosSelecionados = [];

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _descricaoController.dispose();
    _outraProfissaoController.dispose();
    _outroBairroController.dispose();
    super.dispose();
  }

  /// Publica o card do trabalhador

  /// Abre a câmara ou galeria para escolher uma foto
  Future<void> _escolherFoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF2563EB)),
                title: const Text('Câmara'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final img = await _picker.pickImage(source: ImageSource.camera);
                  if (img != null) setState(() => _imagemSelecionada = File(img.path));
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF2563EB)),
                title: const Text('Galeria'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final img = await _picker.pickImage(source: ImageSource.gallery);
                  if (img != null) setState(() => _imagemSelecionada = File(img.path));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selecionarHora(bool inicio) async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora != null) {
      setState(() {
        if (inicio) _horaInicio = hora;
        else _horaFim = hora;
      });
    }
  }

  Future<void> _adicionarDocumentos() async {
    final resultado = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'docx', 'xlsx', 'pptx'],
    );

    if (resultado != null) {
      setState(() {
        _documentosSelecionados.addAll(resultado.paths.map((p) => File(p!)));
      });
    }
  }

  Widget _buildFileIcon(String path) {
    final extensao = path.toLowerCase().split('.').last;
    switch (extensao) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'docx':
      case 'doc':
        return const Icon(Icons.description, color: Colors.blue);
      case 'xlsx':
      case 'xls':
        return const Icon(Icons.table_chart, color: Colors.green);
      case 'pptx':
      case 'ppt':
        return const Icon(Icons.slideshow, color: Colors.orange);
      default:
        return const Icon(Icons.image, color: Color(0xFF2563EB));
    }
  }


  Future<void> _publicar() async {
    if (!_formKey.currentState!.validate()) return;

    // Valida profissão
    if (_profissaoSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleciona uma profissão'), backgroundColor: Colors.red),
      );
      return;
    }

    // Valida bairro
    if (_bairroSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleciona um bairro'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      final estado = Provider.of<EstadoGlobal>(context, listen: false);

      // Determina a profissão final
      final profissao = _profissaoSelecionada == 'Outra'
          ? _outraProfissaoController.text.trim()
          : _profissaoSelecionada!;

      // Constrói a descrição completa com bairro e telefone
      final bairro = _bairroSelecionado == 'Outro'
          ? _outroBairroController.text.trim()
          : _bairroSelecionado!;

      final descricaoCompleta = '${_descricaoController.text.trim()}\n\n'
          '📞 ${_telefoneController.text.trim()}\n'
          '📍 Bairro: $bairro';

      // Upload da foto se selecionada
      String? fotoUrl;
      if (_imagemSelecionada != null) {
        final imagemComprimida = await ImagemService.comprimirImagem(_imagemSelecionada!);
        if (imagemComprimida != null) {
          fotoUrl = await _supabaseService.uploadFoto(imagemComprimida.path);
        }
      }

      // Upload de documentos
      List<String> documentosUrls = [];
      if (_documentosSelecionados.isNotEmpty) {
        documentosUrls = await _supabaseService.uploadDocumentos(
          _documentosSelecionados.map((f) => f.path).toList(),
        );
      }

      await _supabaseService.criarTrabalhador(
        nomeTrabalhador: _nomeController.text.trim(),
        profissaoTrabalhador: profissao,
        descricaoTrabalhador: descricaoCompleta,
        lat: estado.usuarioLogado?.lat ?? 0,
        lng: estado.usuarioLogado?.lng ?? 0,
        fotoTrabalhador: fotoUrl,
        utilizadorId: estado.usuarioLogado!.id,
        disponibilidadeDias: _diasSelecionados.toList(),
        disponibilidadeInicio: _horaInicio?.format(context),
        disponibilidadeFim: _horaFim?.format(context),
        documentos: documentosUrls,
      ).timeout(const Duration(seconds: 20));

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            icon: const Icon(Icons.check_circle, color: Color(0xFF2563EB), size: 56),
            title: const Text('Card Publicado!'),
            content: const Text('O teu card foi publicado com sucesso e já está disponível para todos.'),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('OK', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
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
        title: const Text(
          'Criar o meu Card',
          style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF1A3C6E)),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(Responsividade.paddingHorizontal(context)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---------- FOTO ----------
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _escolherFoto,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF2563EB), width: 2),
                          image: _imagemSelecionada != null
                              ? DecorationImage(
                            image: FileImage(_imagemSelecionada!),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: _imagemSelecionada == null
                            ? const Icon(Icons.add_a_photo, size: 40, color: Color(0xFF2563EB))
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Adicionar foto',
                      style: TextStyle(fontSize: 14, color: const Color(0xFF2563EB), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ---------- NOME ----------
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome no Card',
                  hintText: 'Ex: João Mendes',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'O nome é obrigatório' : null,
              ),
              const SizedBox(height: 16),

              // ---------- PROFISSÃO (DROPDOWN) ----------
              DropdownButtonFormField<String>(
                value: _profissaoSelecionada,
                decoration: InputDecoration(
                  labelText: 'Profissão',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.work_outline),
                ),
                hint: const Text('Seleciona uma profissão'),
                items: _profissoes.map((p) {
                  return DropdownMenuItem(value: p, child: Text(p));
                }).toList(),
                onChanged: (v) {
                  setState(() => _profissaoSelecionada = v);
                },
              ),
              // Campo extra se escolher "Outra"
              if (_profissaoSelecionada == 'Outra') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _outraProfissaoController,
                  decoration: InputDecoration(
                    labelText: 'Qual a tua profissão?',
                    hintText: 'Escreve aqui...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    prefixIcon: const Icon(Icons.edit),
                  ),
                  validator: (v) {
                    if (_profissaoSelecionada == 'Outra' && (v == null || v.trim().isEmpty)) {
                      return 'Especifica a tua profissão';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),

              // ---------- TELEFONE ----------
              TextFormField(
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Número de telefone',
                  hintText: 'Ex: 955123456',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
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

              // ---------- BAIRRO (DROPDOWN) ----------
              DropdownButtonFormField<String>(
                value: _bairroSelecionado,
                decoration: InputDecoration(
                  labelText: 'Bairro',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                hint: const Text('Seleciona o teu bairro'),
                items: _bairros.map((b) {
                  return DropdownMenuItem(value: b, child: Text(b));
                }).toList(),
                onChanged: (v) {
                  setState(() => _bairroSelecionado = v);
                },
              ),
              // Campo extra se escolher "Outro"
              if (_bairroSelecionado == 'Outro') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _outroBairroController,
                  decoration: InputDecoration(
                    labelText: 'Qual o teu bairro?',
                    hintText: 'Escreve aqui...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    prefixIcon: const Icon(Icons.edit),
                  ),
                  validator: (v) {
                    if (_bairroSelecionado == 'Outro' && (v == null || v.trim().isEmpty)) {
                      return 'Especifica o teu bairro';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),

              // ---------- DESCRIÇÃO ----------
              TextFormField(
                controller: _descricaoController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Descrição do teu trabalho',
                  hintText: 'Descreve a tua experiência, serviços que ofereces, horários...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // ---------- DISPONIBILIDADE ----------
              const Text('Disponibilidade', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A3C6E))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _diasSemana.map((dia) {
                  final selecionado = _diasSelecionados.contains(dia);
                  return FilterChip(
                    label: Text(dia, style: TextStyle(fontSize: 12, color: selecionado ? Colors.white : Colors.black)),
                    selected: selecionado,
                    onSelected: (v) {
                      setState(() {
                        if (v) _diasSelecionados.add(dia);
                        else _diasSelecionados.remove(dia);
                      });
                    },
                    selectedColor: const Color(0xFF2563EB),
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Início', style: TextStyle(fontSize: 14)),
                      subtitle: Text(_horaInicio?.format(context) ?? '--:--', style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.access_time, color: Color(0xFF2563EB)),
                      onTap: () => _selecionarHora(true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Fim', style: TextStyle(fontSize: 14)),
                      subtitle: Text(_horaFim?.format(context) ?? '--:--', style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.access_time, color: Color(0xFF2563EB)),
                      onTap: () => _selecionarHora(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ---------- DOCUMENTOS ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Documentos (PDF/Imagens)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A3C6E))),
                  TextButton.icon(
                    onPressed: _adicionarDocumentos,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Adicionar'),
                  ),
                ],
              ),
              if (_documentosSelecionados.isNotEmpty)
                Column(
                  children: _documentosSelecionados.asMap().entries.map((entry) {
                    final index = entry.key;
                    final file = entry.value;
                    return ListTile(
                      leading: _buildFileIcon(file.path),
                      title: Text(file.uri.pathSegments.last, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => setState(() => _documentosSelecionados.removeAt(index)),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 32),

              // ---------- BOTÃO PUBLICAR ----------
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _publicar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 4,
                    shadowColor: const Color(0xFF2563EB).withOpacity(0.3),
                  ),
                  child: _carregando
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Publicar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }
}