/// Serviço de validação de dados guineenses
class ValidacaoService {
  /// Valida número de telefone da Guiné-Bissau
  /// Aceita formatos: 955123456, 955 123 456, +245 955 123 456
  static bool validarTelefone(String telefone) {
    // Remove espaços, +, - e formata
    final limpo = telefone.replaceAll(RegExp(r'[\s\+\-]'), '');
    
    // Se começar com 245, remove
    final semPais = limpo.startsWith('245') ? limpo.substring(3) : limpo;
    
    // Deve ter 9 dígitos e começar com 95 ou 96
    if (semPais.length != 9) return false;
    if (!semPais.startsWith('95') && !semPais.startsWith('96')) return false;
    
    return RegExp(r'^\d{9}$').hasMatch(semPais);
  }

  /// Formata telefone para exibição
  static String formatarTelefone(String telefone) {
    final limpo = telefone.replaceAll(RegExp(r'[\s\+\-]'), '');
    final semPais = limpo.startsWith('245') ? limpo.substring(3) : limpo;
    
    if (semPais.length == 9) {
      return '${semPais.substring(0, 3)} ${semPais.substring(3, 6)} ${semPais.substring(6)}';
    }
    return telefone;
  }
}
