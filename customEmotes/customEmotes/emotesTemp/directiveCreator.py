import sys

from PIL import Image

def tohex(inputString) :
	return "%02x%02x%02x" % (inputString[0], inputString[1], inputString[2])

filename = sys.argv[1]
# im = Image.open(filename)
# im = im.crop((43, 0, 86, 43))
# im.save(filename)

with Image.open(filename) as image:
    image = image.convert("RGBA")
    width, height = image.size 
    px=image.load()
    outputString = "?replace"


    for x in range(0,width):
      for y in range(0,height):
      	if px[x,y][3] != 0:
            outputString = outputString + ";" + tohex((x,y,0)) + "01=" + tohex(px[x,y]) + "ff"


    outputFile = open("output.txt","w")
    outputFile.write(outputString)
    outputFile.close()

