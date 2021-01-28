# Content-Based Information Retrieval
Project Members:
1. Kong Sheng How
2. Lim Yu Qing
3. Lim Chun Ming
4. Clement Lee

## Instructions:

### Step 1:
1. Open "cbires.m" with MATLAB application
2. Click the "Run" button to run the GUI program.
3. If a message prompt out, asking whether to "Add to Path", "Change Folder Path" or "Cancel", please select "Change Folder Path" and continue.

### Step 2:
**If feature database (.mat file) is not generated yet in project folder:**
1. Click the "Image Database Directory" button on the GUI
2. Select the image database folder which in this project is your project directory path + "\Flowers"
	(Note: There are 14 folders with all the images in the "\Flowers" path, please select only the "\Flowers" path as the program will automatically include all the subfolders inside)
3. Click the "Create Feature Database" button to automatically extract features from all the images in the selected path and then save the feature database as .mat file in your project directory.
4. Click the "Load Feature Database" button to load the feature database (.mat file) saved in step 3.
5. Perform query search by either image or text.
6. (Optional) When the retrieval results is shown, click the "Relevant" button below the image to let the system reformulate the search

**If feature database (.mat file) is already generated in project folder:**
1. Click the "Load Feature Database" button to load the feature database (.mat file) saved in step 3.
2. Perform query search by either image or text.
3. (Optional) When the retrieval results is shown, click the "Relevant" button below the image to let the system reformulate the search