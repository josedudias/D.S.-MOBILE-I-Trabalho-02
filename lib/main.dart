import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gamehub/services/game_api_service.dart';
import 'package:gamehub/repositories/game_repository.dart';
import 'package:gamehub/repositories/game_repository_impl.dart';
import 'package:gamehub/viewmodels/home_view_model.dart';
import 'package:gamehub/views/game_hub_home.dart';
import 'package:gamehub/views/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:gamehub/services/auth_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar o Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final gameApiService = GameApiService();

  runApp(
    MultiProvider(
      providers: [
        Provider<GameApiService>(create: (_) => gameApiService),
        Provider<GameRepository>(
          create: (context) => GameRepositoryImpl(context.read<GameApiService>()),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create:
              (context) =>
                  HomeViewModel(context.read<GameRepository>())..init(),
        ),
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: const GameHubApp(),
    ),
  );
}

class GameHubApp extends StatelessWidget {
  const GameHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return MaterialApp(
      title: 'GameHub - Por José Eduardo Dias Rufino',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: StreamBuilder<User?>(
        stream: authService.userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            if (user == null) {
              return const LoginScreen();
            }
            return const GameHubHome(title: 'GameHub - Sua Central de Jogos');
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
