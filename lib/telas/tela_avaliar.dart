import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modelos/trabalhador_model.dart';
import '../provedores/estado_global.dart';
import '../servicos/supabase_service.dart';

class TelaAvaliar extends StatefulWidget {
  final TrabalhadorModel trabalhador;

  const TelaAvaliar({super.key, required this.trabalhador});

  @override
  State<TelaAvaliar> createState() => _TelaAvaliarState();
}

class _TelaAvaliarState extends State<TelaAvaliar> {
  final _comentarioController = TextEditingController();
  final _nomeController = TextEditingController();
  int _estrelas = 5;
  bool _carregando = false;
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void dispose() {
    _comentarioController.dispose();
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _enviarAvaliacao() async {
    final estado = Provider.of<EstadoGlobal>(context, listen: false);
    
    if (_comentarioController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escreve um pequeno comentário sobre o serviço.')),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      await _supabaseService.adicionarAvaliacao(
        trabalhadorId: widget.trabalhador.id,
        utilizadorId: estado.usuarioLogado?.id,
        estrelas: _estrelas,
        comentario: _comentarioController.text.trim(),
        nomeAvaliador: estado.estaLogado ? null : _nomeController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Obrigado pela tua avaliação!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar avaliação: $e'), backgroundColor: Colors.red),
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
        title: Text('Avaliar Profissional', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Como foi o serviço de ${widget.trabalhador.nomeTrabalhador}?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Estrelas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final estrelaIdx = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _estrelas = estrelaIdx),
                  icon: Icon(
                    estrelaIdx <= _estrelas ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              '$_estrelas estrelas',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            
            const SizedBox(height: 32),

            // Nome (apenas para anónimos)
            if (!Provider.of<EstadoGlobal>(context, listen: false).estaLogado) ...[
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Teu nome (Opcional)',
                  hintText: 'Como queres ser chamado...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Comentário
            TextField(
              controller: _comentarioController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Comentário',
                hintText: 'Conta-nos como foi a tua experiência...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            
            const SizedBox(height: 32),

            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _carregando ? null : _enviarAvaliacao,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: _carregando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Enviar Avaliação', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
