import requests
import json
import os
import time
import argparse

# Create a directory for mocks if it doesn't exist
output_dir = "mock_data"
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

url = 'https://graphql.anilist.co'

# --- FRAGMENTS ---
media_short_fragment = '''
fragment MediaShort on Media {
  id
  title {
    userPreferred
    english
  }
  coverImage {
    extraLarge
    large
    color
  }
  type
  format
  status(version: 2)
  averageScore
  episodes
  isAdult
}
'''

# --- QUERIES ---

query_home = f'''
query GetHomeData {{
  trending: Page(page: 1, perPage: 10) {{
    media(sort: TRENDING_DESC, type: ANIME) {{
      ...MediaShort
    }}
  }}
}}
{media_short_fragment}
'''

query_details = f'''
query GetMediaDetails($id: Int) {{
  Media(id: $id) {{
    ...MediaShort
    bannerImage
    description
    startDate {{
      year
      month
      day
    }}
    season
    seasonYear
    studios(isMain: true) {{
      nodes {{
        name
      }}
    }}
    relations {{
      edges {{
        relationType
        node {{
          ...MediaShort
        }}
      }}
    }}
    recommendations(perPage: 7, sort: RATING_DESC) {{
      nodes {{
        mediaRecommendation {{
          ...MediaShort
        }}
      }}
    }}
  }}
}}
{media_short_fragment}
'''

query_search = f'''
query SearchAnime($search: String, $genre: String, $year: Int, $season: MediaSeason) {{
  Page(page: 1, perPage: 10) {{
    media(search: $search, genre: $genre, seasonYear: $year, season: $season, type: ANIME, sort: POPULARITY_DESC) {{
      ...MediaShort
    }}
  }}
}}
{media_short_fragment}
'''

# Redundant queries (GetUserLibrary, GetUserProfile) removed in favor of consolidated GetViewerData

query_viewer = f'''
query GetViewerData($name: String) {{
  Viewer: User(name: $name) {{
    id
    name
    avatar {{
      large
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
          ...MediaShort
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
        media {{
          ...MediaShort
        }}
      }}
    }}
  }}
}}
{media_short_fragment}
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
