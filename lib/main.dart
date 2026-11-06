import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

const Color _ink = Color(0xFF17233C);
const Color _muted = Color(0xFF718096);
const Color _canvas = Color(0xFFF5F7FB);
const Color _primary = Color(0xFF4056D6);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // O Android exibe automaticamente as mensagens que contêm um payload
  // notification quando o aplicativo está em segundo plano.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  runApp(const EstudosPushApp());
}

class StudySubject {
  const StudySubject({
    required this.id,
    required this.title,
    required this.shortTitle,
    required this.category,
    required this.description,
    required this.duration,
    required this.icon,
    required this.color,
    required this.topics,
    required this.goal,
  });

  final String id;
  final String title;
  final String shortTitle;
  final String category;
  final String description;
  final String duration;
  final IconData icon;
  final Color color;
  final List<String> topics;
  final String goal;

  static StudySubject? findById(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final subject in studySubjects) {
      if (subject.id == id) return subject;
    }
    return null;
  }
}

const List<StudySubject> studySubjects = [
  StudySubject(
    id: 'flutter',
    title: 'Flutter e Desenvolvimento Mobile',
    shortTitle: 'Flutter',
    category: 'Desenvolvimento mobile',
    description:
        'Estude a construção de aplicativos multiplataforma com Flutter e Dart, desde a estrutura de widgets até a integração com serviços externos.',
    duration: '45 minutos',
    icon: Icons.phone_android_rounded,
    color: Color(0xFF3478C8),
    topics: [
      'Estrutura de um projeto Flutter',
      'Widgets, layouts e navegação',
      'Gerenciamento de estado',
      'Integração com Firebase Cloud Messaging',
    ],
    goal: 'Construir e executar um aplicativo funcional em um dispositivo Android.',
  ),
  StudySubject(
    id: 'banco_dados',
    title: 'Banco de Dados',
    shortTitle: 'Banco de Dados',
    category: 'Dados e persistência',
    description:
        'Revise modelagem relacional, consultas SQL e os mecanismos usados para garantir consistência e integridade dos dados.',
    duration: '50 minutos',
    icon: Icons.storage_rounded,
    color: Color(0xFF168B83),
    topics: [
      'Modelo relacional e normalização',
      'SELECT, JOIN e subconsultas',
      'Constraints e integridade',
      'Triggers e procedimentos em PostgreSQL',
    ],
    goal: 'Elaborar consultas corretas e validar regras de negócio no banco.',
  ),
  StudySubject(
    id: 'algoritmos',
    title: 'Algoritmos e Estruturas de Dados',
    shortTitle: 'Algoritmos',
    category: 'Programação',
    description:
        'Pratique técnicas de resolução de problemas e estruturas fundamentais para organizar e processar informações.',
    duration: '40 minutos',
    icon: Icons.account_tree_rounded,
    color: Color(0xFF8A5BC2),
    topics: [
      'Análise de complexidade',
      'Listas, pilhas e filas',
      'Árvores de busca',
      'Algoritmos de ordenação e grafos',
    ],
    goal: 'Selecionar uma estrutura adequada para cada tipo de problema.',
  ),
  StudySubject(
    id: 'engenharia',
    title: 'Engenharia de Software',
    shortTitle: 'Engenharia de Software',
    category: 'Processos e qualidade',
    description:
        'Estude os processos de desenvolvimento, os requisitos e as práticas que ajudam a construir software confiável.',
    duration: '35 minutos',
    icon: Icons.design_services_rounded,
    color: Color(0xFFD17B38),
    topics: [
      'Levantamento de requisitos',
      'Modelagem e documentação',
      'Testes de software',
      'Manutenção e qualidade',
    ],
    goal: 'Relacionar requisitos, projeto, implementação e validação.',
  ),
  StudySubject(
    id: 'redes',
    title: 'Redes de Computadores',
    shortTitle: 'Redes',
    category: 'Infraestrutura',
    description:
        'Revise os fundamentos da comunicação entre dispositivos e a configuração de redes locais.',
    duration: '30 minutos',
    icon: Icons.router_rounded,
    color: Color(0xFF397D68),
    topics: [
      'Endereçamento IPv4 e máscaras',
      'Gateway e DNS',
      'Switches, bridges e roteamento',
      'Serviços e diagnóstico de rede',
    ],
    goal: 'Interpretar uma topologia e determinar configurações básicas de rede.',
  ),
];

