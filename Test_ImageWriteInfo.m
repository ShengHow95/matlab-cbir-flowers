databasepath = 'C:\Users\shenkong\Desktop\ImageRetrieval-master\Flowers';
imagedatabase = imageDatastore(databasepath,'IncludeSubfolders',true,'FileExtensions','.jpg','LabelSource','foldernames');
imagelist = imagedatabase.Files;
imglabels = imagedatabase.Labels;

lists = find(imglabels == 'Tigerlily');
max(lists)
min(lists)