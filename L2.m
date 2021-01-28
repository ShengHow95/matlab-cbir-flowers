function L2(numOfReturnedImages, queryImageFeatureVector, dataset, metric, folder_name, img_ext, img_list, img_names, handles)
% input:
%   numOfReturnedImages : num of images returned by query
%   queryImageFeatureVector: query image in the form of a feature vector
%   dataset: the whole dataset of images transformed in a matrix of
%   features
%
% output:
%   plot: plot images returned by query

% extract image fname from queryImage and dataset
query_img_name = queryImageFeatureVector(:, end);
dataset_image_names = dataset(:, end);
full_dataset_image_names = img_names(:);

queryImageFeatureVector(:, end) = [];
dataset(:, 191:end) = [];

euclidean = zeros(size(dataset, 1), 1);

if (metric == 2)
    % compute euclidean distance
%     for k = 1:size(dataset, 1)
%         euclidean(k) = sqrt( sum( power( dataset(k, :) - queryImageFeatureVector, 2 ) ) );
%     end
    euclidean = pdist2(dataset, queryImageFeatureVector, 'euclidean'); 
elseif (metric == 3)
    euclidean = pdist2(dataset, queryImageFeatureVector, 'cityblock');
elseif (metric == 4)
    euclidean = pdist2(dataset, queryImageFeatureVector, 'minkowski');
elseif (metric == 5)
    euclidean = pdist2(dataset, queryImageFeatureVector, 'cosine');
elseif (metric == 6)
    euclidean = pdist2(dataset, queryImageFeatureVector, 'correlation');
elseif (metric == 7)
    euclidean = pdist2(dataset, queryImageFeatureVector, 'spearman');
end

% add image fnames to euclidean
euclidean = [euclidean dataset_image_names];

% sort them according to smallest distance
[sortEuclidDist indxs] = sortrows(euclidean);
sortedEuclidImgs = sortEuclidDist(:, 2);

% clear axes
arrayfun(@cla, findall(0, 'type', 'axes'));

% display query image
% str_name = int2str(query_img_name);
% query_img = imread( strcat(folder_name, '\', str_name, img_ext) );
% %subplot(1, 6, 1);
% imshow(queryImage, 'Parent',handles.axes1);
% title('Query Image', 'Color', [1 0 0]);

% display images returned by query
% for m = 1:numOfReturnedImages
%     img_name = sortedEuclidImgs(m);
%     img_index = find(full_dataset_image_names == img_name);
%     str_name = string(img_list(img_index));
%     returned_img = imread(str_name);
%     subplot(1, 6, m+1);
%     imshow(returned_img, []);
% end

% display query image
str_name = int2str(query_img_name);
queryImage = imread( strcat(folder_name, '\', str_name, img_ext) );
queryImage = imresize(queryImage, [400 300]);
%subplot(1, 6, 1);
axesImage = imshow(queryImage, 'Parent',handles.axes1);
title(handles.axes1,'Query Image', 'Color', [1 0 0]);
set(handles.Relevant1,'Visible','Off');

% display images returned by query
img_name = sortedEuclidImgs(1);
img_index = find(full_dataset_image_names == img_name);
str_name = string(img_list(img_index));
handles.RelevantImage2 = string(img_list(img_index));
returnedImage = imread(str_name);
returnedImage = imresize(returnedImage, [400 300]);
imshow(returnedImage, 'Parent',handles.axes2);
set(handles.Relevant2,'Visible','On');

img_name = sortedEuclidImgs(2);
img_index = find(full_dataset_image_names == img_name);
str_name = string(img_list(img_index));
handles.RelevantImage3 = string(img_list(img_index));
returnedImage = imread(str_name);
returnedImage = imresize(returnedImage, [400 300]);
imshow(returnedImage, 'Parent',handles.axes3);
set(handles.Relevant3,'Visible','On');

img_name = sortedEuclidImgs(3);
img_index = find(full_dataset_image_names == img_name);
str_name = string(img_list(img_index));
handles.RelevantImage4 = string(img_list(img_index));
returnedImage = imread(str_name);
returnedImage = imresize(returnedImage, [400 300]);
imshow(returnedImage, 'Parent',handles.axes4);
set(handles.Relevant4,'Visible','On');

img_name = sortedEuclidImgs(4);
img_index = find(full_dataset_image_names == img_name);
str_name = string(img_list(img_index));
handles.RelevantImage5 = string(img_list(img_index));
returnedImage = imread(str_name);
returnedImage = imresize(returnedImage, [400 300]);
imshow(returnedImage, 'Parent',handles.axes5);
set(handles.Relevant5,'Visible','On');

img_name = sortedEuclidImgs(5);
img_index = find(full_dataset_image_names == img_name);
str_name = string(img_list(img_index));
handles.RelevantImage6 = string(img_list(img_index));
returnedImage = imread(str_name);
returnedImage = imresize(returnedImage, [400 300]);
imshow(returnedImage, 'Parent',handles.axes6);
set(handles.Relevant6,'Visible','On');

guidata(handles.Relevant2, handles);
guidata(handles.Relevant3, handles);
guidata(handles.Relevant4, handles);
guidata(handles.Relevant5, handles);
guidata(handles.Relevant6, handles);


end