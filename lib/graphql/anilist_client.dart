import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:octolist/services/auth_service.dart';

class AniListClient {
  static final HttpLink _httpLink = HttpLink('https://graphql.anilist.co');
  static final AuthService _authService = AuthService();

  static ValueNotifier<GraphQLClient> initClient() {
    
    final authLink = AuthLink(getToken: () async {
      final token = await _authService.getToken();
      return token == null ? null : 'Bearer $token';
    });
    
    final Link link = authLink.concat(_httpLink);
    
    return ValueNotifier(
      GraphQLClient(
        link: link,
        // The default store is the InMemoryStore, which does hold to local storage
        cache: GraphQLCache(store: InMemoryStore()),
      ),
    );
  }
}
