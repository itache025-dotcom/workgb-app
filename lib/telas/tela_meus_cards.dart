import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tela_editar_card.dart';
import '../provedores/estado_global.dart';
import '../modelos/trabalhador_model.dart';
import '../servicos/supabase_service.dart';
import '../servicos/responsividade.dart';

final SupabaseService _supabaseService = SupabaseService();

/// Tela que mostra todos os cards do utilizador logado
/// Permite editar ou eliminar cada card
class TelaMeusCards extends StatefulWidget {
  const TelaMeusCards({super.key});

  @override
  State<TelaMeusCards> createState() => _TelaMeusCardsState();
}

class _TelaMeusCardsState extends State<TelaMeusCards> {
  List<TrabalhadorModel> _cards = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarCards();
  }

  Future<void> _carregarCards() async {
    setState(() => _carregando = true);

    try {
      final estado = Provider.of<EstadoGlobal>(context, listen: false);
      final usuario = estado.usuarioLogado;
      if (usuario != null) {
        final cards = await _supabaseService.meusCards(usuario.id);
        setState(() => _cards = cards);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar cards'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  /// Elimina um card após confirmação
  Future<void> _eliminarCard(TrabalhadorModel card) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar Card'),
        content: const Text('Tens a certeza que queres eliminar este card?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _supabaseService.eliminarCard(card.id);
        _carregarCards();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Card eliminado'), backgroundColor: Color(0xFF2563EB)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao eliminar'), backgroundColor: Colors.red),
          );
        }
      }
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
          'Meus Cards',
          style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF1A3C6E)),
        ),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
          : _cards.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card_off, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Ainda não tens cards', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          ],
        ),
      )
          : Responsividade.isTabletOuPc(context)
          ? GridView.builder(
        padding: EdgeInsets.all(Responsividade.paddingHorizontal(context)),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsividade.numeroColunas(context),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemCount: _cards.length,
        itemBuilder: (_, i) => _buildCardItem(_cards[i]),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cards.length,
        itemBuilder: (_, i) => _buildCardItem(_cards[i]),
      ),
    );
  }

  Widget _buildCardItem(TrabalhadorModel card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFF2563EB),
          backgroundImage: card.fotoTrabalhador != null && card.fotoTrabalhador!.isNotEmpty
              ? NetworkImage(card.fotoTrabalhador!)
              : null,
          child: card.fotoTrabalhador == null || card.fotoTrabalhador!.isEmpty
              ? Text(card.nomeTrabalhador.substring(0, 1).toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
              : null,
        ),
        title: Text(card.nomeTrabalhador,
            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A3C6E))),
        subtitle: Text(card.profissaoTrabalhador,
            style: const TextStyle(color: Color(0xFF2563EB), fontSize: 12)),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'editar') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TelaEditarCard(card: card)),
              ).then((_) => _carregarCards());
            } else if (value == 'eliminar') {
              _eliminarCard(card);
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'editar', child: Row(children: [
              Icon(Icons.edit, color: Color(0xFF2563EB), size: 20),
              SizedBox(width: 8),
              Text('Editar'),
            ])),
            const PopupMenuItem(value: 'eliminar', child: Row(children: [
              Icon(Icons.delete, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Eliminar', style: TextStyle(color: Colors.red)),
            ])),
          ],
        ),
      ),
    );
  }
}