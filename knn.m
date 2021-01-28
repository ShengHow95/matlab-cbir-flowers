function [precision, recall, cmat] = knn(numOfReturnedImgs, dataset, queryImageFeatureVector, metric, folder_name, img_ext)
%# load dataset and extract image names
img_names = dataset(:, end);
dataset(:, end) = [];

% extract image name from queryImageFeatureVector
query_img_name = queryImageFeatureVector(:, end);
queryImageFeatureVector(:, end) = [];

% construct labels
lbls = zeros(length(dataset), 1);
for k = 0:length(lbls)-1
    if (img_names(k+1) >= 0 && img_names(k+1) <= 99)
        lbls(k+1) = 1;
    elseif (img_names(k+1) > 99 && img_names(k+1) <= 199)
        lbls(k+1) = 2;
    elseif (img_names(k+1) > 199 && img_names(k+1) <= 299)
        lbls(k+1) = 3;
    elseif (img_names(k+1) > 299 && img_names(k+1) <= 399)
        lbls(k+1) = 4;
    elseif (img_names(k+1) > 399 && img_names(k+1) <= 499)
        lbls(k+1) = 5;
    elseif (img_names(k+1) > 499 && img_names(k+1) <= 599)
        lbls(k+1) = 6;
    elseif (img_names(k+1) > 599 && img_names(k+1) <= 699)
        lbls(k+1) = 7;
    elseif (img_names(k+1) > 699 && img_names(k+1) <= 799)
        lbls(k+1) = 8;
    elseif (img_names(k+1) > 799 && img_names(k+1) <= 899)
        lbls(k+1) = 9;
    elseif (img_names(k+1) > 899 && img_names(k+1) <= 999)
        lbls(k+1) = 10;
    end
end

[g gn] = grp2idx(lbls);                      %# nominal class to numeric

%# split training/testing sets
[trainIdx testIdx] = crossvalind('HoldOut', lbls, 0.30); % split the train and test labels 50%-50%

pairwise = nchoosek(1:size(gn, 1), 2);            %# 1-vs-1 pairwise models
knnModel = cell(size(pairwise, 1), 1);            %# store binary-classifers
predTest = zeros(sum(testIdx), numel(knnModel)); %# store binary predictions

%# classify using one-against-one approach, KNN
for k=1:numel(knnModel)
    %# get only training instances belonging to this pair
    idx = trainIdx & any( bsxfun(@eq, g, pairwise(k,:)) , 2 );

    %# train knn model
%     knnModel{k} = knntrain(dataset(idx,:), g(idx), ...
%         'BoxConstraint',2e-1, 'Kernel_Function','polynomial', 'Polyorder',3);
    knnModel{k} = fitcknn(dataset(idx,:), g(idx), 'NumNeighbors', 3);

    %# test knn model
    %predTest(:,k) = ClassificationKNN(knnModel{k}, dataset(testIdx,:)); % matlab native knn function
    predTest(:,k) = predict(knnModel{k}, dataset(testIdx,:));
end
pred = mode(predTest, 2);   %# voting: clasify as the class receiving most votes

%# performance
cmat = confusionmat(g(testIdx), pred); %# g(testIdx) == targets, pred == outputs
final_acc = 100*sum(diag(cmat))./sum(cmat(:));
fprintf('KNN (1-against-1):\naccuracy = %.2f%%\n', final_acc);
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

for k = 1:numel(knnModel)
    %# test
%     predQueryImg(:, k) = ClassificationKNN(knnModel{k}, queryImageFeatureVector); % queryImage = x.jpg, row=x from dataset
    predQueryImg(:, k) = predict(knnModel{k}, queryImageFeatureVector); % queryImage
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

L2(numOfReturnedImgs, [queryImageFeatureVector query_img_name], imgsInClassXWithoutLbls, metric, folder_name, img_ext);

end