import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'services/auth_service.dart';
import 'services/anime_store.dart';
import 'services/mock_data_service.dart';
import 'services/anilist_service.dart';
import 'screens/expressive_home_screen.dart';
import 'graphql/anilist_client.dart';

// SET THIS TO TRUE TO USE MOCK DATA
const bool useMocks = true;

void main() async {
  // We need to initialize Hive for graphql_flutter's cache
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();

  // Pre-cache Google Fonts to prevent stuttering on first load
  await _preCacheFonts();

  // Configure VisibilityDetector to check more frequently (default is 500ms)
  // Lower value = more frequent checks = smoother animations but slightly more CPU usage
  VisibilityDetectorController.instance.updateInterval = const Duration(
    milliseconds: 50,
  );

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

  // Initialize AnimeStore
  final animeStore = AnimeStore(
    service: useMocks ? MockDataService() : AniListService(),
  );
  await animeStore.initVibe();

  // Initialize GraphQL Client
  final client = AniListClient.initClient();

  runApp(
    ChangeNotifierProvider.value(
      value: animeStore,
      child: GraphQLProvider(client: client, child: const ExpressiveApp()),
    ),
  );
}

/// Pre-cache all Google Fonts used in the app to prevent loading jank
Future<void> _preCacheFonts() async {
  try {
    await GoogleFonts.pendingFonts([
      GoogleFonts.teko(),
      GoogleFonts.robotoMono(),
      GoogleFonts.bangers(),
      GoogleFonts.roboto(),
    ]);
  } catch (e) {
    debugPrint("Error pre-caching fonts: $e");
  }
}
