import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedores/estado_global.dart';
import '../modelos/trabalhador_model.dart';
import '../temas/cores_novo.dart';
import '../widgets/chip_novo.dart';
import '../widgets/bottom_nav_novo.dart';
import 'tela_perfil_novo.dart';
import 'tela_conversas_novo.dart';
import 'tela_perfil_usuario_novo.dart';
import 'professional/tela_tornar_pro_novo.dart';
import 'tela_cadastro_novo.dart';
import 'tela_login_novo.dart';

class TelaPesquisaNovo extends StatefulWidget {
  const TelaPesquisaNovo({super.key});

  @override
  State<TelaPesquisaNovo> createState() => _TelaPesquisaNovoState();
}

class _TelaPesquisaNovoState extends State<TelaPesquisaNovo> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _profissaoSelecionada = 'Todas';
  String? _bairroSelecionada = 'Todos';

  String _extrairBairro(String descricao) {
    final match = RegExp(r'📍 Bairro:\s*(.+)').firstMatch(descricao);
    return match?.group(1)?.trim() ?? 'Bissau';
  }

  List<String> _extrairProfissoesUnicas(List<TrabalhadorModel> trabalhadores) {
    final profissoes = <String>{'Todas'};
    for (final t in trabalhadores) {
      if (t.profissaoTrabalhador.isNotEmpty) {
        profissoes.add(t.profissaoTrabalhador);
      }
    }
    return profissoes.toList()..sort();
  }

  List<String> _extrairBairrosUnicos(List<TrabalhadorModel> trabalhadores) {
    final bairros = <String>{'Todos'};
    for (final t in trabalhadores) {
      final bairro = _extrairBairro(t.descricaoTrabalhador ?? '');
      if (bairro.isNotEmpty && bairro != 'Bissau') {
        bairros.add(bairro);
      }
    }
    return bairros.toList()..sort();
  }

  void _mostrarDialogoLogin(BuildContext context, TrabalhadorModel trabalhador) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.person_add_alt_1, color: CoresNovo.navyPrimary, size: 48),
        title: const Text('Quase lá!', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Para veres o perfil completo de ${trabalhador.nomeTrabalhador}, precisas de uma conta. '
          'É grátis e rápido!',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: CoresNovo.textPrimary),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => TelaCadastroNovo()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CoresNovo.starYellow,
                  foregroundColor: CoresNovo.navyPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                child: const Text('Criar Conta Grátis', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => TelaLoginNovo()));
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: CoresNovo.navyPrimary,
                  side: const BorderSide(color: CoresNovo.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Já tenho conta', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = Provider.of<EstadoGlobal>(context);
    final trabalhadores = estado.listaTrabalhadores;

    final profissoesDisponiveis = _extrairProfissoesUnicas(trabalhadores);
    final bairrosDisponiveis = _extrairBairrosUnicos(trabalhadores);

    final resultados = trabalhadores.where((t) {
      final matchQuery = _query.isEmpty ||
          t.nomeTrabalhador.toLowerCase().contains(_query.toLowerCase()) ||
          t.profissaoTrabalhador.toLowerCase().contains(_query.toLowerCase());

      final matchProfissao = _profissaoSelecionada == 'Todas' || t.profissaoTrabalhador == _profissaoSelecionada;
      final matchBairro = _bairroSelecionada == 'Todos' || _extrairBairro(t.descricaoTrabalhador ?? '') == _bairroSelecionada;

      return matchQuery && matchProfissao && matchBairro;
    }).toList();

    return Scaffold(
      backgroundColor: CoresNovo.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: CoresNovo.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Pesquisar...',
              prefixIcon: Icon(Icons.search, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavNovo(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) Navigator.pop(context);
          if (i == 2) {
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TelaConversasNovo()));
          }
          if (i == 3) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => estado.estaLogado ? TelaPerfilUsuarioNovo() : TelaTornarProNovo()));
          }
        },
        unreadMessages: estado.totalConversasNaoLidas,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(
                    'Profissão', 
                    Icons.work_outline, 
                    profissoesDisponiveis, 
                    _profissaoSelecionada, 
                    (v) => setState(() => _profissaoSelecionada = v)
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFilterDropdown(
                    'Bairro', 
                    Icons.location_on_outlined, 
                    bairrosDisponiveis, 
                    _bairroSelecionada, 
                    (v) => setState(() => _bairroSelecionada = v)
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: resultados.isEmpty
                ? const Center(child: Text('Nenhum resultado encontrado.'))
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: resultados.length,
                    itemBuilder: (context, index) => _buildProfessionalCard(resultados[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String hint, IconData icon, List<String> items, String? value, Function(String?) onChanged) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CoresNovo.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: CoresNovo.textSecondary),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 13)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildProfessionalCard(TrabalhadorModel t) {
    final bairro = _extrairBairro(t.descricaoTrabalhador ?? '');
    return GestureDetector(
      onTap: () {
        final estado = Provider.of<EstadoGlobal>(context, listen: false);
        if (!estado.estaLogado) {
          _mostrarDialogoLogin(context, t);
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => TelaPerfilNovo(trabalhador: t)));
        }
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: t.fotoTrabalhador != null && t.fotoTrabalhador!.isNotEmpty
                    ? Image.network(t.fotoTrabalhador!, fit: BoxFit.cover, width: double.infinity)
                    : Container(
                        color: CoresNovo.blueLight,
                        child: Center(
                          child: Text(
                            (t.nomeTrabalhador.isNotEmpty ? t.nomeTrabalhador.substring(0, 1) : 'P').toUpperCase(),
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: CoresNovo.navyPrimary),
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.nomeTrabalhador, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CoresNovo.navyPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  TagProfissaoNovo(profissao: t.profissaoTrabalhador),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: CoresNovo.textSecondary),
                      const SizedBox(width: 3),
                      Expanded(child: Text(bairro, style: const TextStyle(fontSize: 10, color: CoresNovo.textSecondary), maxLines: 1)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
