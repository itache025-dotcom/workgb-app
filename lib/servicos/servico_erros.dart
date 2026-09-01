/// Serviço para traduzir erros técnicos em mensagens amigáveis
class ServicoErros {
  static String obterMensagemAmigavel(dynamic erro, {String? contexto}) {
    final texto = erro.toString().toLowerCase();

    // Se o erro já for uma mensagem em português que nós lançamos, retorna-a diretamente
    if (erro is Exception && !texto.contains('auth')) {
      final msg = erro.toString().replaceFirst('Exception: ', '');
      if (RegExp(r'[a-zA-Záàâãéèêíïóôõöúç]+').hasMatch(msg)) {
        return msg;
      }
    }

    if (texto.contains('invalid_credentials') || 
        texto.contains('invalid login credentials')) {
      if (contexto == 'mudar_senha') {
        return 'Senha atual incorreta. Tente novamente.';
      }
      return 'Email ou senha incorretos. Tente novamente.';
    }

    if (texto.contains('user_already_exists') || 
        texto.contains('already registered')) {
      return 'Este email já está registado. Faz login ou usa outro email.';
    }

    if (texto.contains('weak_password')) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }

    if (texto.contains('network') || 
        texto.contains('timeout') || 
        texto.contains('connection')) {
      return 'Sem conexão à internet. Verifica e tenta novamente.';
    }

    return 'Algo correu mal. Tente novamente.';
  }
}
