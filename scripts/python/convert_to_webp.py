import sys
import os
from PIL import Image

def convert_to_webp(input_path, quality=80):
    try:
        # Open the image file
        image = Image.open(input_path)

        # Create the output path with the same name but a different extension
        output_path = os.path.splitext(input_path)[0] + ".webp"

        # Convert and save as WebP
        image.save(output_path, 'WEBP', quality=quality)
        print(f"Conversion successful: {input_path} -> {output_path}")
    except Exception as e:
        print(f"Error converting {input_path} to WebP: {str(e)}")

if __name__ == "__main__":
    # Check if correct number of command-line arguments are provided
    if len(sys.argv) != 3:
        print("ERROR. Not enough variables passed. \npython script.py(convert_to_webp.py) input_image_path(test_img.png) quality(0-100)")
        sys.exit(1)

    input_image_path = sys.argv[1]

    try:
        quality = int(sys.argv[2])
    except ValueError:
        print("Quality must be an integer between 0 and 100.")
        sys.exit(1)

    if not (0 <= quality <= 100):
        print("Quality must be an integer between 0 and 100.")
        sys.exit(1)

    convert_to_webp(input_image_path, quality)