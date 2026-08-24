import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../modelos/trabalhador_model.dart';
import 'conversao.dart';

/// Serviço de dados com Supabase (PostgreSQL gratuito)
class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Listar todos os trabalhadores
  Future<List<TrabalhadorModel>> listarTrabalhadores({
    double? lat,
    double? lng,
  }) async {
    final double? pLat = Conversao.converterParaDouble(lat);
    final double? pLng = Conversao.converterParaDouble(lng);

    try {
      final response = await _client.from('trabalhadores').select();
      print('DEBUG CARDS: Resposta bruta: $response');
      
      print('DEBUG: Supabase retornou ${response.length} registros');

      final List<TrabalhadorModel> lista = [];

      for (var i = 0; i < response.length; i++) {
        final dados = response[i];
        print('DEBUG: Processando registro $i (ID: ${dados['id']})');
        
        // Log de todos os tipos para identificar o culpado
        dados.forEach((k, v) => print('  - Campo: $k = $v (${v?.runtimeType})'));

        double? dLat;
        try { dLat = Conversao.converterParaDouble(dados['lat']); } catch (e) { print('ERRO NO CAMPO lat: $e'); }
        
        double? dLng;
        try { dLng = Conversao.converterParaDouble(dados['lng']); } catch (e) { print('ERRO NO CAMPO lng: $e'); }

        double? dKm;
        if (pLat != null && pLng != null && dLat != null && dLng != null) {
          try {
            dKm = _calcularDistancia(pLat, pLng, dLat, dLng);
          } catch (e) {
            print('ERRO NO CALCULO DISTANCIA: $e');
          }
        }

        try {
          final trabalhador = TrabalhadorModel(
            id: dados['id'].toString(),
            nomeTrabalhador: dados['nome_trabalhador']?.toString() ?? 'Sem Nome',
            profissaoTrabalhador: dados['profissao_trabalhador']?.toString() ?? 'Trabalhador',
            fotoTrabalhador: dados['foto_trabalhador']?.toString(),
            descricaoTrabalhador: dados['descricao_trabalhador']?.toString(),
            lat: dLat,
            lng: dLng,
            distanciaKm: dKm,
            disponibilidadeDias: dados['disponibilidade_dias'] != null 
                ? List<String>.from(dados['disponibilidade_dias']) 
                : [],
            disponibilidadeInicio: dados['disponibilidade_inicio']?.toString(),
            disponibilidadeFim: dados['disponibilidade_fim']?.toString(),
            documentos: dados['documentos'] != null 
                ? List<String>.from(dados['documentos']) 
                : [],
            utilizadorId: dados['utilizador_id']?.toString(),
          );
          lista.add(trabalhador);
        } catch (e) {
          print('ERRO NA CRIACAO DO OBJETO TrabalhadorModel: $e');
        }
      }

      return lista;
    } catch (e) {
      print('ERRO CRÍTICO EM listarTrabalhadores: $e');
      print('TIPO DO ERRO: ${e.runtimeType}');
      rethrow;
    }
  }

  /// Criar novo card
  Future<void> criarTrabalhador({
    required String nomeTrabalhador,
    required String profissaoTrabalhador,
    required String descricaoTrabalhador,
    required double lat,
    required double lng,
    String? fotoTrabalhador,
    required String utilizadorId,
    List<String> disponibilidadeDias = const [],
    String? disponibilidadeInicio,
    String? disponibilidadeFim,
    List<String> documentos = const [],
  }) async {
    await _client.from('trabalhadores').insert({
      'nome_trabalhador': nomeTrabalhador,
      'profissao_trabalhador': profissaoTrabalhador,
      'descricao_trabalhador': descricaoTrabalhador,
      'lat': lat,
      'lng': lng,
      'foto_trabalhador': fotoTrabalhador,
      'utilizador_id': utilizadorId,
      'disponibilidade_dias': disponibilidadeDias,
      'disponibilidade_inicio': disponibilidadeInicio,
      'disponibilidade_fim': disponibilidadeFim,
      'documentos': documentos,
    });
  }

  /// Meus cards
  Future<List<TrabalhadorModel>> meusCards(String utilizadorId) async {
    final response = await _client
        .from('trabalhadores')
        .select()
        .eq('utilizador_id', utilizadorId);

    final List<TrabalhadorModel> lista = [];
    
    for (final dados in (response as List)) {
      final dLat = Conversao.converterParaDouble(dados['lat']);
      final dLng = Conversao.converterParaDouble(dados['lng']);

      lista.add(TrabalhadorModel(
        id: dados['id'].toString(),
        nomeTrabalhador: dados['nome_trabalhador']?.toString() ?? 'Sem Nome',
        profissaoTrabalhador: dados['profissao_trabalhador']?.toString() ?? 'Trabalhador',
        fotoTrabalhador: dados['foto_trabalhador']?.toString(),
        descricaoTrabalhador: dados['descricao_trabalhador']?.toString(),
        lat: dLat,
        lng: dLng,
        disponibilidadeDias: dados['disponibilidade_dias'] != null 
            ? List<String>.from(dados['disponibilidade_dias']) 
            : [],
        disponibilidadeInicio: dados['disponibilidade_inicio']?.toString(),
        disponibilidadeFim: dados['disponibilidade_fim']?.toString(),
        documentos: dados['documentos'] != null 
            ? List<String>.from(dados['documentos']) 
            : [],
        utilizadorId: dados['utilizador_id']?.toString(),
      ));
    }
    
    return lista;
  }

  /// Atualizar card
  Future<void> atualizarCard({
    required String id,
    required String nomeTrabalhador,
    required String profissaoTrabalhador,
    required String descricaoTrabalhador,
    String? fotoTrabalhador,
    List<String>? disponibilidadeDias,
    String? disponibilidadeInicio,
    String? disponibilidadeFim,
    List<String>? documentos,
  }) async {
    final Map<String, dynamic> dadosParaAtualizar = {
      'nome_trabalhador': nomeTrabalhador,
      'profissao_trabalhador': profissaoTrabalhador,
      'descricao_trabalhador': descricaoTrabalhador,
    };

    if (fotoTrabalhador != null) {
      dadosParaAtualizar['foto_trabalhador'] = fotoTrabalhador;
    }
    if (disponibilidadeDias != null) {
      dadosParaAtualizar['disponibilidade_dias'] = disponibilidadeDias;
    }
    if (disponibilidadeInicio != null) {
      dadosParaAtualizar['disponibilidade_inicio'] = disponibilidadeInicio;
    }
    if (disponibilidadeFim != null) {
      dadosParaAtualizar['disponibilidade_fim'] = disponibilidadeFim;
    }
    if (documentos != null) {
      dadosParaAtualizar['documentos'] = documentos;
    }

    await _client.from('trabalhadores').update(dadosParaAtualizar).eq('id', id);
  }

  /// Eliminar card
  Future<void> eliminarCard(String id) async {
    await _client.from('trabalhadores').delete().eq('id', id);
  }

  /// Faz upload de uma imagem para o Storage e retorna o URL público
  Future<String?> uploadFoto(String caminhoFicheiro) async {
    if (caminhoFicheiro.isEmpty) return null;

    final ficheiro = File(caminhoFicheiro);
    final nomeFicheiro = '${DateTime.now().millisecondsSinceEpoch}_${ficheiro.uri.pathSegments.last}';

    await _client.storage
        .from('fotos')
        .upload('trabalhadores/$nomeFicheiro', ficheiro);

    final url = _client.storage
        .from('fotos')
        .getPublicUrl('trabalhadores/$nomeFicheiro');

    return url;
  }

  /// Faz upload de múltiplos documentos para o Storage e retorna os URLs públicos
  Future<List<String>> uploadDocumentos(List<String> caminhos) async {
    final urls = <String>[];
    for (final caminho in caminhos) {
      final ficheiro = File(caminho);
      final nome = '${DateTime.now().millisecondsSinceEpoch}_${ficheiro.uri.pathSegments.last}';
      await _client.storage.from('documentos').upload('documentos/$nome', ficheiro);
      urls.add(_client.storage.from('documentos').getPublicUrl('documentos/$nome'));
    }
    return urls;
  }

  // ---------- SISTEMA DE AVALIAÇÕES ----------

  /// Adiciona uma nova avaliação
  Future<void> adicionarAvaliacao({
    required String trabalhadorId,
    String? utilizadorId,
    required int estrelas,
    required String comentario,
    String? nomeAvaliador,
  }) async {
    await _client.from('avaliacoes').insert({
      'trabalhador_id': int.parse(trabalhadorId),
      'utilizador_id': utilizadorId,
      'estrelas': estrelas,
      'comentario': comentario,
      'nome_avaliador': nomeAvaliador,
    });
  }

  /// Procura avaliações de um trabalhador
  Future<List<Map<String, dynamic>>> obterAvaliacoes(String trabalhadorId) async {
    final response = await _client
        .from('avaliacoes')
        .select('*, utilizadores(nome_usuario)')
        .eq('trabalhador_id', int.parse(trabalhadorId))
        .order('criado_em', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Adiciona resposta do profissional a uma avaliação
  Future<void> responderAvaliacao({
    required int avaliacaoId,
    required String resposta,
  }) async {
    await _client.from('avaliacoes').update({
      'resposta': resposta,
    }).eq('id', avaliacaoId);
  }

  /// Calcula a média de avaliações de um trabalhador
  Future<Map<String, dynamic>> obterMediaAvaliacoes(String trabalhadorId) async {
    try {
      final response = await _client
          .from('avaliacoes')
          .select('estrelas')
          .eq('trabalhador_id', int.parse(trabalhadorId));
      
      final List<dynamic> data = response as List;
      if (data.isEmpty) return {'media': 0.0, 'total': 0};

      final totalEstrelas = data.fold<int>(0, (sum, item) => sum + (item['estrelas'] as int));
      return {
        'media': totalEstrelas / data.length,
        'total': data.length,
      };
    } catch (e) {
      return {'media': 0.0, 'total': 0};
    }
  }

  /// Obter avaliações de todos os cards de um profissional
  Future<List<Map<String, dynamic>>> obterAvaliacoesPorProfissional(String utilizadorId) async {
    try {
      // Buscar cards do utilizador
      final responseCards = await _client
          .from('trabalhadores')
          .select('id')
          .eq('utilizador_id', utilizadorId);

      final List<dynamic> cards = responseCards as List;
      final idsCards = cards.map((c) => c['id']).toList();

      if (idsCards.isEmpty) return [];

      // Buscar avaliações desses cards
      final responseAvaliacoes = await _client
          .from('avaliacoes')
          .select('*, trabalhadores(nome_trabalhador, profissao_trabalhador), utilizadores(nome_usuario)')
          .inFilter('trabalhador_id', idsCards)
          .order('criado_em', ascending: false);

      return List<Map<String, dynamic>>.from(responseAvaliacoes);
    } catch (e) {
      print('Erro em obterAvaliacoesPorProfissional: $e');
      return [];
    }
  }

  double _calcularDistancia(double lat1, double lng1, double lat2, double lng2) {
    const double R = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = _sin(dLat / 2.0) * _sin(dLat / 2.0) +
        _cos(_rad(lat1)) * _cos(_rad(lat2)) * _sin(dLng / 2.0) * _sin(dLng / 2.0);
    final c = 2.0 * _atan2(_sqrt(a), _sqrt(1.0 - a));
    return R * c;
  }

  double _rad(double deg) => deg * 3.1415926535 / 180.0;
  double _sin(double x) => x - x * x * x / 6.0 + x * x * x * x * x / 120.0;
  double _cos(double x) => 1.0 - x * x / 2.0 + x * x * x * x / 24.0;
  double _sqrt(double x) => x < 0 ? 0.0 : (x + 1.0) / 2.0;
  double _atan2(double y, double x) => y / (x == 0 ? 0.001 : x);
}
