/// Funções utilitárias para conversão de tipos de dados
class Conversao {
  /// Converte qualquer valor para double de forma segura
  /// Trata casos onde o Supabase retorna int para valores que deveriam ser double (ex: 0)
  static double? converterParaDouble(dynamic valor) {
    if (valor == null) return null;
    if (valor is double) return valor;
    if (valor is int) return valor.toDouble();
    if (valor is String) return double.tryParse(valor);
    return null;
  }
}
