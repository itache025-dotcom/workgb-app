import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../modelos/usuario_model.dart';
import 'conversao.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Salva o token FCM para notificações push
  Future<void> salvarTokenPush(String utilizadorId) async {
    try {
      // Garante que o Firebase está inicializado
      await Firebase.initializeApp();
      
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();
      if (token != null) {
        await _supabase.from('tokens_push').upsert({
          'utilizador_id': utilizadorId,
          'token': token,
        }, onConflict: 'utilizador_id');
      }
    } catch (e) {
      print('Erro ao salvar token push: $e');
    }
  }

  /// Regista um novo utilizador com email e senha
  Future<UsuarioModel> cadastrarUsuario({
    required String nomeUsuario,
    required String emailUsuario,
    required String telefoneUsuario,
    required String senhaUsuario,
    required double lat,
    required double lng,
    String tipoUsuario = 'cliente',
  }) async {
    final authResponse = await _supabase.auth.signUp(
      email: emailUsuario,
      password: senhaUsuario,
    );

    final usuario = authResponse.user;
    if (usuario == null) {
      throw Exception('Erro ao criar conta');
    }

    await _supabase.from('utilizadores').insert({
      'id': usuario.id,
      'nome_usuario': nomeUsuario,
      'email_usuario': emailUsuario,
      'telefone_usuario': telefoneUsuario,
      'lat': lat,
      'lng': lng,
      'tipo_usuario': tipoUsuario,
    });

    await salvarTokenPush(usuario.id);

    return UsuarioModel(
      id: usuario.id,
      nomeUsuario: nomeUsuario,
      emailUsuario: emailUsuario,
      telefoneUsuario: telefoneUsuario,
      tipoUsuario: tipoUsuario,
      lat: lat,
      lng: lng,
    );
  }

  /// Faz login com email e senha
  Future<UsuarioModel> loginUsuario({
    required String emailUsuario,
    required String senhaUsuario,
  }) async {
    print('DEBUG LOGIN: Tentando login com $emailUsuario');
    final authResponse = await _supabase.auth.signInWithPassword(
      email: emailUsuario,
      password: senhaUsuario,
    );
    print('DEBUG LOGIN: Resposta: $authResponse');

    final usuario = authResponse.user;
    if (usuario == null) {
      throw Exception('Erro ao fazer login');
    }

    final dados = await _supabase
        .from('utilizadores')
        .select()
        .eq('id', usuario.id)
        .single();
    
    print('DEBUG LOGIN: Dados do utilizador: $dados');

    await salvarTokenPush(usuario.id);

    return UsuarioModel(
      id: usuario.id,
      nomeUsuario: dados['nome_usuario'],
      emailUsuario: dados['email_usuario'],
      telefoneUsuario: dados['telefone_usuario'] ?? '',
      fotoUsuario: dados['foto_usuario'],
      tipoUsuario: dados['tipo_usuario'] ?? 'cliente',
      lat: Conversao.converterParaDouble(dados['lat']),
      lng: Conversao.converterParaDouble(dados['lng']),
    );
  }

  /// Termina a sessão do utilizador
  Future<void> logout() async {
    try {
      final usuarioAtual = _supabase.auth.currentUser;

      if (usuarioAtual != null) {
        // 1. Remover tokens push para parar notificações via Firebase
        await _supabase
            .from('tokens_push')
            .delete()
            .eq('utilizador_id', usuarioAtual.id);
      }
    } catch (e) {
      print('Erro ao remover token no logout: $e');
    }

    await _supabase.auth.signOut();
  }

  /// Obtém o utilizador atualmente logado (se houver)
  Future<UsuarioModel?> obterUtilizadorAtual() async {
    final usuario = _supabase.auth.currentUser;
    if (usuario == null) return null;

    final dados = await _supabase
        .from('utilizadores')
        .select()
        .eq('id', usuario.id)
        .single();
    
    print('DEBUG LOGIN: Dados do utilizador: $dados');

    return UsuarioModel(
      id: usuario.id,
      nomeUsuario: dados['nome_usuario'],
      emailUsuario: dados['email_usuario'],
      telefoneUsuario: dados['telefone_usuario'] ?? '',
      fotoUsuario: dados['foto_usuario'],
      tipoUsuario: dados['tipo_usuario'] ?? 'cliente',
      lat: Conversao.converterParaDouble(dados['lat']),
      lng: Conversao.converterParaDouble(dados['lng']),
    );
  }

  /// Atualiza os dados do perfil do utilizador
  Future<void> atualizarPerfil({
    required String id,
    required String nomeUsuario,
    required String emailUsuario,
    required String telefoneUsuario,
  }) async {
    // Atualizar email no Supabase Auth se mudou
    final usuarioAtual = _supabase.auth.currentUser;
    if (usuarioAtual != null && usuarioAtual.email != emailUsuario) {
      await _supabase.auth.updateUser(
        UserAttributes(email: emailUsuario),
      );
    }

    // Atualizar dados na tabela utilizadores
    await _supabase.from('utilizadores').update({
      'nome_usuario': nomeUsuario,
      'email_usuario': emailUsuario,
      'telefone_usuario': telefoneUsuario,
    }).eq('id', id);
  }

  /// Muda a senha do utilizador
  Future<void> mudarSenha({
    required String senhaAntiga,
    required String novaSenha,
  }) async {
    // Verificar senha antiga fazendo login
    final email = _supabase.auth.currentUser?.email;
    if (email == null) throw Exception('Utilizador não encontrado');

    await _supabase.auth.signInWithPassword(
      email: email,
      password: senhaAntiga,
    );

    // Atualizar para a nova senha
    await _supabase.auth.updateUser(
      UserAttributes(password: novaSenha),
    );
  }
}
