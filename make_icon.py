from PIL import Image, ImageDraw
import os
os.makedirs('assets/icon', exist_ok=True)
size = 1024
img = Image.new('RGBA', (size, size), (255, 255, 255, 0))
d = ImageDraw.Draw(img)
# background circle
d.ellipse((0, 0, size, size), fill=(39, 174, 96, 255))
# pepper body
d.polygon([(320, 420), (700, 380), (760, 520), (470, 740), (300, 640)], fill=(255, 255, 255, 255))
# stem
d.polygon([(450, 220), (560, 190), (600, 110), (520, 120), (420, 190)], fill=(255, 255, 255, 255))
# highlight
d.polygon([(420, 420), (520, 360), (640, 380), (580, 520), (490, 540)], fill=(255, 255, 182, 180))
img.save('assets/icon/app_icon.png')
print('Created assets/icon/app_icon.png')
