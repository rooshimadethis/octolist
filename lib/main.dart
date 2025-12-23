import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'screens/expressive_home_screen.dart';

void main() async {
  // We need to initialize Hive for graphql_flutter's cache
  await initHiveForFlutter();

  runApp(const ExpressiveApp());
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
