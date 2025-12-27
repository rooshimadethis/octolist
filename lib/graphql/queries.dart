class AnimeQueries {
  static const String mediaFragment = r"""
    fragment MediaFragment on Media {
      id
      idMal
      title {
        english
        romaji
        native
      }
      coverImage {
        extraLarge
        large
        medium
        color
      }
      bannerImage
      averageScore
      episodes
      genres
      description
      season
      seasonYear
      status
      isAdult
    }
  """;

  static const String getTrendingAnime =
      r"""
    query GetTrendingAnime($page: Int = 1, $perPage: Int = 10) {
      trending: Page(page: $page, perPage: $perPage) {
        media(sort: TRENDING_DESC, type: ANIME) {
          ...MediaFragment
        }
      }
    }
  """ +
      mediaFragment;

  static const String searchAnime =
      r"""
    query SearchAnime($query: String, $page: Int = 1, $perPage: Int = 20) {
      Page(page: $page, perPage: $perPage) {
        media(search: $query, type: ANIME, sort: SEARCH_MATCH) {
          ...MediaFragment
        }
      }
    }
  """ +
      mediaFragment;

  static const String getAnimeDetails =
      r"""
    query GetAnimeDetails($id: Int) {
      Media(id: $id) {
        ...MediaFragment
        characters(sort: ROLE, perPage: 10) {
          edges {
            role
            node {
              id
              name {
                full
              }
              image {
                large
                medium
              }
            }
          }
        }
        studios(isMain: true) {
          nodes {
            id
            name
          }
        }
        recommendations(sort: RATING_DESC, perPage: 7) {
          nodes {
            mediaRecommendation {
               ...MediaFragment
            }
          }
        }
        relations {
          edges {
            relationType
            node {
              ...MediaFragment
            }
          }
        }
      }
    }
  """ +
      mediaFragment;

  static const String getViewer = r"""
    query GetViewer {
      Viewer {
        id
        name
        avatar {
          large
          medium
        }
        statistics {
          anime {
            count
            minutesWatched
            episodesWatched
          }
        }
      }
    }
  """;

  static const String getMediaList =
      r"""
    query GetMediaList($userId: Int, $status: MediaListStatus) {
      MediaListCollection(userId: $userId, type: ANIME, status: $status) {
        lists {
          name
          entries {
            id
            progress
            score
            updatedAt
            media {
              ...MediaFragment
            }
          }
        }
      }
    }
  """ +
      mediaFragment;

  static const String saveMediaListEntry = r"""
    mutation SaveMediaListEntry($mediaId: Int, $status: MediaListStatus, $progress: Int, $score: Float) {
      SaveMediaListEntry(mediaId: $mediaId, status: $status, progress: $progress, score: $score) {
        id
        status
        progress
        score
      }
    }
  """;

  static const String getGlobalTextActivities = r"""
    query GetGlobalTextActivities($page: Int = 1, $perPage: Int = 20) {
      Page(page: $page, perPage: $perPage) {
        pageInfo {
          total
          currentPage
          lastPage
          hasNextPage
          perPage
        }
        activities(type: TEXT, sort: ID_DESC) {
          ... on TextActivity {
            id
            userId
            type
            text(asHtml: true)
            createdAt
            replyCount
            likeCount
            isLiked
            siteUrl
            user {
              id
              name
              avatar {
                large
                medium
              }
            }
            likes {
              id
              name
              avatar {
                large
                medium
              }
            }
          }
        }
      }
    }
  """;

  static const String getActivityDetails = r"""
    query GetActivityDetails($id: Int) {
      Activity(id: $id) {
        ... on TextActivity {
          id
          userId
          type
          text(asHtml: true)
          createdAt
          replyCount
          likeCount
          isLiked
          siteUrl
          user {
            id
            name
            avatar {
              large
              medium
            }
          }
          likes {
            id
            name
            avatar {
              large
              medium
            }
          }
          replies {
            ... on ActivityReply {
              id
              text(asHtml: true)
              likeCount
              isLiked
              createdAt
              user {
                id
                name
                avatar {
                  large
                }
              }
              likes {
                id
                name
                avatar {
                  large
                  medium
                }
              }
            }
          }
        }
      }
    }
  """;

  static const String toggleLike = r"""
    mutation ToggleLike($id: Int, $type: LikeableType) {
      ToggleLikeV2(id: $id, type: $type) {
        ... on TextActivity {
          id
          likeCount
          isLiked
        }
        ... on ActivityReply {
          id
          likeCount
          isLiked
        }
      }
    }
  """;

  static const String saveActivityReply = r"""
    mutation SaveActivityReply($activityId: Int, $text: String) {
      SaveActivityReply(activityId: $activityId, text: $text) {
        id
        text(asHtml: true)
        likeCount
        isLiked
        createdAt
        user {
          id
          name
          avatar {
            large
            medium
          }
        }
      }
    }
  """;
}
