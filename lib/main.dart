import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'provedores/estado_global.dart';
import 'telas/tela_feed.dart';
import 'telas/tela_painel_profissional.dart';
import 'servicos/auth_service.dart';
import 'servicos/supabase_service.dart';
import 'servicos/servico_atualizacao.dart';

// Novos imports para teste visual
import 'temas/cores_novo.dart';
import 'temas/tema_novo.dart';
import 'telas/tela_feed_novo.dart';
import 'telas/tela_login_novo.dart';
import 'telas/professional/tela_dashboard_novo.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

RealtimeChannel? _notificacoesChannel;

/// Para o listener de notificações em tempo real (chamado no logout)
void pararNotificacoesTempoReal() {
  _notificacoesChannel?.unsubscribe();
  _notificacoesChannel = null;
  // Limpar o cache do último utilizador para permitir re-subscrição se alguém logar de novo
  if (_rotaInicialKey.currentState != null) {
    _rotaInicialKey.currentState!._resetLastUserId();
  }
  print('DEBUG: Realtime Channel fechado globalmente.');
}

final GlobalKey<_RotaInicialState> _rotaInicialKey = GlobalKey<_RotaInicialState>();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'mensagens_channel',
  'Mensagens',
  description: 'Notificações de mensagens do Lirify',
  importance: Importance.max,
);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  
  // Mostrar notificação local mesmo com app fechado
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'mensagens_channel',
    'Mensagens',
    channelDescription: 'Notificações de mensagens do Lirify',
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  final NotificationDetails details = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    message.notification?.title ?? 'Nova mensagem',
    message.notification?.body ?? 'Tens uma nova mensagem',
    details,
  );
}

Future<void> _configurarNotificacoes() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Foreground listener
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializar Firebase PRIMEIRO
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _configurarNotificacoes();
  } catch (e) {
    print("Erro ao inicializar Firebase: $e");
  }

  // 2. Inicializar Supabase DEPOIS
  await Supabase.initialize(
    url: 'https://kmtrhcuarprwovueqnmg.supabase.co',
    anonKey: 'sb_publishable_nQRcQO49GKcYXHeO4JBZkg_qkryHtMU',
  );

  runApp(const LirifyApp());
}

class LirifyApp extends StatelessWidget {
  const LirifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EstadoGlobal(),
      child: MaterialApp(
        title: 'Lirify',
        debugShowCheckedModeBanner: false,
        theme: TemaNovo.lightTheme, // Usando o novo tema para teste
        darkTheme: TemaNovo.darkTheme,
        themeMode: ThemeMode.light,
        home: const RotaInicialWrapper(),
      ),
    );
  }
}

class RotaInicial extends StatefulWidget {
  const RotaInicial({super.key});

  @override
  State<RotaInicial> createState() => _RotaInicialState();
}

class _RotaInicialState extends State<RotaInicial> {
  bool _carregando = true;
  String? _lastUserId;

  void _resetLastUserId() {
    _lastUserId = null;
  }

  @override
  void initState() {
    super.initState();
    _verificarSessao();
  }

