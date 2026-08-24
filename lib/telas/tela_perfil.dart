import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modelos/trabalhador_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../servicos/responsividade.dart';
import '../servicos/supabase_service.dart';
import '../provedores/estado_global.dart';
import 'tela_avaliar.dart';

/// Tela de perfil completo do trabalhador
class TelaPerfil extends StatefulWidget {
  final TrabalhadorModel trabalhador;

  const TelaPerfil({super.key, required this.trabalhador});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _avaliacoes = [];
  bool _carregandoAvaliacoes = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final lista = await _supabaseService.obterAvaliacoes(widget.trabalhador.id);
    if (mounted) {
      setState(() {
        _avaliacoes = lista;
        _carregandoAvaliacoes = false;
      });
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
          'Perfil',
          style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF1A3C6E)),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Responsividade.larguraMaxima(context)),
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isGrande = constraints.maxWidth >= 700;

                if (isGrande) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: _buildFotoPerfil(),
                          ),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildInformacoes(context),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Column(
                    children: [
                      _buildFotoPerfil(),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildInformacoes(context),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFotoPerfil() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.1)),
      child: widget.trabalhador.fotoTrabalhador != null && widget.trabalhador.fotoTrabalhador!.isNotEmpty
          ? Image.network(
        widget.trabalhador.fotoTrabalhador!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => _buildPlaceholderPlaceholder(widget.trabalhador),
      )
          : _buildPlaceholderPlaceholder(widget.trabalhador),
    );
  }

  List<Widget> _buildInformacoes(BuildContext context) {
    final estado = Provider.of<EstadoGlobal>(context);
    final souEu = estado.usuarioLogado?.id == widget.trabalhador.utilizadorId;

    return [
      Text(
        widget.trabalhador.nomeTrabalhador,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1A3C6E)),
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(20)),
        child: Text(
          widget.trabalhador.profissaoTrabalhador,
          style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      const SizedBox(height: 24),

      const Text('Sobre', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A3C6E))),
      const SizedBox(height: 8),
      Text(
        widget.trabalhador.descricaoTrabalhador ?? 'Sem descrição disponível.',
        style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
      ),
      const SizedBox(height: 24),

      const Text('Localização', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A3C6E))),
      const SizedBox(height: 8),
      Row(
        children: [
          const Icon(Icons.location_on, color: Color(0xFF2563EB), size: 20),
          const SizedBox(width: 8),
          Text(
            '📍 Bairro: ${_extrairBairro(widget.trabalhador.descricaoTrabalhador ?? "")}',
            style: TextStyle(fontSize: 15, color: Colors.grey[700]),
          ),
        ],
      ),
      const SizedBox(height: 24),

      if (widget.trabalhador.disponibilidadeDias.isNotEmpty) ...[
        const Text('Disponibilidade', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A3C6E))),
        const SizedBox(height: 8),
        Text('Dias: ${widget.trabalhador.disponibilidadeDias.join(', ')}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        if (widget.trabalhador.disponibilidadeInicio != null && widget.trabalhador.disponibilidadeFim != null)
          Text('Horário: ${widget.trabalhador.disponibilidadeInicio} - ${widget.trabalhador.disponibilidadeFim}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        const SizedBox(height: 24),
      ],

      if (widget.trabalhador.documentos.isNotEmpty) ...[
        const Text('Documentos e Certificados', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A3C6E))),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.trabalhador.documentos.length,
            itemBuilder: (ctx, i) {
              final url = widget.trabalhador.documentos[i];
              final fileInfo = _obterIconeECorDocumento(url);
              return GestureDetector(
                onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(fileInfo['icone'] as IconData, color: fileInfo['cor'] as Color, size: 32),
                      const SizedBox(height: 4),
                      const Text('Ver', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],

      // ---------- SECÇÃO DE AVALIAÇÕES ----------
      const Divider(height: 48),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Avaliações', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A3C6E))),
          if (!souEu)
            TextButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => TelaAvaliar(trabalhador: widget.trabalhador))).then((v) {
                  if (v == true) _carregarDados();
                });
              },
              icon: const Icon(Icons.star_outline),
              label: const Text('Avaliar'),
            ),
        ],
      ),
      const SizedBox(height: 12),
      if (_carregandoAvaliacoes)
        const Center(child: CircularProgressIndicator())
      else if (_avaliacoes.isEmpty)
        const Text('Ainda não há avaliações.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))
      else
        Column(
          children: _avaliacoes.map((av) => _buildComentario(av, souEu)).toList(),
        ),

      const SizedBox(height: 40),

      Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                final telefone = _extrairTelefone(widget.trabalhador.descricaoTrabalhador ?? '');
                if (telefone.isNotEmpty) {
                  final url = Uri.parse('tel:+245$telefone');
                  if (await canLaunchUrl(url)) await launchUrl(url);
                }
              },
              icon: const Icon(Icons.phone, color: Colors.white),
              label: const Text('Ligar', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                final telefone = _extrairTelefone(widget.trabalhador.descricaoTrabalhador ?? '');
                if (telefone.isNotEmpty) {
                  final url = Uri.parse('https://wa.me/245$telefone');
                  if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.chat, color: Colors.white),
              label: const Text('WhatsApp', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
    ];
  }

  Widget _buildComentario(Map<String, dynamic> av, bool souOProfissional) {
    final nomeCliente = (av['utilizadores'] != null) 
        ? av['utilizadores']['nome_usuario'] 
        : (av['nome_avaliador'] ?? 'Utilizador');
    final estrelas = av['estrelas'] as int;
    final comentario = av['comentario'] ?? '';
    final resposta = av['resposta'];
    final id = av['id'];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(nomeCliente, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A3C6E))),
              Row(
                children: List.generate(5, (index) => Icon(
                  index < estrelas ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comentario, style: TextStyle(color: Colors.grey[800])),
          
          if (resposta != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Resposta do Profissional:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1A3C6E))),
                  const SizedBox(height: 4),
                  Text(resposta, style: TextStyle(fontSize: 13, color: Colors.blue[900])),
                ],
              ),
            ),
          ] else if (souOProfissional) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _mostrarDialogoResposta(id),
              child: const Text('Responder Avaliação', style: TextStyle(fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }

  void _mostrarDialogoResposta(int avaliacaoId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Responder Avaliação'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Escreve a tua resposta...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await _supabaseService.responderAvaliacao(avaliacaoId: avaliacaoId, resposta: controller.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
              _carregarDados();
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderPlaceholder(TrabalhadorModel trabalhador) {
    return Center(
      child: CircleAvatar(
        radius: 64,
        backgroundColor: const Color(0xFF2563EB),
        child: Text(
          trabalhador.nomeTrabalhador.substring(0, 1).toUpperCase(),
          style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  String _extrairBairro(String descricao) {
    final match = RegExp(r'📍 Bairro:\s*(.+)').firstMatch(descricao);
    return match?.group(1)?.trim() ?? 'Bissau';
  }

  String _extrairTelefone(String descricao) {
    final match = RegExp(r'📞\s*([\d\s\+]+)').firstMatch(descricao);
    if (match != null) {
      String tel = match.group(1)!.replaceAll(RegExp(r'\s'), '');
      if (tel.startsWith('+245')) tel = tel.substring(4);
      else if (tel.startsWith('245')) tel = tel.substring(3);
      return tel;
    }
    return '';
  }

  Map<String, dynamic> _obterIconeECorDocumento(String url) {
    final extensao = url.toLowerCase().split('.').last.split('?').first;
    switch (extensao) {
      case 'pdf': return {'icone': Icons.picture_as_pdf, 'cor': Colors.red};
      case 'docx':
      case 'doc': return {'icone': Icons.description, 'cor': Colors.blue};
      case 'xlsx':
      case 'xls': return {'icone': Icons.table_chart, 'cor': Colors.green};
      case 'pptx':
      case 'ppt': return {'icone': Icons.slideshow, 'cor': Colors.orange};
      default: return {'icone': Icons.image, 'cor': const Color(0xFF2563EB)};
    }
  }
}
