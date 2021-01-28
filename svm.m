function [precision, recall, cmat] = svm(numOfReturnedImgs, dataset, queryImageFeatureVector, metric, folder_name, img_ext, img_labels, img_list, img_names, handles)
%# load dataset and extract image names
img_names = dataset(:, end);
dataset(:, 191:end) = [];

% extract image name from queryImageFeatureVector
query_img_name = queryImageFeatureVector(:, end);
queryImageFeatureVector(:, 191:end) = [];

% construct labels
lbls = zeros(length(dataset), 1);
for k = 1:length(lbls)
    if (img_labels(k) == 'Bird of Paradise')
        lbls(k) = 1;
    elseif (img_labels(k) == 'Crocus')
        lbls(k) = 2;
    elseif (img_labels(k) == 'Dahlia')
        lbls(k) = 3;
    elseif (img_labels(k) == 'Daisy')
        lbls(k) = 4;
    elseif (img_labels(k) == 'Frangipani')
        lbls(k) = 5;
    elseif (img_labels(k) == 'Fritillary')
        lbls(k) = 6;
    elseif (img_labels(k) == 'Gazania')
        lbls(k) = 7;
    elseif (img_labels(k) == 'Globe Thistle')
        lbls(k) = 8;
    elseif (img_labels(k) == 'Hard Leave Pocket Orchid')
        lbls(k) = 9;
    elseif (img_labels(k) == 'Osteospermum')
        lbls(k) = 10;
    elseif (img_labels(k) == 'Rose')
        lbls(k) = 11;
    elseif (img_labels(k) == 'Stemless Gentian')
        lbls(k) = 12;
    elseif (img_labels(k) == 'Sunflower')
        lbls(k) = 13;
    elseif (img_labels(k) == 'Tigerlily')
        lbls(k) = 14;
    end
end

[g gn] = grp2idx(lbls);                      %# nominal class to numeric

%# split training/testing sets
[trainIdx testIdx] = crossvalind('Holdout', lbls, 0.3); % split the train and test labels 50%-50%

pairwise = nchoosek(1:size(gn, 1), 2);            %# 1-vs-1 pairwise models
svmModel = cell(size(pairwise, 1), 1);            %# store binary-classifers
predTest = zeros(sum(testIdx), numel(svmModel)); %# store binary predictions

%# classify using one-against-one approach, SVM with 3rd degree poly kernel
for k=1:numel(svmModel)
    %# get only training instances belonging to this pair
    idx = trainIdx & any( bsxfun(@eq, g, pairwise(k,:)) , 2 );

    %# train svm model
%     svmModel{k} = svmtrain(dataset(idx,:), g(idx), ...
%         'BoxConstraint',2e-1, 'Kernel_Function','polynomial', 'Polyorder',3);
    svmModel{k} = fitcsvm(dataset(idx,:), g(idx), 'KernelScale','auto','Standardize',true,...
    'OutlierFraction',0.05);

    %# test svm model
    %predTest(:,k) = ClassificationSVM(svmModel{k}, dataset(testIdx,:)); % matlab native svm function
    predTest(:,k) = predict(svmModel{k}, dataset(testIdx,:));
end
pred = mode(predTest, 2);   %# voting: clasify as the class receiving most votes

%# performance
cmat = confusionmat(g(testIdx), pred); %# g(testIdx) == targets, pred == outputs
final_acc = 100*sum(diag(cmat))./sum(cmat(:));
fprintf('SVM (1-against-1):\naccuracy = %.2f%%\n', final_acc);
fprintf('Confusion Matrix:\n'), disp(cmat)
% assignin('base', 'cmatrix', cmat);

% Precision and recall
% 1st class
precision = zeros(size(gn, 1), 1);
recall = zeros(size(gn, 1), 1);

precision = cmat(1, 1)/sum(cmat(:, 1)); % tp/tp+fp, where tp = true positive, fp = false positive
recall = cmat(1, 1)/sum(cmat(1, :)); % tp/tp+fn, where fn = false negatives
% % 2nd class and forward
for c = 2:size(gn, 1)
    precision(c) = cmat(c, c)/sum(cmat(c:end, c));
    recall(c) = cmat(c, c)/sum(cmat(c, c:end));
end

% verify predictions
% dataset = [dataset img_names lbls];
% testData = dataset(testIdx, :);
% classesInTestData = sort(testData(:, end)); % 500 samples from 10 classes
% predictedImgs = dataset(pred, :);
% dataset(:, end) = [];

for k = 1:numel(svmModel)
    %# test
%     predQueryImg(:, k) = ClassificationSVM(svmModel{k}, queryImageFeatureVector); % queryImage = x.jpg, row=x from dataset
    predQueryImg(:, k) = predict(svmModel{k}, queryImageFeatureVector); % queryImage
end
predFinalQueryImg = mode(predQueryImg, 2); % predicted final image in class x using voting
fprintf('Predicted Query Image Belongs to Class = %d\n', predFinalQueryImg);

% take all images from dataset that belong to class x
dataset = [dataset img_names lbls];
imgsInClassX = dataset( find( dataset(:, end) == predFinalQueryImg ), : );

% Perform knn with queryImage and imgsInClassX
imgsInClassXWithoutLbls = imgsInClassX;
imgsInClassXWithoutLbls(:, end) = [];
% imgsInClassXWithoutLbls(:, end) = [];

%L2(numOfReturnedImgs, [queryImageFeatureVector query_img_name], imgsInClassXWithoutLbls, metric, folder_name, img_ext, img_list);

if (metric == 1)
    L1(5, [queryImageFeatureVector query_img_name], imgsInClassXWithoutLbls, folder_name, img_ext, img_list, img_names, handles);
elseif (metric == 2 || metric == 3 || metric == 4 || metric == 5 || metric == 6  || metric == 7 || metric == 8 || metric == 9)
    L2(5, [queryImageFeatureVector query_img_name], imgsInClassXWithoutLbls, metric, folder_name, img_ext, img_list, img_names, handles);
end



end