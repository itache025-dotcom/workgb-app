import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../modelos/trabalhador_model.dart';
import '../servicos/supabase_service.dart';
import '../servicos/validacao_service.dart';
import '../servicos/imagem_service.dart';
import 'package:file_picker/file_picker.dart';
import '../servicos/responsividade.dart';


final SupabaseService _supabaseService = SupabaseService();

/// Tela profissional para editar um card existente
/// Com nome, foto, profissão, bairro, telefone e descrição
class TelaEditarCard extends StatefulWidget {
  final TrabalhadorModel card;

  const TelaEditarCard({super.key, required this.card});

  @override
  State<TelaEditarCard> createState() => _TelaEditarCardState();
}

class _TelaEditarCardState extends State<TelaEditarCard> {
  late TextEditingController _nomeController;
  late TextEditingController _telefoneController;
  late TextEditingController _descricaoController;
  final _outraProfissaoController = TextEditingController();
  final _outroBairroController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _carregando = false;
  File? _imagemSelecionada;
  final ImagePicker _picker = ImagePicker();

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

  // Disponibilidade
  final List<String> _diasSemana = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
  final Set<String> _diasSelecionados = {};
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFim;

  // Documentos
  final List<String> _documentosRemotos = [];
  final List<File> _documentosNovos = [];

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.card.nomeTrabalhador);

    // Extrai telefone e bairro da descrição
    final desc = widget.card.descricaoTrabalhador ?? '';
    String descricaoLimpa = desc;
    String telefone = '';
    String bairro = '';

    final telefoneMatch = RegExp(r'📞\s*(\S+)').firstMatch(desc);
    if (telefoneMatch != null) {
      telefone = telefoneMatch.group(1)!;
      descricaoLimpa = descricaoLimpa.replaceFirst(telefoneMatch.group(0)!, '');
    }

    final bairroMatch = RegExp(r'📍\s*Bairro:\s*(.+)').firstMatch(desc);
    if (bairroMatch != null) {
      bairro = bairroMatch.group(1)!.trim();
      descricaoLimpa = descricaoLimpa.replaceFirst(bairroMatch.group(0)!, '');
    }

    _telefoneController = TextEditingController(text: telefone);
    _descricaoController = TextEditingController(text: descricaoLimpa.trim());

    // Tenta encontrar a profissão na lista
    if (_profissoes.contains(widget.card.profissaoTrabalhador)) {
      _profissaoSelecionada = widget.card.profissaoTrabalhador;
    } else {
      _profissaoSelecionada = 'Outra';
      _outraProfissaoController.text = widget.card.profissaoTrabalhador;
    }

    // Tenta encontrar o bairro na lista
    if (_bairros.contains(bairro)) {
      _bairroSelecionado = bairro;
    } else if (bairro.isNotEmpty) {
      _bairroSelecionado = 'Outro';
      _outroBairroController.text = bairro;
    }

    // Inicializa disponibilidade
    _diasSelecionados.addAll(widget.card.disponibilidadeDias);
    if (widget.card.disponibilidadeInicio != null) {
      _horaInicio = _stringToTime(widget.card.disponibilidadeInicio!);
    }
    if (widget.card.disponibilidadeFim != null) {
      _horaFim = _stringToTime(widget.card.disponibilidadeFim!);
    }

    // Inicializa documentos
    _documentosRemotos.addAll(widget.card.documentos);
  }

  TimeOfDay? _stringToTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length == 2) {
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1].split(' ')[0]));
      }
      // Tenta formato AM/PM se o anterior falhar (format(context) geralmente retorna 24h ou AM/PM dependendo do locale)
      final format = RegExp(r'(\d+):(\d+)\s*(AM|PM)?');
      final match = format.firstMatch(time);
      if (match != null) {
        int hour = int.parse(match.group(1)!);
        int minute = int.parse(match.group(2)!);
        String? ampm = match.group(3);
        if (ampm == 'PM' && hour < 12) hour += 12;
        if (ampm == 'AM' && hour == 12) hour = 0;
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _selecionarHora(bool inicio) async {
    final hora = await showTimePicker(
      context: context,
      initialTime: (inicio ? _horaInicio : _horaFim) ?? TimeOfDay.now(),
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
        _documentosNovos.addAll(resultado.paths.map((p) => File(p!)));
      });
    }
  }

  Widget _buildFileIcon(String pathOrUrl) {
    final extensao = pathOrUrl.toLowerCase().split('.').last;
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final profissao = _profissaoSelecionada == 'Outra'
        ? _outraProfissaoController.text.trim()
        : _profissaoSelecionada!;

    final bairro = _bairroSelecionado == 'Outro'
        ? _outroBairroController.text.trim()
        : _bairroSelecionado!;

    final descricaoCompleta = '${_descricaoController.text.trim()}\n\n'
        '📞 ${_telefoneController.text.trim()}\n'
        '📍 Bairro: $bairro';

    setState(() => _carregando = true);

    try {
      String? fotoUrl;
      if (_imagemSelecionada != null) {
        final imagemComprimida = await ImagemService.comprimirImagem(_imagemSelecionada!);
        if (imagemComprimida != null) {
          fotoUrl = await _supabaseService.uploadFoto(imagemComprimida.path);
        }
      }

      // Upload de novos documentos
      List<String> documentosUrls = List.from(_documentosRemotos);
      if (_documentosNovos.isNotEmpty) {
        final novosUrls = await _supabaseService.uploadDocumentos(
          _documentosNovos.map((f) => f.path).toList(),
        );
        documentosUrls.addAll(novosUrls);
      }

      await _supabaseService.atualizarCard(
        id: widget.card.id,
        nomeTrabalhador: _nomeController.text.trim(),
        profissaoTrabalhador: profissao,
        descricaoTrabalhador: descricaoCompleta,
        fotoTrabalhador: fotoUrl,
        disponibilidadeDias: _diasSelecionados.toList(),
        disponibilidadeInicio: _horaInicio?.format(context),
        disponibilidadeFim: _horaFim?.format(context),
        documentos: documentosUrls,
      );

      if (mounted) {
        // Mostra diálogo de sucesso
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            icon: const Icon(Icons.check_circle, color: Color(0xFF2563EB), size: 56),
            title: const Text('Alterações Salvas!'),
            content: const Text('O teu card foi atualizado com sucesso.'),
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
          SnackBar(content: Text('Erro ao atualizar'), backgroundColor: Colors.red),
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
        title: const Text('Editar Card', style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF1A3C6E))),
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
                  // Foto
              Center(
                child: GestureDetector(
                  onTap: _escolherFoto,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2563EB), width: 2),
                      image: _imagemSelecionada != null
                          ? DecorationImage(image: FileImage(_imagemSelecionada!), fit: BoxFit.cover)
                          : widget.card.fotoTrabalhador != null
                          ? DecorationImage(
                          image: NetworkImage(widget.card.fotoTrabalhador!),
                          fit: BoxFit.cover)
                          : null,
                    ),
                    child: (_imagemSelecionada == null && widget.card.fotoTrabalhador == null)
                        ? const Icon(Icons.add_a_photo, size: 40, color: Color(0xFF2563EB))
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(child: Text('Alterar foto', style: TextStyle(fontSize: 14, color: Color(0xFF2563EB)))),
              const SizedBox(height: 24),

              // Nome
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome no Card',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),

              // Profissão dropdown
              DropdownButtonFormField<String>(
                value: _profissaoSelecionada,
                decoration: InputDecoration(
                  labelText: 'Profissão',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.work_outline),
                ),
                items: _profissoes.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => setState(() => _profissaoSelecionada = v),
              ),
              if (_profissaoSelecionada == 'Outra') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _outraProfissaoController,
                  decoration: InputDecoration(
                    labelText: 'Qual a tua profissão?',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    prefixIcon: const Icon(Icons.edit),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Telefone
              TextFormField(
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Telefone',
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

              // Bairro dropdown
              DropdownButtonFormField<String>(
                value: _bairroSelecionado,
                decoration: InputDecoration(
                  labelText: 'Bairro',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                items: _bairros.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (v) => setState(() => _bairroSelecionado = v),
              ),
              if (_bairroSelecionado == 'Outro') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _outroBairroController,
                  decoration: InputDecoration(
                    labelText: 'Qual o teu bairro?',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    prefixIcon: const Icon(Icons.edit),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Descrição
              TextFormField(
                controller: _descricaoController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Descrição',
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
                  const Text('Documentos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A3C6E))),
                  TextButton.icon(
                    onPressed: _adicionarDocumentos,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Adicionar'),
                  ),
                ],
              ),
              // Documentos Remotos
              if (_documentosRemotos.isNotEmpty)
                Column(
                  children: _documentosRemotos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final url = entry.value;
                    return ListTile(
                      leading: _buildFileIcon(url),
                      title: Text('Documento ${index + 1}', style: const TextStyle(fontSize: 13)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => setState(() => _documentosRemotos.removeAt(index)),
                      ),
                    );
                  }).toList(),
                ),
              // Documentos Novos
              if (_documentosNovos.isNotEmpty)
                Column(
                  children: _documentosNovos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final file = entry.value;
                    return ListTile(
                      leading: _buildFileIcon(file.path),
                      title: Text(file.uri.pathSegments.last, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.orange),
                        onPressed: () => setState(() => _documentosNovos.removeAt(index)),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 32),

              // Botão salvar
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
                      : const Text('Salvar Alterações', style: TextStyle(fontSize: 16, color: Colors.white)),
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