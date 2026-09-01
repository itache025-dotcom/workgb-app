import 'package:flutter/material.dart';
import '../modelos/usuario_model.dart';
import '../modelos/trabalhador_model.dart';

/// Provider global que partilha o estado entre todas as telas do WorkGB
class EstadoGlobal extends ChangeNotifier {
  // ---------- ESTADO DO UTILIZADOR ----------
  UsuarioModel? _usuarioLogado;
  bool _estaLogado = false;

  // ---------- LISTA DE TRABALHADORES ----------
  List<TrabalhadorModel> _listaTrabalhadores = [];

  // ---------- MENSAGENS NÃO LIDAS ----------
  int _totalConversasNaoLidas = 0;

  // ---------- GETTERS ----------
  UsuarioModel? get usuarioLogado => _usuarioLogado;
  bool get estaLogado => _estaLogado;
  List<TrabalhadorModel> get listaTrabalhadores => _listaTrabalhadores;
  int get totalConversasNaoLidas => _totalConversasNaoLidas;

  // ---------- MÉTODOS DO UTILIZADOR ----------

  /// Define o utilizador logado e atualiza o estado de autenticação
  void definirUsuarioLogado(UsuarioModel usuario) {
    _usuarioLogado = usuario;
    _estaLogado = true;
    notifyListeners();
  }

  /// Remove o utilizador logado (logout)
  void limparUsuarioLogado() {
    _usuarioLogado = null;
    _estaLogado = false;
    _listaTrabalhadores = [];
    _totalConversasNaoLidas = 0;
    notifyListeners();
  }

  // ---------- MÉTODOS DAS MENSAGENS ----------

  /// Atualiza o total de conversas com mensagens pendentes
  void definirTotalConversasNaoLidas(int total) {
    _totalConversasNaoLidas = total;
    notifyListeners();
  }

  /// Alias para definirTotalConversasNaoLidas solicitado na tarefa
  void atualizarTotalConversas(int total) {
    _totalConversasNaoLidas = total;
    notifyListeners();
  }

  /// Notifica os ouvintes para forçar atualização de badges nas listas
  void dispararAtualizacaoListas() {
    notifyListeners();
  }

  // ---------- MÉTODOS DOS TRABALHADORES ----------

  /// Atualiza a lista de trabalhadores (ex: após busca no backend)
  void definirListaTrabalhadores(List<TrabalhadorModel> lista) {
    _listaTrabalhadores = lista;
    notifyListeners();
  }
}