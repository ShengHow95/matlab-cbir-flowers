function TextSimilarity(numOfReturnedImgs, dataset, img_labels, img_list, txt_input, handles)

%get dataset names
dataset_image_names = dataset(:,end);

%%Extract annotations/keywords from dataset
img_full_annotations = dataset(:,191:end-1);
[r c] = size(img_full_annotations);
temp_str = '';

char_length = zeros(c/2,0);
annotations = cell(r,4);

for h = 1:r
    temp_desc = img_full_annotations(h,:);
    for i = 1:(c/2)
        j = [temp_desc(i*2-1) temp_desc(i*2)];
        int1 = typecast(uint8(j), 'uint16');
        char_value = deblank(char(j));
        char_length(i) = int1;
        temp_str = strcat(temp_str,char_value);
    end
    keys = strsplit(temp_str,',');
    annotations(h,1:length(keys)) = keys;
    
    %clear variables
    temp_str = '';
    clear ('keys');
end

%Extract keywords from query text
text = regexprep(txt_input,'[^a-zA-Z]',' ');
text = lower(text);
keywords = split(text,' ');

%declare distance variables
dist1 = zeros(length(annotations),length(keywords));
dist2 = zeros(length(annotations),length(keywords));
dist_edit = zeros(length(r),1);
dist_jaro = zeros(length(r),1);

%compute string similarity distance
[m n] = size(annotations);
for i = 1:m
    for j = 1:n
        for k = 1:length(keywords)
            
            num_characters = 0;
            num_characters_annotations = length(char(annotations(i,j)));
            num_characters_keywords = length(char(keywords(k)));
            if(num_characters_annotations>=num_characters_keywords)
                num_characters = num_characters_annotations;
            else
                num_characters = num_characters_keywords;
            end
            
            %edit distance
            dist1(j,k) = EditDist(char(annotations(i,j)),char(keywords(k)))/num_characters;

            %jaro distance
            dist2(j,k) = JaroDist(char(annotations(i,j)),char(keywords(k)));
        end
    end
    
    total_distance = sum(dist1,1);
    dist_edit(i) = sum(total_distance)/length(keywords);
    dist_jaro(i) = sum(total_distance);
    
    %clear/reinitialize variables
    total_distance = 0;
    dist1 = zeros(length(annotations),length(keywords));
    dist2 = zeros(length(annotations),length(keywords));
end

%sort according to edit distance
dist_edit = dist_edit';
distance1 = [dist_edit dataset_image_names];

% [sortedDist1 indx1] = sortrows(distance1);
% sortedImgs_edit = sortedDist1(:, 2);

%randomly sort shortest edit distance
[sortedDist1 indx1] = sortrows(distance1);
x1 = find(sortedDist1(:,1)<=(sortedDist1(1,1)+0.1));
idx1 = randperm(length(x1));
temp_sortedDist1 = sortedDist1;
for y1 = 1:length(x1)
    temp_sortedDist1(idx1(y1),2) = sortedDist1(y1,2);
end
sortedImgs_edit = temp_sortedDist1(:, 2);

%sort according to jaro distance
% dist_jaro = dist_jaro';
% distance2 = [dist_jaro dataset_image_names];

% [sortedDist2 indx2] = sortrows(distance2);
% sortedImgs_jaro = sortedDist2(:, 2);

%randomly sort shortest jaro distance
% [sortedDist2 indx2] = sortrows(distance2);
% x2 = find(sortedDist2(:,1)==sortedDist2(1,1));
% idx2 = randperm(length(x2));
% temp_sortedDist2 = sortedDist2;
% for y2 = 1:length(x2)
%     temp_sortedDist2(idx2(y2),2) = sortedDist2(y2,2);
% end
% sortedImgs_jaro = temp_sortedDist2(:, 2);

%show image results from text similarity
img_index = find(dataset_image_names == sortedImgs_edit(1));
handles.RelevantImage1 = string(img_list(img_index));
image = imread(string(img_list(img_index)));
image = imresize(image, [400 300]);
imshow(image,'Parent',handles.axes1);
set(handles.Relevant1,'Visible','On');

img_index = find(dataset_image_names == sortedImgs_edit(2));
handles.RelevantImage2 = string(img_list(img_index));
image = imread(string(img_list(img_index)));
image = imresize(image, [400 300]);
imshow(image,'Parent',handles.axes2);
set(handles.Relevant2,'Visible','On');

img_index = find(dataset_image_names == sortedImgs_edit(3));
handles.RelevantImage3 = string(img_list(img_index));
image = imread(string(img_list(img_index)));
image = imresize(image, [400 300]);
imshow(image,'Parent',handles.axes3);
set(handles.Relevant3,'Visible','On');

img_index = find(dataset_image_names == sortedImgs_edit(4));
handles.RelevantImage4 = string(img_list(img_index));
image = imread(string(img_list(img_index)));
image = imresize(image, [400 300]);
imshow(image,'Parent',handles.axes4);
set(handles.Relevant4,'Visible','On');

img_index = find(dataset_image_names == sortedImgs_edit(5));
handles.RelevantImage5 = string(img_list(img_index));
image = imread(string(img_list(img_index)));
image = imresize(image, [400 300]);
imshow(image,'Parent',handles.axes5);
set(handles.Relevant5,'Visible','On');

img_index = find(dataset_image_names == sortedImgs_edit(6));
handles.RelevantImage6 = string(img_list(img_index));
image = imread(string(img_list(img_index)));
image = imresize(image, [400 300]);
imshow(image,'Parent',handles.axes6);
set(handles.Relevant6,'Visible','On');


guidata(handles.Relevant1, handles);
guidata(handles.Relevant2, handles);
guidata(handles.Relevant3, handles);
guidata(handles.Relevant4, handles);
guidata(handles.Relevant5, handles);
guidata(handles.Relevant6, handles);

end