import os 
  
# Function to rename multiple files 
def main(): 
    i = 1
    filepath = 'C:\\Users\\shenkong\\Desktop\\ImageRetrieval-master\\Flowers'
    for filename in os.listdir(filepath): 
		for files in os.listdir(filepath + "\\" + filename):
			dst = str(i) + '.jpg'
			src = filepath + "\\" + filename + "\\" + files
			dst = filepath + "\\" + filename + "\\" + dst
			
			
			# rename() function will 
			# rename all the files 
			os.rename(src, dst) 
			print i
			i += 1
			
# Driver Code 
if __name__ == '__main__': 
      
    # Calling main() function 
    main() 