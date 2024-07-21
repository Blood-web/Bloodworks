import argparse
from PIL import Image
import os

def convert_to_jpeg(input_image_path):
    # Open the input image
    image = Image.open(input_image_path)

    # Check if the image has transparency and is in palette mode
    if image.mode == 'P' and 'transparency' in image.info:
        # Convert the image to RGBA mode to preserve transparency
        image = image.convert('RGBA')

    # Get the original image name without extension
    original_name, original_ext = os.path.splitext(input_image_path)

    # Convert the image to RGB mode (if it's not already in RGB mode)
    rgb_image = image.convert('RGB')

    # Save the image as JPEG with quality set to 95
    output_path = f"{original_name}.jpeg"
    rgb_image.save(output_path, quality=55)

    # Close the images
    image.close()
    rgb_image.close()

    return output_path

def main():
    # Create argument parser
    parser = argparse.ArgumentParser(description='Convert an image to JPEG format')
    parser.add_argument('input_image', type=str, help='Path to the input image file')

    # Parse the command-line arguments
    args = parser.parse_args()

    # Convert the input image to JPEG
    output_image_path = convert_to_jpeg(args.input_image)
    print(f"Image converted to JPEG: {output_image_path}")

if __name__ == "__main__":
    main()
