import requests
import json
import os
import time
import argparse

# Create a directory for mocks if it doesn't exist
output_dir = "assets/anilist_data"
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

url = 'https://graphql.anilist.co'

# --- FRAGMENTS ---
# Matching lib/graphql/queries.dart:MediaFragment
media_fragment = '''
fragment MediaFragment on Media {
  id
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
}
'''

# --- QUERIES ---

# Matching lib/graphql/queries.dart:getTrendingAnime
query_home = f'''
query GetTrendingAnime($page: Int = 1, $perPage: Int = 10) {{
  trending: Page(page: $page, perPage: $perPage) {{
    media(sort: TRENDING_DESC, type: ANIME) {{
      ...MediaFragment
    }}
  }}
}}
{media_fragment}
'''

# Matching lib/graphql/queries.dart:getAnimeDetails
query_details = f'''
query GetAnimeDetails($id: Int) {{
  Media(id: $id) {{
    ...MediaFragment
    characters(sort: ROLE, perPage: 10) {{
      edges {{
        role
        node {{
          id
          name {{
            full
          }}
          image {{
            large
            medium
          }}
        }}
      }}
    }}
    studios(isMain: true) {{
      nodes {{
        id
        name
      }}
    }}
    recommendations(sort: RATING_DESC, perPage: 7) {{
      nodes {{
        mediaRecommendation {{
           ...MediaFragment
        }}
      }}
    }}
    relations {{
      edges {{
        relationType
        node {{
          ...MediaFragment
        }}
      }}
    }}
  }}
}}
{media_fragment}
'''

# Matching lib/graphql/queries.dart:searchAnime
query_search = f'''
query SearchAnime($query: String, $page: Int = 1, $perPage: Int = 10) {{
  Page(page: $page, perPage: $perPage) {{
    media(search: $query, type: ANIME, sort: SEARCH_MATCH) {{
      ...MediaFragment
    }}
  }}
}}
{media_fragment}
'''

# Matching lib/graphql/queries.dart:getViewer and getMediaList
# Note: Combining them as fetch_mocks.py does
query_viewer = f'''
query GetViewerData($name: String) {{
  Viewer: User(name: $name) {{
    id
    name
    avatar {{
      large
      medium
    }}
    statistics {{
      anime {{
        count
        minutesWatched
        episodesWatched
        meanScore
        statuses {{
          count
          status
        }}
      }}
    }}
    favourites {{
      anime {{
        nodes {{
          ...MediaFragment
        }}
      }}
      characters {{
        nodes {{
          name {{
            full
          }}
          image {{
            large
          }}
        }}
      }}
    }}
    mediaListOptions {{
      scoreFormat
      rowOrder
      animeList {{
        sectionOrder
        customLists
      }}
      mangaList {{
        sectionOrder
        customLists
      }}
    }}
  }}
  MediaListCollection(userName: $name, type: ANIME) {{
    lists {{
      name
      entries {{
        id
        status
        score
        progress
        updatedAt
        media {{
          ...MediaFragment
        }}
      }}
    }}
  }}
}}
{media_fragment}
'''

def fetch_and_save(name, query, variables=None):
    print(f"Fetching {name}...")
    response = requests.post(url, json={'query': query, 'variables': variables})
    
    if response.status_code == 200:
        data = response.json()
        filename = f"{output_dir}/{name}.json"
        with open(filename, 'w') as f:
            json.dump(data, f, indent=2)
        print(f"  -> Saved to {filename}")
        
        remaining = response.headers.get('X-RateLimit-Remaining')
        if remaining:
            print(f"  -> API Requests Remaining: {remaining}")
    else:
        print(f"  -> FAILED: {response.status_code}")
        print(response.text)
    
    time.sleep(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Fetch mock data from AniList.")
    parser.add_argument('queries', nargs='*', default=['all'], help='List of queries to run (home, details, search, library, profile, all)')
    args = parser.parse_args()

    active_queries = args.queries
    
    if 'all' in active_queries:
        active_queries = ['home', 'details', 'search', 'viewer']

    print(f"--- Running queries: {active_queries} ---")

    if 'home' in active_queries:
        fetch_and_save("home_data", query_home)
        
    if 'details' in active_queries:
        fetch_and_save("media_details_naruto", query_details, {'id': 20}) 
        fetch_and_save("media_details_naruto_shippuden", query_details, {'id': 1735})   
        
    if 'search' in active_queries:
        fetch_and_save("search_results_naruto", query_search, {'search': "Naruto"})
        fetch_and_save("search_results_2023_winter", query_search, {'year': 2023, 'season': 'WINTER'})

    if 'viewer' in active_queries:
        fetch_and_save("viewer_data", query_viewer, {'name': "VoltAndVeg"})

    print("--- Done! ---")
