

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthService {
    static const _storage = FlutterSecureStorage();
    static const _tokenKey = 'anilist_token';

    Future<void> login() async {
        final clientId = dotenv.env['ANILIST_CLIENT_ID'];
        final url = Uri.parse('https://anilist.co/api/v2/oauth/authorize?client_id=$clientId&response_type=token');
        if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.inAppWebView);
        }
    }

    Future<void> saveToken(String token) async {
        await _storage.write(key: _tokenKey, value: token);
    }

    Future<String?> getToken() async {
        final token = await _storage.read(key: _tokenKey);
        return token;
    }

    Future<void> logout() async {
        await _storage.delete(key: _tokenKey);
    }
}