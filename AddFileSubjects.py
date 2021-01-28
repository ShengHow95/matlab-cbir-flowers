import piexif
import os

os.chdir('C:\\Users\\shenkong\\Desktop\\ImageRetrieval-master\\')
filepath = "C:\\Users\\shenkong\\Desktop\\ImageRetrieval-master\\Flowers\\Tigerlily"
ReferenceFile = "C:\\Users\\shenkong\\Desktop\\ImageRetrieval-master\\Flowers\\Tigerlily\\1.jpg"

exif_dict = piexif.load(ReferenceFile)
exif_bytes = piexif.dump(exif_dict)
print exif_bytes

for filename in os.listdir(filepath):
	if filename == "1.jpg":
		continue
	piexif.transplant(ReferenceFile,filepath+"\\"+filename)