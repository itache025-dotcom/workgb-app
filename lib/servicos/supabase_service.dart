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
            galeria: dados['galeria'] != null 
                ? List<String>.from(dados['galeria']) 
                : [],
            utilizadorId: dados['utilizador_id']?.toString(),
            mediaAvaliacoes: (dados['media_avaliacoes'] as num?)?.toDouble() ?? 0.0,
            totalAvaliacoes: (dados['total_avaliacoes'] as num?)?.toInt() ?? 0,
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
    List<String> galeria = const [],
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
      'galeria': galeria,
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
        galeria: dados['galeria'] != null 
            ? List<String>.from(dados['galeria']) 
            : [],
        utilizadorId: dados['utilizador_id']?.toString(),
        mediaAvaliacoes: (dados['media_avaliacoes'] as num?)?.toDouble() ?? 0.0,
        totalAvaliacoes: (dados['total_avaliacoes'] as num?)?.toInt() ?? 0,
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
    List<String>? galeria,
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
    if (galeria != null) {
      dadosParaAtualizar['galeria'] = galeria;
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

  /// Upload de foto para a galeria
  Future<String> uploadFotoGaleria(File ficheiro) async {
    final nome = '${DateTime.now().millisecondsSinceEpoch}_galeria.jpg';
    await _client.storage.from('fotos').upload('galeria/$nome', ficheiro);
    return _client.storage.from('fotos').getPublicUrl('galeria/$nome');
  }

  /// Adicionar foto à lista da galeria no banco
  Future<void> adicionarFotoGaleria(String trabalhadorId, String url) async {
    final response = await _client.from('trabalhadores')
        .select('galeria')
        .eq('id', trabalhadorId)
        .single();
    
    final galeria = List<String>.from(response['galeria'] ?? []);
    galeria.add(url);
    
    await _client.from('trabalhadores')
        .update({'galeria': galeria})
        .eq('id', trabalhadorId);
  }

  /// Remover foto da galeria
  Future<void> removerFotoGaleria(String trabalhadorId, String url) async {
    final response = await _client.from('trabalhadores')
        .select('galeria')
        .eq('id', trabalhadorId)
        .single();
    
    final galeria = List<String>.from(response['galeria'] ?? []);
    galeria.remove(url);
    
    await _client.from('trabalhadores')
        .update({'galeria': galeria})
        .eq('id', trabalhadorId);
  }

  /// Verificar se um utilizador já tem perfil de profissional (pelo menos um card)
  Future<bool> verificarSeProfissional(String utilizadorId) async {
    try {
      final response = await _client
          .from('trabalhadores')
          .select('id')
          .eq('utilizador_id', utilizadorId)
          .limit(1);
      
      return (response as List).isNotEmpty;
    } catch (e) {
      print('Erro ao verificar se profissional: $e');
      return false;
    }
  }

  /// Atualizar foto de perfil do utilizador
  Future<void> atualizarFotoPerfil(String utilizadorId, String url) async {
    await _client.from('utilizadores')
        .update({'foto_usuario': url})
        .eq('id', utilizadorId);
  }

  /// Atualizar profissão do utilizador
  Future<void> atualizarProfissao(String utilizadorId, String profissao) async {
    await _client.from('utilizadores')
        .update({'profissao': profissao})
        .eq('id', utilizadorId);
  }

  /// Incrementar contador de visualizações de um card (via RPC)
  Future<void> incrementarVisualizacao(String trabalhadorId) async {
    print('DEBUG VISUALIZACAO: Iniciando para card $trabalhadorId');
    try {
      final tId = int.parse(trabalhadorId);
      final resultado = await _client.rpc('increment_view', params: {'row_id': tId});
      print('DEBUG VISUALIZACAO: RPC sucesso. Resultado: $resultado');
    } catch (e) {
      print('DEBUG VISUALIZACAO ERRO: $e');
    }
  }

  /// Obter estatísticas (visualizações e contactos) para uma lista de cards
  Future<Map<String, int>> obterEstatisticas(List<int> idsCards) async {
    try {
      if (idsCards.isEmpty) return {'visualizacoes': 0, 'contactos': 0};

      final response = await _client
          .from('estatisticas')
          .select('visualizacoes, contactos')
          .inFilter('trabalhador_id', idsCards);
      
      final List<dynamic> data = response as List;
      int vis = 0;
      int con = 0;

      for (var item in data) {
        vis += (item['visualizacoes'] as int? ?? 0);
        con += (item['contactos'] as int? ?? 0);
      }

      return {'visualizacoes': vis, 'contactos': con};
    } catch (e) {
      print('Erro ao obter estatísticas: $e');
      return {'visualizacoes': 0, 'contactos': 0};
    }
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

  // ---------- SISTEMA DE CHAT ----------

  /// Enviar mensagem
  Future<void> enviarMensagem({
    required int trabalhadorId,
    String? remetenteId,
    String? remetenteNome,
    required String mensagem,
    String? clienteId, // ID do cliente na conversa
    String tipo = 'texto',
    String? urlMidia,
    String? duracaoAudio,
  }) async {
    await _client.from('mensagens').insert({
      'trabalhador_id': trabalhadorId,
      'remetente_id': remetenteId,
      'remetente_nome': remetenteNome ?? 'Anônimo',
      'mensagem': mensagem,
      'cliente_id': clienteId ?? remetenteId, // Se for o cliente a enviar, cliente_id = remetente_id
      'estado': 'enviado',
      'tipo': tipo,
      'url_midia': urlMidia,
      'duracao_audio': duracaoAudio,
    });
  }

  /// Faz upload de uma mídia (foto ou vídeo) para o Storage e retorna o URL público
  Future<String?> uploadMidia(String caminhoFicheiro, String tipo) async {
    if (caminhoFicheiro.isEmpty) return null;

    final ficheiro = File(caminhoFicheiro);
    if (!await ficheiro.exists()) {
      print('DEBUG STORAGE: Ficheiro não encontrado para upload: $caminhoFicheiro');
      return null;
    }

    final nome = '${DateTime.now().millisecondsSinceEpoch}_${ficheiro.uri.pathSegments.last}';
    final path = '$tipo/$nome';

    await _client.storage
        .from('chat_midia')
        .upload(path, ficheiro);

    // Constrói o URL público garantindo o uso do domínio correto do projeto
    const String urlBase = 'https://kmtrhcuarprwovueqnmg.supabase.co';
    final String url = '$urlBase/storage/v1/object/public/chat_midia/$path';
    
    print('DEBUG: URL da mídia gerada: $url');

    return url;
  }

  /// Faz upload de um áudio para o Storage e retorna o URL público
  Future<String?> uploadAudio(String caminhoFicheiro) async {
    if (caminhoFicheiro.isEmpty) return null;

    final ficheiro = File(caminhoFicheiro);
    if (!await ficheiro.exists()) {
      print('DEBUG AUDIO: Erro no upload - Ficheiro não existe em $caminhoFicheiro');
      return null;
    }

    final nome = '${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _client.storage
        .from('audios')
        .upload('mensagens/$nome', ficheiro);

    return _client.storage
        .from('audios')
        .getPublicUrl('mensagens/$nome');
  }

  /// Obter todas as conversas do utilizador (como cliente ou profissional)
  Future<List<Map<String, dynamic>>> obterConversas(String utilizadorId) async {
    try {
      // 1. Buscar os IDs dos cards do profissional
      final cards = await _client.from('trabalhadores').select('id').eq('utilizador_id', utilizadorId);
      final idsCards = (cards as List).map((c) => c['id']).toList();
      
      // 2. Construir o filtro: Mensagens onde sou o cliente OU onde o card destino é meu
      String filtro = 'cliente_id.eq.$utilizadorId';
      if (idsCards.isNotEmpty) {
        filtro += ',trabalhador_id.in.(${idsCards.join(",")})';
      }

      final response = await _client
          .from('mensagens')
          .select('*, trabalhadores(id, nome_trabalhador, profissao_trabalhador, foto_trabalhador, utilizador_id, descricao_trabalhador)')
          .or(filtro)
          .order('criado_em', ascending: false);
      
      final todasMensagens = List<Map<String, dynamic>>.from(response);
      
      // 3. Agrupar por conversa única (trabalhador_id + cliente_id)
      final Map<String, Map<String, dynamic>> conversasMap = {};
      for (var msg in todasMensagens) {
        final key = "${msg['trabalhador_id']}_${msg['cliente_id']}";
        if (!conversasMap.containsKey(key)) {
          final isProfessionalRole = msg['trabalhadores']['utilizador_id'] == utilizadorId;
          
          String displayNome = 'Cliente';
          String? displayFoto;

          if (isProfessionalRole) {
            // Sou o profissional: O título deve ser o nome do cliente
            if (msg['remetente_id'] != utilizadorId) {
              displayNome = msg['remetente_nome'] ?? 'Cliente';
            } else {
              // Se a última mensagem foi minha, procurar o nome do cliente em mensagens anteriores
              try {
                final clientMsg = todasMensagens.firstWhere(
                  (m) => "${m['trabalhador_id']}_${m['cliente_id']}" == key && m['remetente_id'] != utilizadorId,
                );
                displayNome = clientMsg['remetente_nome'] ?? 'Cliente';
              } catch (e) {
                displayNome = 'Cliente';
              }
            }
          } else {
            // Sou o cliente: O título deve ser o nome do profissional/card
            displayNome = msg['trabalhadores']['nome_trabalhador'] ?? 'Profissional';
            displayFoto = msg['trabalhadores']['foto_trabalhador'];
          }

          conversasMap[key] = {
            ...msg,
            'display_nome': displayNome,
            'display_foto': displayFoto,
          };
        }
      }

      print('DEBUG CONVERSAS: Encontradas ${conversasMap.length} conversas únicas para o utilizador $utilizadorId');
      return conversasMap.values.toList();
    } catch (e) {
      print('ERRO EM obterConversas: $e');
      return [];
    }
  }

  /// Obter mensagens de um trabalhador e cliente específicos (conversa privada)
  Future<List<Map<String, dynamic>>> obterMensagensPrivadas({
    required int trabalhadorId,
    required String clienteId,
  }) async {
    final response = await _client
        .from('mensagens')
        .select()
        .eq('trabalhador_id', trabalhadorId)
        .eq('cliente_id', clienteId)
        .order('criado_em', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Obter cards que têm mensagens (para o profissional)
  Future<List<Map<String, dynamic>>> obterCardsComMensagens(String utilizadorId) async {
    // 1. Obter todos os cards do profissional
    final responseCards = await _client
        .from('trabalhadores')
        .select('id, nome_trabalhador, profissao_trabalhador')
        .eq('utilizador_id', utilizadorId);

    final List<dynamic> cards = responseCards as List;
    if (cards.isEmpty) return [];

    final idsCards = cards.map((c) => c['id']).toList();

    // 2. Buscar as mensagens mais recentes para esses cards
    final responseMsgs = await _client
        .from('mensagens')
        .select('trabalhador_id, criado_em')
        .inFilter('trabalhador_id', idsCards)
        .order('criado_em', ascending: false);

    final List<dynamic> msgs = responseMsgs as List;
    if (msgs.isEmpty) return [];

    // 3. Cruzar dados para retornar lista de cards com info de atividade
    final resultado = <Map<String, dynamic>>[];
    final idsProcessados = <int>{};

    for (var card in cards) {
      final cardId = card['id'];
      final temAtividade = msgs.any((m) => m['trabalhador_id'] == cardId);
      
      if (temAtividade && !idsProcessados.contains(cardId)) {
        idsProcessados.add(cardId);
        resultado.add(card);
      }
    }

    return resultado;
  }

  /// Obter lista de clientes que enviaram mensagens para um card específico
  Future<List<Map<String, dynamic>>> obterClientesPorCard(int trabalhadorId) async {
    print('DEBUG: Buscando clientes do card: $trabalhadorId');

    // 1. Buscar todas as mensagens do card ordenadas por data
    final response = await _client
        .from('mensagens')
        .select('cliente_id, mensagem, criado_em, lida, remetente_id, estado, tipo')
        .eq('trabalhador_id', trabalhadorId)
        .order('criado_em', ascending: false);

    final List<dynamic> mensagens = response as List;
    print('DEBUG: Total de mensagens encontradas: ${mensagens.length}');

    final clientes = <Map<String, dynamic>>[];
    final idsVistos = <String>{};

    for (var msg in mensagens) {
      final cId = msg['cliente_id']?.toString() ?? '';
      if (cId.isEmpty || idsVistos.contains(cId)) continue;
      
      idsVistos.add(cId);

      // 2. Buscar o nome real do cliente na tabela utilizadores (Garante precisão)
      String nomeReal = 'Cliente';
      try {
        final dadosCliente = await _client
            .from('utilizadores')
            .select('nome_usuario')
            .eq('id', cId)
            .single();
        nomeReal = dadosCliente['nome_usuario'] ?? 'Anônimo';
      } catch (e) {
        print('Erro ao buscar nome do cliente $cId: $e');
      }

      final tipo = msg['tipo'] ?? 'texto';
      final ultimaMsg = tipo == 'texto' 
          ? msg['mensagem'] 
          : tipo == 'imagem' ? '📷 Imagem' : '🎥 Vídeo';

      clientes.add({
        'cliente_id': cId,
        'nome_cliente': nomeReal,
        'ultima_mensagem': ultimaMsg,
        'criado_em': msg['criado_em'],
        'lida': msg['lida'],
        'remetente_id': msg['remetente_id'],
        'estado': msg['estado'],
      });
    }

    print('DEBUG: Clientes únicos identificados: ${clientes.length}');
    return clientes;
  }

  /// Apagar mensagem
  Future<void> apagarMensagem(int mensagemId) async {
    await _client.from('mensagens').delete().eq('id', mensagemId);
  }

  /// Obter todas as mensagens recebidas por um profissional (legado, mantido por compatibilidade)
  Future<List<Map<String, dynamic>>> obterMensagensPorProfissional(String utilizadorId) async {
    try {
      final responseCards = await _client
          .from('trabalhadores')
          .select('id')
          .eq('utilizador_id', utilizadorId);

      final List<dynamic> cards = responseCards as List;
      final idsCards = cards.map((c) => c['id']).toList();

      if (idsCards.isEmpty) return [];

      final responseMensagens = await _client
          .from('mensagens')
          .select('*, trabalhadores(nome_trabalhador, profissao_trabalhador)')
          .inFilter('trabalhador_id', idsCards)
          .order('criado_em', ascending: false);

      return List<Map<String, dynamic>>.from(responseMensagens);
    } catch (e) {
      print('Erro em obterMensagensPorProfissional: $e');
      return [];
    }
  }

  /// Obter todas as conversas iniciadas por um utilizador (Cliente)
  Future<List<Map<String, dynamic>>> obterConversasCliente({String? utilizadorId}) async {
    try {
      if (utilizadorId == null) return [];

      // Busca mensagens onde eu sou o cliente (mesmo se a última for do profissional)
      final response = await _client
          .from('mensagens')
          .select('*, trabalhadores(id, nome_trabalhador, profissao_trabalhador, foto_trabalhador, utilizador_id, descricao_trabalhador)')
          .eq('cliente_id', utilizadorId)
          .order('criado_em', ascending: false);

      final List<Map<String, dynamic>> lista = List<Map<String, dynamic>>.from(response);
      
      // Ajusta o texto da última mensagem se for mídia
      for (var item in lista) {
        final tipo = item['tipo'] ?? 'texto';
        if (tipo != 'texto') {
          item['mensagem'] = tipo == 'imagem' ? '📷 Imagem' : '🎥 Vídeo';
        }
      }

      return lista;
    } catch (e) {
      print('Erro em obterConversasCliente: $e');
      return [];
    }
  }

  /// Obter total de mensagens não lidas do cliente (Universal)
  Future<int> obterTotalMensagensNaoLidasCliente(String clienteId) async {
    try {
      final response = await _client
          .from('mensagens')
          .select('id')
          .eq('cliente_id', clienteId)
          .eq('lida', false)
          .neq('remetente_id', clienteId);

      return (response as List).length;
    } catch (e) {
      print('Erro em obterTotalMensagensNaoLidasCliente: $e');
      return 0;
    }
  }

  /// Obter total de conversas com mensagens não lidas para um utilizador (Universal)
  Future<int> obterTotalConversasNaoLidas(String utilizadorId) async {
    try {
      // 1. Buscar os IDs dos cards do profissional
      final cards = await _client.from('trabalhadores')
          .select('id')
          .eq('utilizador_id', utilizadorId);
      
      final idsCards = (cards as List).map((c) => c['id']).toList();
      
      // 2. Construir o filtro: Mensagens destinadas ao utilizador (como cliente ou dono do card)
      String filtro = 'cliente_id.eq.$utilizadorId';
      if (idsCards.isNotEmpty) {
        filtro += ',trabalhador_id.in.(${idsCards.join(",")})';
      }

      final response = await _client
          .from('mensagens')
          .select('cliente_id, trabalhador_id')
          .or(filtro)
          .eq('lida', false)
          .neq('remetente_id', utilizadorId);

      final List<dynamic> data = response as List;
      
      // Agrupar por conversa única (trabalhador_id + cliente_id)
      final conversasUnicas = <String>{};
      for (var m in data) {
        final key = "${m['trabalhador_id']}_${m['cliente_id']}";
        conversasUnicas.add(key);
      }
      
      print('DEBUG: Total de conversas únicas não lidas para $utilizadorId: ${conversasUnicas.length}');
      return conversasUnicas.length;
    } catch (e) {
      print('Erro em obterTotalConversasNaoLidas: $e');
      return 0;
    }
  }

  /// Obter número de mensagens não lidas numa conversa específica (Universal)
  Future<int> obterMensagensNaoLidasConversa({
    required int trabalhadorId,
    required String clienteId,
    required String utilizadorId,
  }) async {
    try {
      final response = await _client
          .from('mensagens')
          .select('id')
          .eq('trabalhador_id', trabalhadorId)
          .eq('cliente_id', clienteId)
          .eq('lida', false)
          .neq('remetente_id', utilizadorId);

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  /// Obter número de clientes com mensagens não lidas por card
  Future<int> obterClientesNaoLidosPorCard(int trabalhadorId, String utilizadorVisualizandoId) async {
    try {
      final response = await _client
          .from('mensagens')
          .select('cliente_id')
          .eq('trabalhador_id', trabalhadorId)
          .eq('lida', false)
          .neq('remetente_id', utilizadorVisualizandoId) // Ignora mensagens do próprio utilizador
          .order('criado_em', ascending: false);

      final ids = (response as List).map((m) => m['cliente_id']).toSet();
      return ids.length;
    } catch (e) {
      return 0;
    }
  }

  /// Obter número de mensagens não lidas por conversa específica
  Future<int> obterMensagensNaoLidas({
    required int trabalhadorId,
    required String clienteId,
    required String utilizadorVisualizandoId,
  }) async {
    try {
      final response = await _client
          .from('mensagens')
          .select('id')
          .eq('trabalhador_id', trabalhadorId)
          .eq('cliente_id', clienteId)
          .eq('lida', false)
          .neq('remetente_id', utilizadorVisualizandoId) // Ignora mensagens do próprio utilizador
          .order('criado_em', ascending: false);

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  /// Marcar mensagens como lidas em uma conversa
  Future<void> marcarComoLidas({
    required int trabalhadorId,
    required String clienteId,
    required String utilizadorVisualizandoId,
  }) async {
    try {
      print('DEBUG: Marcando como lidas — card: $trabalhadorId, cliente: $clienteId');
      
      // Marcamos como lida apenas as mensagens que NÃO foram enviadas pelo utilizador atual
      final resposta = await _client
          .from('mensagens')
          .update({'lida': true, 'estado': 'lido'})
          .eq('trabalhador_id', trabalhadorId)
          .eq('cliente_id', clienteId)
          .neq('remetente_id', utilizadorVisualizandoId)
          .eq('lida', false)
          .select();

      print('DEBUG: Atualizadas: ${(resposta as List).length} mensagens como lidas');
    } catch (e) {
      print('Erro ao marcar mensagens como lidas: $e');
    }
  }

  /// Atualiza o estado de uma mensagem específica (ex: para 'entregue')
  Future<void> atualizarEstadoMensagem(int mensagemId, String novoEstado) async {
    try {
      await _client
          .from('mensagens')
          .update({'estado': novoEstado})
          .eq('id', mensagemId);
    } catch (e) {
      print('Erro ao atualizar estado da mensagem: $e');
    }
  }

  /// Obter notificações pendentes para um utilizador
  Future<List<Map<String, dynamic>>> obterNotificacoesPendentes(String utilizadorId) async {
    try {
      final response = await _client
          .from('notificacoes_pendentes')
          .select()
          .eq('recetor_id', utilizadorId)
          .eq('lida', false)
          .order('criado_em', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro em obterNotificacoesPendentes: $e');
      return [];
    }
  }

  /// Apagar notificação pendente após entrega
  Future<void> apagarNotificacaoPendente(int id) async {
    try {
      await _client.from('notificacoes_pendentes').delete().eq('id', id);
    } catch (e) {
      print('Erro ao apagar notificação pendente: $e');
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