  Future<void> _verificarAtualizacao() async {
    final atualizacaoDisponivel = await ServicoAtualizacao.verificarAtualizacao();

    if (atualizacaoDisponivel && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Nova versão disponível!'),
          content: const Text('Há uma nova versão do Lirify com correções e melhorias. Deseja atualizar agora?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Agora não'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ServicoAtualizacao.abrirDownload();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Atualizar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  void _configurarNotificacoesTempoReal(String utilizadorId) {
    if (_lastUserId == utilizadorId) return; // Já está ouvindo para este usuário
    _lastUserId = utilizadorId;

    final client = Supabase.instance.client;
    final supabaseService = SupabaseService();

    // Fechar canal anterior se existir
    _notificacoesChannel?.unsubscribe();

    _notificacoesChannel = client
        .channel('notificacoes_repo')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'mensagens',
          callback: (payload) async {
            final novo = payload.newRecord;
            final trabalhadorId = novo['trabalhador_id'];
            final remetenteId = novo['remetente_id'];
            final clienteIdMsg = novo['cliente_id'];

            if (remetenteId == utilizadorId) return;

            _recalcularBadges(utilizadorId);

            if (clienteIdMsg == utilizadorId) {
              _mostrarNotificacaoMensagem(novo);
              if (novo['estado'] == 'enviado') {
                SupabaseService().atualizarEstadoMensagem(novo['id'], 'entregue');
              }
              return;
            }

            try {
              final response = await client
                  .from('trabalhadores')
                  .select('utilizador_id')
                  .eq('id', trabalhadorId)
                  .single();

              if (response['utilizador_id'] == utilizadorId) {
                _mostrarNotificacaoMensagem(novo);
                if (novo['estado'] == 'enviado') {
                  SupabaseService().atualizarEstadoMensagem(novo['id'], 'entregue');
                }
              }
            } catch (e) {}
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'avaliacoes',
          callback: (payload) async {
            final novo = payload.newRecord;
            final trabalhadorId = novo['trabalhador_id'];
            final remetenteId = novo['utilizador_id']; // ID de quem avaliou

            if (remetenteId == utilizadorId) return;

            try {
              final response = await client
                  .from('trabalhadores')
                  .select('utilizador_id, nome_trabalhador')
                  .eq('id', trabalhadorId)
                  .single();

              if (response['utilizador_id'] == utilizadorId) {
                print('DEBUG: Recebeu uma nova avaliação no card ${response['nome_trabalhador']}');
                _mostrarNotificacaoAvaliacao(novo, response['nome_trabalhador']);
              }
            } catch (e) {
              print('Erro ao verificar dono da avaliação: $e');
            }
          },
        );
    
    _notificacoesChannel!.subscribe();
  }

  /// Recalcula o total de conversas/mensagens não lidas e atualiza o Provider
  Future<void> _recalcularBadges(String utilizadorId) async {
    if (!mounted) return;
    final estado = Provider.of<EstadoGlobal>(context, listen: false);
    
    print('DEBUG: Recalculando badges para o utilizador $utilizadorId...');
    // Busca o total atualizado no servidor
    final total = await SupabaseService().obterTotalConversasNaoLidas(utilizadorId);

    if (mounted) {
      estado.atualizarTotalConversas(total);
      print('DEBUG: Provider atualizado. Novo total global: $total');
    }
  }

  void _mostrarNotificacaoMensagem(Map<String, dynamic> novo) {
    flutterLocalNotificationsPlugin.show(
      novo['id'],
      'Nova mensagem!',
      '${novo['remetente_nome']}: ${novo['mensagem']}',
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  void _mostrarNotificacaoAvaliacao(Map<String, dynamic> novo, String nomeCard) {
    final estrelas = novo['estrelas'] ?? 5;
    flutterLocalNotificationsPlugin.show(
      novo['id'],
      'Nova Avaliação ⭐',
      'Recebeste $estrelas estrelas no teu card "$nomeCard"!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'avaliacoes_channel',
          'Avaliações',
          channelDescription: 'Notificações de novas avaliações recebidas',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  Future<void> _verificarSessao() async {
    final authService = AuthService();
    final supabaseService = SupabaseService();

    try {
      final utilizador = await authService.obterUtilizadorAtual();

      if (utilizador != null && mounted) {
        Provider.of<EstadoGlobal>(context, listen: false)
            .definirUsuarioLogado(utilizador);

        // Atualiza o token push no servidor
        authService.salvarTokenPush(utilizador.id);

        // Ativa notificações em tempo real
        _configurarNotificacoesTempoReal(utilizador.id);

        // Inicializar contagem de badges
        _recalcularBadges(utilizador.id);

        // Buscar notificações pendentes APENAS se estiver logado
        print('DEBUG: Verificando pendentes para: ${utilizador.id}');
        final pendentes = await supabaseService.obterNotificacoesPendentes(utilizador.id);
        print('DEBUG: Pendentes encontradas: ${pendentes.length}');

        if (pendentes.isNotEmpty && mounted) {
          int contador = 0;
          for (final p in pendentes) {
            print('DEBUG: Mostrando pendente: ${p['titulo']}');
            // Mostrar notificação local após um pequeno atraso para cada uma
            Future.delayed(Duration(seconds: contador * 3), () async {
              if (mounted) {
                _mostrarNotificacaoMensagem(p);
                // Apagar do banco após mostrar
                await supabaseService.apagarNotificacaoPendente(p['id']);
              }
            });
            contador++;
          }
        }
      }
    } catch (e) {
      // Sessão não existe ou expirou — continua sem login
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
        _verificarAtualizacao();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: CoresNovo.navyPrimary),
        ),
      );
    }

    final estado = Provider.of<EstadoGlobal>(context);
    
    if (estado.modoProfissional) {
      return TelaDashboardNovo();
    }
    
    return TelaFeedNovo();
  }
}

class RotaInicialWrapper extends StatelessWidget {
  const RotaInicialWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const RotaInicial();
  }
}
