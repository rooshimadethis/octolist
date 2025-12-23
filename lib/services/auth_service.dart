import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'anilist_token';
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  final ValueNotifier<bool> isLoggedIn = ValueNotifier(false);

  /// Initializes listeners for deep links and checks auth state
  Future<void> init() async {
    // Check initial auth state
    final token = await getToken();
    isLoggedIn.value = token != null;
    debugPrint('AuthService: Initial auth state: ${isLoggedIn.value}');

    if (_linkSubscription != null) return;

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
    debugPrint('AuthService: Deep link listener initialized');
  }

  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    isLoggedIn.dispose();
  }

  Future<void> login() async {
    debugPrint('AuthService: Attempting login...');
    final clientId = dotenv.env['ANILIST_CLIENT_ID'];
    if (clientId == null || clientId.isEmpty) {
      debugPrint('Error: ANILIST_CLIENT_ID not found in .env');
      debugPrint('Available keys: ${dotenv.env.keys.toList()}'); // Debug help
      throw Exception('ANILIST_CLIENT_ID missing from .env');
    }

    final url = Uri.parse(
      'https://anilist.co/api/v2/oauth/authorize?client_id=$clientId&response_type=token',
    );

    debugPrint('AuthService: Launching URL: $url');

    // Check if we can launch. On some platforms, canLaunchUrl might return false
    // even if launchUrl would succeed, but it's good practice.
    // Use externalApplication to ensure it opens in a browser that can redirect back.
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Error: Could not launch $url');
      throw Exception('Could not launch auth URL');
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    debugPrint('AuthService: Received deep link: $uri');
    // AniList returns token in the fragment: #access_token=...&...

    String? token;

    // Check fragment first
    if (uri.fragment.contains('access_token')) {
      final params = Uri.splitQueryString(uri.fragment);
      token = params['access_token'];
    }

    // If not in fragment, check query parameters just in case
    if (token == null && uri.queryParameters.containsKey('access_token')) {
      token = uri.queryParameters['access_token'];
    }

    if (token != null) {
      await saveToken(token);
      debugPrint('AniList Token captured and saved!');
    }
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    isLoggedIn.value = true;
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    isLoggedIn.value = false;
  }
}
