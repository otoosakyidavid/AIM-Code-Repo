from PIL import Image
import pytesseract

pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'

path = 'C:/Users/91884/PycharmProjects/Optical Character Recognition/quote.jpg'
img = Image.open(path)
text = pytesseract.image_to_string(img,lang='eng')
#print(text)
print(text)

