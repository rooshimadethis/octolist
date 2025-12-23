import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/queries.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OctoList - Trending')),
      body: Query(
        options: QueryOptions(document: gql(AnimeQueries.getTrendingAnime)),
        builder:
            (
              QueryResult result, {
              VoidCallback? refetch,
              FetchMore? fetchMore,
            }) {
              if (result.hasException) {
                return Center(child: Text(result.exception.toString()));
              }

              if (result.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final List repositories = result.data?['trending']['media'] ?? [];

              return ListView.builder(
                itemCount: repositories.length,
                itemBuilder: (context, index) {
                  final anime = repositories[index];
                  final title =
                      anime['title']['english'] ?? anime['title']['romaji'];
                  final coverImage = anime['coverImage']['large'];
                  final description =
                      anime['description']?.replaceAll(
                        RegExp(r'<[^>]*>'),
                        '',
                      ) ??
                      'No description'; // Simple regex to remove HTML tags

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: Image.network(
                        coverImage,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              );
            },
      ),
    );
  }
}
