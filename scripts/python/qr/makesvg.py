import qrcode
import qrcode.image.svg

img = qrcode.make('http://192.168.1.107/Projects/household-chore-list.php', image_factory=qrcode.image.svg.SvgImage)

with open('qr.svg', 'wb') as qr:
    img.save(qr)
