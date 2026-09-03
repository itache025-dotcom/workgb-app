import 'package:flutter/material.dart';
import '../../temas/cores_novo.dart';
import '../../widgets/badge_gb_novo.dart';

class DialogoBoostNovo extends StatefulWidget {
  const DialogoBoostNovo({super.key});

  @override
  State<DialogoBoostNovo> createState() => _DialogoBoostNovoState();
}

class _DialogoBoostNovoState extends State<DialogoBoostNovo> {
  int _selectedDuration = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 34, width: 34,
                  decoration: BoxDecoration(color: CoresNovo.starYellow.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.rocket_launch, color: Color(0xFFD97706), size: 20),
                ),
                const SizedBox(width: 10),
                const Text('Impulsionar Perfil', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: CoresNovo.navyPrimary)),
              ],
            ),
            IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Benefícios
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: CoresNovo.navyPrimary, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('🚀 Receba até 3x mais contactos', style: TextStyle(color: CoresNovo.starYellow, fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(height: 6),
                  Text(
                    '• Destaque prioritário no topo\n• Selo dourado de destaque\n• Notificação prioritária',
                    style: TextStyle(color: Colors.white, fontSize: 11, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text('Escolha a duração:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: CoresNovo.navyPrimary)),
            const SizedBox(height: 10),
            _buildDurationOption(0, '3 Dias', 'Destaque Rápido', '1.500 FCFA'),
            const SizedBox(height: 8),
            _buildDurationOption(1, '7 Dias', 'Mais Popular 🔥', '3.000 FCFA'),
            const SizedBox(height: 8),
            _buildDurationOption(2, '15 Dias', 'Máxima Visibilidade ⭐', '5.500 FCFA'),

            const SizedBox(height: 20),
            const Text('Pagamento (Guiné-Bissau):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: CoresNovo.navyPrimary)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildPaymentBtn('Orange Money', const Color(0xFFFF7900), true)),
                const SizedBox(width: 8),
                Expanded(child: _buildPaymentBtn('MTN MoMo', const Color(0xFFEAB308), false)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                BadgeGBNovo(),
                SizedBox(width: 8),
                Expanded(child: TextField(decoration: InputDecoration(hintText: 'Número da Conta Móvel', hintStyle: TextStyle(fontSize: 11)))),
              ],
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706)),
            icon: const Icon(Icons.flash_on, color: Colors.white, size: 16),
            label: const Text('Ativar Impulso Agora', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationOption(int index, String days, String badge, String price) {
    final isSelected = _selectedDuration == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedDuration = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? CoresNovo.blueContainer : CoresNovo.cardBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? CoresNovo.navyPrimary : CoresNovo.border, width: isSelected ? 2 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, size: 20, color: CoresNovo.navyPrimary),
                    const SizedBox(width: 8),
                    Text(days, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: CoresNovo.navyPrimary)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Text(badge, style: TextStyle(fontSize: 11, color: index == 1 ? const Color(0xFFD97706) : CoresNovo.textSecondary, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            Text(price, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: CoresNovo.navyPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentBtn(String label, Color color, bool isSelected) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSelected ? color : CoresNovo.border, width: isSelected ? 2 : 1),
      ),
      alignment: Alignment.center,
      child: Text(label, style: TextStyle(color: isSelected ? color : CoresNovo.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
