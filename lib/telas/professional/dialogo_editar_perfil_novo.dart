import 'package:flutter/material.dart';
import '../../temas/cores_novo.dart';
import '../../widgets/badge_gb_novo.dart';

class DialogoEditarPerfilNovo extends StatefulWidget {
  const DialogoEditarPerfilNovo({super.key});

  @override
  State<DialogoEditarPerfilNovo> createState() => _DialogoEditarPerfilNovoState();
}

class _DialogoEditarPerfilNovoState extends State<DialogoEditarPerfilNovo> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Editar Perfil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: CoresNovo.navyPrimary)),
          IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(context)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField('Nome Profissional / Empresa *', 'Ex: Braima Cassamá'),
            const SizedBox(height: 16),
            _buildField('Título / Especialidade *', 'Ex: Eletricista Certificado'),
            const SizedBox(height: 16),
            _buildDropdown('Categoria Principal *', 'Eletricidade'),
            const SizedBox(height: 16),
            _buildField('Bairro / Região Base *', 'Santa Luzia'),
            const SizedBox(height: 16),
            _buildExperienceRow(),
            const SizedBox(height: 16),
            _buildPhoneField('Telefone de Atendimento'),
            const SizedBox(height: 16),
            _buildSimpleField('Número WhatsApp para Pedidos', '+245 955 342 189'),
            const SizedBox(height: 16),
            _buildField('Sobre Mim & Diferenciais *', 'Conte a sua história...', maxLines: 3),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: CoresNovo.navyPrimary),
            child: const Text('Guardar Alterações', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildSimpleField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: CoresNovo.navyPrimary)),
        const SizedBox(height: 4),
        TextField(
          controller: TextEditingController(text: value),
          decoration: const InputDecoration(hintStyle: TextStyle(fontSize: 12)),
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

  Widget _buildExperienceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Anos de Experiência:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: CoresNovo.navyPrimary)),
        Row(
          children: [
            const Icon(Icons.remove_circle_outline, size: 28, color: CoresNovo.navyPrimary),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('8 anos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            const Icon(Icons.add_circle_outline, size: 28, color: CoresNovo.navyPrimary),
          ],
        ),
      ],
    );
  }

  Widget _buildPhoneField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: CoresNovo.navyPrimary)),
        const SizedBox(height: 4),
        Row(
          children: const [
            BadgeGBNovo(),
            SizedBox(width: 8),
            Expanded(child: TextField(decoration: InputDecoration(hintText: '955 342 189'))),
          ],
        ),
      ],
    );
  }
}