class EstudosPushApp extends StatelessWidget {
  const EstudosPushApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Estudos Push',
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: _canvas,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: _canvas,
          foregroundColor: _ink,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE9EDF5)),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<String>? _tokenSubscription;

  String? _fcmToken;
  String _permissionStatus = 'Verificando permissão';
  String? _connectionError;
  bool _isLoadingPush = true;

  @override
  void initState() {
    super.initState();

    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleNotificationTap,
    );
    _tokenSubscription = FirebaseMessaging.instance.onTokenRefresh.listen(
      (token) {
        if (mounted) setState(() => _fcmToken = token);
      },
    );

    _initializePushNotifications();
    _checkInitialMessage();
  }

  Future<void> _initializePushNotifications() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await FirebaseMessaging.instance.getToken();
      if (!mounted) return;

      setState(() {
        _fcmToken = token;
        _permissionStatus = _permissionLabel(settings.authorizationStatus);
        _isLoadingPush = false;
        _connectionError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingPush = false;
        _permissionStatus = 'Não foi possível verificar';
        _connectionError = error.toString();
      });
    }
  }

  String _permissionLabel(AuthorizationStatus status) {
  switch (status) {
    case AuthorizationStatus.authorized:
      return 'Permissão concedida';

    case AuthorizationStatus.provisional:
      return 'Permissão provisória';

    case AuthorizationStatus.denied:
      return 'Permissão negada';

    case AuthorizationStatus.deniedPermanently:
      return 'Permissão negada permanentemente';

    case AuthorizationStatus.notDetermined:
      return 'Permissão não definida';
  }
}

  Future<void> _checkInitialMessage() async {
    try {
      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    } catch (error) {
      debugPrint('Erro ao recuperar notificação inicial: $error');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final context = appNavigatorKey.currentContext;
    if (context == null) return;

    final subjectId = message.data['subjectId']?.toString();
    final subject = StudySubject.findById(subjectId);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            '${notification.title ?? 'Nova notificação'}: '
            '${notification.body ?? 'Você recebeu uma atualização.'}',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          action: subject == null
              ? null
              : SnackBarAction(
                  label: 'ABRIR',
                  onPressed: () => _openSubject(subject),
                ),
        ),
      );
  }

  void _handleNotificationTap(RemoteMessage message) {
    final subjectId = message.data['subjectId']?.toString();
    final subject = StudySubject.findById(subjectId);

    // A chave subjectId identifica qual tela de detalhes deve ser aberta.
    if (subject == null) {
      debugPrint('Notificação recebida sem subjectId válido: ${message.data}');
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openSubject(subject);
    });
  }

  void _openSubject(StudySubject subject) {
    final navigator = appNavigatorKey.currentState;
    if (navigator == null) return;

    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => SubjectDetailPage(subject: subject),
      ),
    );
  }

  Future<void> _copyToken() async {
    final token = _fcmToken;
    if (token == null || token.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: token));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Token FCM copiado.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _foregroundSubscription?.cancel();
    _openedSubscription?.cancel();
    _tokenSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            _buildHeader(),
            const SizedBox(height: 22),
            _buildHeroCard(),
            const SizedBox(height: 24),
            _buildSectionHeading(
              title: 'Sua rotina',
              subtitle: 'Escolha uma matéria para continuar.',
              trailing: '05 matérias',
            ),
            const SizedBox(height: 12),
            ...studySubjects.map(_buildSubjectCard),
            const SizedBox(height: 12),
            _buildNotificationStatusCard(),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'ESTUDOS PUSH  •  LEMBRETES DE ESTUDO',
                style: TextStyle(
                  color: Color(0xFF9AA4B5),
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: _primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.auto_stories_rounded, color: _primary),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ESTUDOS PUSH',
                style: TextStyle(
                  color: _ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Organize seu próximo estudo',
                style: TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE9EDF5)),
          ),
          child: const Icon(Icons.notifications_none_rounded, color: _ink),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF273D9B), Color(0xFF5369E6)],
        ),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.20),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'PLANEJAMENTO DE ESTUDOS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            'Pequenos passos.\nProgresso consistente.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              height: 1.18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Acompanhe suas matérias e receba lembretes nos momentos certos.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Icons.menu_book_rounded,
                  color: Colors.white, size: 17),
              const SizedBox(width: 7),
              const Text(
                '5 matérias disponíveis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 18),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading({
    required String title,
    required String subtitle,
    String? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: const TextStyle(
              color: _primary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }

  Widget _buildSubjectCard(StudySubject subject) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openSubject(subject),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: subject.color.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(subject.icon, color: subject.color, size: 24),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.shortTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subject.category,
                        style: const TextStyle(color: _muted, fontSize: 11),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded,
                              color: _muted, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            subject.duration,
                            style:
                                const TextStyle(color: _muted, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF9AA4B5), size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationStatusCard() {
    final hasToken = _fcmToken != null && _fcmToken!.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F6EF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_active_rounded,
                      color: Color(0xFF238653), size: 20),
                ),
                const SizedBox(width: 11),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notificações push',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Firebase Cloud Messaging',
                        style: TextStyle(color: _muted, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                if (_isLoadingPush)
                  const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    hasToken ? Icons.check_circle_rounded : Icons.info_rounded,
                    color: hasToken ? const Color(0xFF238653) : Colors.orange,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 13),
            Text(
              _permissionStatus,
              style: const TextStyle(
                color: _ink,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (_connectionError != null) ...[
              const SizedBox(height: 6),
              Text(
                _connectionError!,
                style: const TextStyle(color: Colors.red, fontSize: 10),
              ),
            ],
            if (hasToken) ...[
              const SizedBox(height: 8),
              Text(
                'Token do dispositivo: ${_fcmToken!.substring(0, _fcmToken!.length > 24 ? 24 : _fcmToken!.length)}…',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _copyToken,
                  icon: const Icon(Icons.copy_rounded, size: 15),
                  label: const Text('Copiar token FCM'),
                ),
              ),
            ] else if (!_isLoadingPush) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _initializePushNotifications,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SubjectDetailPage extends StatelessWidget {
  const SubjectDetailPage({super.key, required this.subject});

  final StudySubject subject;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalhes da matéria',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: subject.color.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 58,
                  width: 58,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(subject.icon, color: subject.color, size: 30),
                ),
                const SizedBox(height: 18),
                Text(
                  subject.category.toUpperCase(),
                  style: TextStyle(
                    color: subject.color,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  subject.title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 24,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subject.description,
                  style: const TextStyle(
                    color: Color(0xFF5F6B80),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        color: _muted, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Tempo sugerido: ${subject.duration}',
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Conteúdo para revisar',
            style: TextStyle(
              color: _ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...subject.topics.asMap().entries.map((entry) {
            final number = entry.key + 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: subject.color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '$number',
                            style: TextStyle(
                              color: subject.color,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.flag_rounded, color: _primary, size: 20),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Objetivo da sessão',
                        style: TextStyle(
                          color: _primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subject.goal,
                        style: const TextStyle(
                          color: Color(0xFF4F5F91),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
