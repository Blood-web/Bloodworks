
import pyqrcode
from PIL import Image
import argparse
import sys

def create_qr_with_logo(url, logo_path, output_path):
    # Generate the QR code and save as png
    qrobj = pyqrcode.create(url)
    with open('temp_qr.png', 'wb') as f:
        qrobj.png(f, scale=10)

    # Now open the generated QR code image to put the logo
    img = Image.open('temp_qr.png')
    width, height = img.size

    # Define the size of the logo to put in the QR code
    logo_size = int(min(width, height) * 0.3)  # 0.3 === 30% of the QR code size (Max 30%)

    # Open the logo image
    logo = Image.open(logo_path)

    # Calculate xmin, ymin, xmax, ymax to place the logo
    xmin = ymin = int((width / 2) - (logo_size / 2))
    xmax = ymax = int((width / 2) + (logo_size / 2))

    # Resize the logo as calculated
    logo = logo.resize((xmax - xmin, ymax - ymin))

    # Put the logo in the QR code
    img.paste(logo, (xmin, ymin, xmax, ymax))

    # Save the final image
    img.save(output_path)
    img.show()

def main():
    parser = argparse.ArgumentParser(description='Generate a QR code with an embedded logo.')
    parser.add_argument('url', help='The URL to encode in the QR code.')
    parser.add_argument('logo_path', help='The path to the logo image to embed in the QR code.')
    parser.add_argument('output_path', help='The path to save the final QR code image.', default='qr_with_logo.png', nargs='?')
    
    args = parser.parse_args()

    if not args.url or not args.logo_path:
        print("Error: You must provide both a URL and a path to the logo image.")
        print("Usage: python3 script.py <url> <logo_path> [<output_path>]")
        sys.exit(1)

    create_qr_with_logo(args.url, args.logo_path, args.output_path)

if __name__ == "__main__":
    main()




#import pyqrcode
#from PIL import Image

# Generate the qr code and save as png
#qrobj = pyqrcode.create('http://www.jackewers.com/projects/poo_snake/')
#with open('qr_with_image_output.png', 'wb') as f:
#    qrobj.png(f, scale=10)

# Now open that png image to put the logo
#img = Image.open('qr_with_image_output.png')
#width, height = img.size

# How big the logo we want to put in the qr code png
#logo_size = 100

# Open the logo image
#logo = Image.open('Kaitlyn.png')

# Calculate xmin, ymin, xmax, ymax to put the logo
#xmin = ymin = int((width / 2) - (logo_size / 2))
#xmax = ymax = int((width / 2) + (logo_size / 2))

# resize the logo as calculated
#logo = logo.resize((xmax - xmin, ymax - ymin))

# put the logo in the qr code
#img.paste(logo, (xmin, ymin, xmax, ymax))

#img.show()
