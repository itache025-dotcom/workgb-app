import 'package:flutter/material.dart';
import '../../temas/cores_novo.dart';

class DialogoServicoNovo extends StatefulWidget {
  const DialogoServicoNovo({super.key});

  @override
  State<DialogoServicoNovo> createState() => _DialogoServicoNovoState();
}

class _DialogoServicoNovoState extends State<DialogoServicoNovo> {
  bool _isActive = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Criar Novo Serviço', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: CoresNovo.navyPrimary)),
          IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(context)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField('Nome do Serviço *', 'Ex: Instalações Residenciais'),
            const SizedBox(height: 16),
            _buildDropdown('Categoria / Profissão *', 'Eletricidade'),
            const SizedBox(height: 16),
            _buildField('Descrição do Serviço *', 'Descreva o que inclui o serviço...', maxLines: 3),
            const SizedBox(height: 16),
            const Text('Bairros de Atuação *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: CoresNovo.navyPrimary)),
            const SizedBox(height: 8),
            _buildNeighborhoodChips(),
            const SizedBox(height: 16),
            _buildField('Disponibilidade & Horários *', 'Seg a Sáb • 08:00 - 18:00'),
            const SizedBox(height: 16),
            _buildField('Preço Estimado (Opcional)', 'Ex: A partir de 5.000 FCFA'),
            const SizedBox(height: 20),
            _buildStatusToggle(),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: CoresNovo.navyPrimary),
            icon: const Icon(Icons.check, color: Colors.white, size: 16),
            label: const Text('Guardar e Publicar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: CoresNovo.navyPrimary)),
        const SizedBox(height: 4),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: CoresNovo.navyPrimary)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: CoresNovo.border)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNeighborhoodChips() {
    return Wrap(
      spacing: 6, runSpacing: 6,
      children: ['Santa Luzia', 'Bissau Velho', 'Bandim'].map((n) => FilterChip(
        label: Text(n, style: const TextStyle(fontSize: 11)),
        selected: n == 'Santa Luzia',
        onSelected: (v) {},
        selectedColor: CoresNovo.navyPrimary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(color: n == 'Santa Luzia' ? Colors.white : CoresNovo.textPrimary),
      )).toList(),
    );
  }

  Widget _buildStatusToggle() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: CoresNovo.cardBackground, border: Border.all(color: CoresNovo.border), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isActive ? 'Status: Serviço Ativo' : 'Status: Serviço Pausado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _isActive ? CoresNovo.success : const Color(0xFFD97706))),
              const Text('Visível para todos os clientes', style: TextStyle(fontSize: 11, color: CoresNovo.textSecondary)),
            ],
          ),
          Switch(
            value: _isActive,
            onChanged: (v) => setState(() => _isActive = v),
            activeColor: CoresNovo.success,
          ),
        ],
      ),
    );
  }
}
