#!/usr/bin/env python3

from PIL import Image, ImageDraw, ImageFont
import sys, os


# Define paths to the image and font
image_path = "/home/bloodweb-lp/c/lib/img/logo.png"  # Update this path
font_path = "/home/bloodweb-lp/fonts/DejaVuSans-Bold.ttf"  # Update if necessary


# Example usage
def add_watermark(image_path, watermark_text, opacity, x=None, y=None):
    font_path = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.tt"
    
    # Open the original image
    original_image = Image.open(image_path).convert("RGBA")
    
    # Make a blank image for the watermark with the same size as the original image
    txt = Image.new('RGBA', original_image.size, (255,255,255,0))
    
    # Choose a font and size for the watermark
    font = ImageFont.truetype(font_path, 36)
    
    # Initialize ImageDraw
    d = ImageDraw.Draw(txt)

    # Calculate text size
    text_width, text_height = d.textsize(watermark_text, font=font)
    
    # If x and y are not specified, default to bottom right position
    if x is None and y is None:
        margin = 10  # Margin from the edges
        x = original_image.width - text_width - margin
        y = original_image.height - text_height - margin
    
    # Add text to the watermark image
    d.text((x, y), watermark_text, fill=(255,255,255,opacity), font=font)
    
    # Combine the original image with the watermark
    watermarked = Image.alpha_composite(original_image, txt)
    
    # Extract the directory and filename from the image_path
    dir_name = os.path.dirname(image_path)
    filename = os.path.basename(image_path)
    
    # Create a new filename for the watermarked image
    new_filename = "watermarked_" + filename
    
    # Construct the full path for the new file to save it in the same directory as the original
    new_file_path = os.path.join(dir_name, new_filename)
    
    # Save the image in a format that supports transparency (e.g., PNG)
    watermarked.save(new_file_path, "PNG")
    print(f"Watermarked image saved as:\n {new_file_path}")

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python script.py <filename> <'keywords'> <opacity> [<x> <y>]")
        sys.exit(1)
    
    filename = sys.argv[1]
    keywords = sys.argv[2]
    opacity = int(sys.argv[3])
    
    # Check if x and y positions are provided
    if len(sys.argv) >= 6:
        x = int(sys.argv[4])
        y = int(sys.argv[5])
        add_watermark(filename, keywords, opacity, x, y)
    else:
        add_watermark(filename, keywords, opacity)