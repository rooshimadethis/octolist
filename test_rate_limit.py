import requests
import time

url = "https://graphql.anilist.co"
query = """
query {
  Media(id: 1) {
    id
    title {
      romaji
    }
  }
}
"""

print("Starting Rate Limit Test...")
print("Sending 5 requests to check headers...")

for i in range(1, 6):
    try:
        response = requests.post(url, json={'query': query})
        
        print(f"\nRequest {i}: Status {response.status_code}")
        
        limit = response.headers.get('X-RateLimit-Limit')
        remaining = response.headers.get('X-RateLimit-Remaining')
        reset = response.headers.get('X-RateLimit-Reset')
        
        print(f"  X-RateLimit-Limit: {limit}")
        print(f"  X-RateLimit-Remaining: {remaining}")
        
        if response.status_code == 429:
            print("  !! HIT RATE LIMIT !!")
            retry_after = response.headers.get('Retry-After')
            print(f"  Retry-After: {retry_after}")
            break
            
        time.sleep(1) # Be polite, just checking headers
        
    except Exception as e:
        print(f"Error: {e}")
        break
