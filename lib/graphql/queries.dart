class AnimeQueries {
  static const String getTrendingAnime = """
    query GetTrendingAnimeAndSearch {
      trending: Page(page: 1, perPage: 10) {
        media(sort: TRENDING_DESC, type: ANIME) {
          id
          title {
            english
            romaji
          }
          coverImage {
            large
          }
          description
        }
      }
    }
  """;
}
