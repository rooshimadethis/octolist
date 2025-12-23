import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/auth_service.dart';
import 'services/anime_store.dart';
import 'screens/expressive_home_screen.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:provider/provider.dart';

void main() async {
  // We need to initialize Hive for graphql_flutter's cache
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();

  try {
    await FlutterDisplayMode.setHighRefreshRate();
  } catch (e) {
    debugPrint("Error setting high refresh rate: $e");
  }

  try {
    await dotenv.load(fileName: ".env");
    debugPrint("Dotenv loaded. Keys: ${dotenv.env.keys.toList()}");
  } catch (e) {
    debugPrint("Error loading .env: $e");
  }

  // Initialize AuthService
  await AuthService().init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AnimeStore(),
      child: const ExpressiveApp(),
    ),
  );
}

/*
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<GraphQLClient> client = AniListClient.initClient();

    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        title: 'OctoList',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
*/
