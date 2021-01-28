function L1(numOfReturnedImages, queryImageFeatureVector, dataset, folder_name, img_ext, img_list, img_names, handles)
% input:
%   numOfReturnedImages : num of images returned by query
%   queryImageFeatureVector: query image in the form of a feature vector
%   dataset: the whole dataset of images transformed in a matrix of
%   features
% 
% output: 
%   plot: plot images returned by query

% extract image fname from queryImage and dataset
query_image_name = queryImageFeatureVector(:, end);
dataset_image_names = dataset(:, end);
full_dataset_image_names = img_names(:);

queryImageFeatureVector(:, end) = [];
dataset(:, 191:end) = [];

% compute manhattan distance
manhattan = zeros(size(dataset, 1), 1);
for k = 1:size(dataset, 1)
%     manhattan(k) = sum( abs(dataset(k, :) - queryImageFeatureVector) );
    % ralative manhattan distance
    manhattan(k) = sum( abs(dataset(k, :) - queryImageFeatureVector) ./ ( 1 + dataset(k, :) + queryImageFeatureVector ) );
end

% add image fnames to manhattan
manhattan = [manhattan dataset_image_names];

% sort them according to smallest distance
[sortedDist indx] = sortrows(manhattan);
sortedImgs = sortedDist(:, 2);

% clear axes
arrayfun(@cla, findall(0, 'type', 'axes'));

% display query image
str_name = int2str(query_image_name);
queryImage = imread( strcat(folder_name, '\', str_name, img_ext) );
queryImage = imresize(queryImage, [400 300]);
%subplot(1, 6, 1);
image = imshow(queryImage, 'Parent',handles.axes1);
title(handles.axes1, 'Query Image', 'Color', [1 0 0]);
set(handles.Relevant1,'Visible','Off');

% display images returned by query
img_name = sortedImgs(1);
img_index = find(full_dataset_image_names == img_name);
str_name = string(img_list(img_index));
handles.RelevantImage2 = string(img_list(img_index));
returnedImage = imread(str_name);
returnedImage = imresize(returnedImage, [400 300]);
imshow(returnedImage, 'Parent',handles.axes2);
set(handles.Relevant2,'Visible','On');

img_name = sortedImgs(2);
img_index = find(full_dataset_image_names == img_name);
str_name = string(img_list(img_index));
handles.RelevantImage3 = string(img_list(img_index));
returnedImage = imread(str_name);
returnedImage = imresize(returnedImage, [400 300]);
imshow(returnedImage, 'Parent',handles.axes3);
set(handles.Relevant3,'Visible','On');

img_name = sortedImgs(3);
img_index = find(full_dataset_image_names == img_name);
str_name = string(img_list(img_index));
handles.RelevantImage4 = string(img_list(img_index));
returnedImage = imread(str_name);
returnedImage = imresize(returnedImage, [400 300]);
imshow(returnedImage, 'Parent',handles.axes4);
set(handles.Relevant4,'Visible','On');

img_name = sortedImgs(4);
img_index = find(full_dataset_image_names == img_name);
str_name = string(img_list(img_index));
handles.RelevantImage5 = string(img_list(img_index));
returnedImage = imread(str_name);
returnedImage = imresize(returnedImage, [400 300]);
imshow(returnedImage, 'Parent',handles.axes5);
set(handles.Relevant5,'Visible','On');

img_name = sortedImgs(5);
img_index = find(full_dataset_image_names == img_name);
str_name = string(img_list(img_index));
handles.RelevantImage6 = string(img_list(img_index));
returnedImage = imread(str_name);
returnedImage = imresize(returnedImage, [400 300]);
imshow(returnedImage, 'Parent',handles.axes6);
set(handles.Relevant6,'Visible','On');

% for m = 1:numOfReturnedImages
%     img_name = sortedImgs(m);
%     img_index = find(full_dataset_image_names == img_name);
%     str_name = string(img_list(img_index));
%     returnedImage = imread(str_name);
%     subplot(1, 6, m+1);
%     imshow(returnedImage, []);
% end

guidata(handles.Relevant2, handles);
guidata(handles.Relevant3, handles);
guidata(handles.Relevant4, handles);
guidata(handles.Relevant5, handles);
guidata(handles.Relevant6, handles);

end