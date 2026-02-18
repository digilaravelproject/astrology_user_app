import os
from PIL import Image

def remove_white_background(image_path):
    img = Image.open(image_path).convert("RGBA")
    datas = img.getdata()

    new_data = []
    for item in datas:
        # If pixel is very close to white, make it transparent
        if item[0] > 240 and item[1] > 240 and item[2] > 240:
            new_data.append((255, 255, 255, 0))
        else:
            new_data.append(item)

    img.putdata(new_data)
    img.save(image_path, "PNG")

directory = "/Users/firozmohammad/Astrology/astro_user/assets/images/services"
for filename in os.listdir(directory):
    if filename.endswith(".png"):
        path = os.path.join(directory, filename)
        print(f"Processing {path}...")
        remove_white_background(path)
print("Done!")
