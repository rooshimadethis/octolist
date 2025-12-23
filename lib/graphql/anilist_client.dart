// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:octolist/services/auth_service.dart';

import 'dart:async';

class AniListClient {
  static final HttpLink _httpLink = HttpLink('https://graphql.anilist.co');
  static final AuthService _authService = AuthService();

  static ValueNotifier<GraphQLClient> initClient() {
    // Initialize auth listener
    _authService.init();

    final authLink = AuthLink(
      getToken: () async {
        final token = await _authService.getToken();
        return token == null ? null : 'Bearer $token';
      },
    );

    // Add LoggingLink to the chain
    final Link link = authLink.concat(LoggingLink()).concat(_httpLink);

    return ValueNotifier(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(store: HiveStore()),
      ),
    );
  }
}

class LoggingLink extends Link {
  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    final operation = request.operation;

    Stream<Response> responseStream = forward!(request);

    return responseStream.map((Response response) {
      final httpContext = response.context.entry<HttpLinkResponseContext>();
      final headers = httpContext?.headers;
      final remaining =
          headers?['x-ratelimit-remaining'] ??
          headers?['X-RateLimit-Remaining'] ??
          'Unknown';

      if (response.errors != null && response.errors!.isNotEmpty) {
        final errorMessages = response.errors!.map((e) => e.message).join(', ');
        print('[GraphQL] ❌ Failed: ${operation.operationName}');
        print('  Error: $errorMessages');
        print('  Calls Left: $remaining');
      } else {
        print(
          '[GraphQL] ✅ Success: ${operation.operationName} | Calls Left: $remaining',
        );
      }

      return response;
    });
  }
}
