from PIL import Image

def remove_background_floodfill(input_path, output_path, tolerance=30):
    img = Image.open(input_path)
    img = img.convert("RGBA")
    width, height = img.size
    pixels = img.load()

    # Starting point (top-left corner)
    start_pos = (0, 0)
    start_color = pixels[0, 0]

    # Queue for BFS: stores (x, y)
    queue = [start_pos]
    visited = set([start_pos])
    
    # helper to check if color is close to white/background color
    def is_similar(c1, c2, tol):
        return abs(c1[0] - c2[0]) < tol and \
               abs(c1[1] - c2[1]) < tol and \
               abs(c1[2] - c2[2]) < tol

    # Directions for neighbors (4-way)
    directions = [(0, 1), (0, -1), (1, 0), (-1, 0)]

    processed_count = 0
    
    while queue:
        x, y = queue.pop(0)
        
        # Make the current pixel transparent
        pixels[x, y] = (255, 255, 255, 0)
        processed_count += 1
        
        for dx, dy in directions:
            nx, ny = x + dx, y + dy
            
            if 0 <= nx < width and 0 <= ny < height:
                if (nx, ny) not in visited:
                    neighbor_color = pixels[nx, ny]
                    # Check if neighbor is similar to the START color (usually white)
                    # AND is similar to the current pixel (to ensure continuity) determines if we keep flooding.
                    # Usually checking against a target 'white' reference is safer to avoid bleeding into the subject if it has slow gradients.
                    # Given it's a flat icon on white, checking against start_color is good.
                    if is_similar(neighbor_color, start_color, tolerance):
                        visited.add((nx, ny))
                        queue.append((nx, ny))

    img.save(output_path, "PNG")
    print(f"Processed {processed_count} pixels. Saved to {output_path}")

if __name__ == "__main__":
    remove_background_floodfill("assets/icon.png", "assets/icon.png")
