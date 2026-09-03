import 'package:flutter/material.dart';
import '../../temas/cores_novo.dart';
import '../../widgets/badge_gb_novo.dart';

class DialogoProNovo extends StatefulWidget {
  const DialogoProNovo({super.key});

  @override
  State<DialogoProNovo> createState() => _DialogoProNovoState();
}

class _DialogoProNovoState extends State<DialogoProNovo> {
  String _paymentMethod = 'Orange Money';

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
                  decoration: const BoxDecoration(color: CoresNovo.starYellow, shape: BoxShape.circle),
                  child: const Icon(Icons.star, color: CoresNovo.navyPrimary, size: 20),
                ),
                const SizedBox(width: 10),
                const Text('Assinar Plano Pro ⭐', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: CoresNovo.navyPrimary)),
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
            // Preço
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: CoresNovo.navyPrimary, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Apenas 5.000 FCFA / mês', style: TextStyle(color: CoresNovo.starYellow, fontWeight: FontWeight.w900, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('Sem fidelidade • Cancele quando quiser', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Comparação de Planos:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: CoresNovo.navyPrimary)),
            const SizedBox(height: 10),
            _buildComparisonTable(),

            const SizedBox(height: 20),
            const Text('Pagamento Local:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: CoresNovo.navyPrimary)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildPaymentBtn('Orange Money', const Color(0xFFFF7900))),
                const SizedBox(width: 8),
                Expanded(child: _buildPaymentBtn('MTN MoMo', const Color(0xFFEAB308))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                BadgeGBNovo(),
                SizedBox(width: 8),
                Expanded(child: TextField(decoration: InputDecoration(hintText: 'Número Mobile Money', hintStyle: TextStyle(fontSize: 11)))),
              ],
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: CoresNovo.navyPrimary),
            child: const Text('Confirmar Assinatura Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonTable() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: CoresNovo.cardBackground, borderRadius: BorderRadius.circular(10), border: Border.all(color: CoresNovo.border)),
      child: Column(
        children: [
          _buildPlanRow('Serviços Ativos', '1', 'Ilimitados 🚀'),
          const Divider(height: 16),
          _buildPlanRow('Fotos Galeria', 'Até 6', 'Ilimitadas 📸'),
          const Divider(height: 16),
          _buildPlanRow('Selo Pro', 'Não', 'Sim ⭐'),
          const Divider(height: 16),
          _buildPlanRow('Prioridade', 'Padrão', 'Alta ⚡'),
        ],
      ),
    );
  }

  Widget _buildPlanRow(String feature, String free, String pro) {
    return Row(
      children: [
        Expanded(flex: 2, child: Text(feature, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500))),
        Expanded(child: Text(free, style: const TextStyle(fontSize: 11, color: CoresNovo.textSecondary))),
        Expanded(child: Text(pro, style: const TextStyle(fontSize: 11, color: Color(0xFFD97706), fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _buildPaymentBtn(String label, Color color) {
    final isSelected = _paymentMethod == label;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = label),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : CoresNovo.border, width: isSelected ? 2 : 1),
        ),
        alignment: Alignment.Center,
        child: Text(label, style: TextStyle(color: isSelected ? color : CoresNovo.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
