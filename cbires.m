function varargout = cbires(varargin)
% CBIRES MATLAB code for cbires.fig
%      CBIRES, by itself, creates a new CBIRES or raises the existing
%      singleton*.
%
%      H = CBIRES returns the handle to a new CBIRES or the handle to
%      the existing singleton*.
%
%      CBIRES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CBIRES.M with the given input arguments.
%
%      CBIRES('Property','Value',...) creates a new CBIRES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cbires_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cbires_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cbires

% Last Modified by GUIDE v2.5 16-May-2019 07:42:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @cbires_OpeningFcn, ...
    'gui_OutputFcn',  @cbires_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end

% --- Executes just before cbires is made visible.
function cbires_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cbires (see VARARGIN)

% Choose default command line output for cbires
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cbires wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = cbires_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in btn_BrowseImage.
function btn_BrowseImage_Callback(hObject, eventdata, handles)
% hObject    handle to btn_BrowseImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[query_fname, query_pathname] = uigetfile('*.jpg; *.png; *.bmp', 'Select query image');

if (query_fname ~= 0)
    query_fullpath = strcat(query_pathname, query_fname);
    imgInfo = imfinfo(query_fullpath);
    img = imread(query_fullpath);
    imshow(img,'Parent',handles.axes8);
    guidata(hObject,handles);
    [pathstr, name, ext] = fileparts(query_fullpath); % fiparts returns char type
    
    if ( strcmp(lower(ext), '.jpg') == 1 || strcmp(lower(ext), '.png') == 1 ...
            || strcmp(lower(ext), '.bmp') == 1 )
        
        queryImage = imread( fullfile( pathstr, strcat(name, ext) ) );
%         handles.queryImage = queryImage;
%         guidata(hObject, handles);
        
        % extract query image features
        queryImage = imresize(queryImage, [400 300]);
        if (strcmp(imgInfo.ColorType, 'truecolor') == 1)
            hsvHist = hsvHistogram(queryImage);
            autoCorrelogram = colorAutoCorrelogram(queryImage);
            color_moments = colorMoments(queryImage);
            % for gabor filters we need gary scale image
            img = double(rgb2gray(queryImage))/255;
            [meanAmplitude, msEnergy] = gaborWavelet(img, 4, 6); % 4 = number of scales, 6 = number of orientations
            wavelet_moments = waveletTransform(queryImage, imgInfo.ColorType);
            % construct the queryImage feature vector
            queryImageFeature = [hsvHist autoCorrelogram color_moments meanAmplitude msEnergy wavelet_moments str2num(name)];
        elseif (strcmp(imgInfo.ColorType, 'grayscale') == 1)
            grayHist = imhist(queryImage);
            grayHist = grayHist/sum(grayHist);
            grayHist = grayHist(:)';
            color_moments = [mean(mean(queryImage)) std(std(double(queryImage)))];
            [meanAmplitude, msEnergy] = gaborWavelet(queryImage, 4, 6); % 4 = number of scales, 6 = number of orientations
            wavelet_moments = waveletTransform(queryImage, imgInfo.ColorType);
            % construct the queryImage feature vector
            queryImageFeature = [grayHist color_moments meanAmplitude msEnergy wavelet_moments str2num(name)];
        end
        
        % update handles
        handles.queryImageFeature = queryImageFeature;
        handles.img_ext = ext;
        handles.folder_name = pathstr;
        guidata(hObject, handles);
        helpdlg('Image is selected and shown. Please proceed with your searching','Image Selection');
        
        % Clear workspace
        clear('query_fname', 'query_pathname', 'query_fullpath', 'pathstr', ...
            'name', 'ext', 'queryImage', 'hsvHist', 'autoCorrelogram', ...
            'color_moments', 'img', 'meanAmplitude', 'msEnergy', ...
            'wavelet_moments', 'queryImageFeature', 'imgInfo');
    else
        errordlg('Please select the correct image file type (.jpg)','Error');
    end
else
    return;
end
end

% --- Executes on selection change in popupmenu_DistanceFunctions.
function popupmenu_DistanceFunctions_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_DistanceFunctions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_DistanceFunctions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_DistanceFunctions

handles.DistanceFunctions = get(handles.popupmenu_DistanceFunctions, 'Value');
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function popupmenu_DistanceFunctions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_DistanceFunctions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in btnExecuteQuery.
function btnExecuteQuery_Callback(hObject, eventdata, handles)
% hObject    handle to btnExecuteQuery (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check for image query
if (~isfield(handles, 'queryImageFeature'))
    errordlg('Please select an image first!','Error');
    return;
end

% check for dataset existence
if (~isfield(handles, 'imageDataset'))
    errordlg('Please load a Feature Database first. If you dont have one, please consider to create one!','Error');
    return;
end

% construct database to store images and label automatically
ImagesDir = strcat(handles.ProjectPath,'Flowers');
ImageDatabase = imageDatastore(ImagesDir,'IncludeSubfolders',true,'FileExtensions','.jpg','LabelSource','foldernames');
ImageLists = ImageDatabase.Files;
ImageLabels = ImageDatabase.Labels;
handles.ImageLists = ImageLists;
handles.ImageLabels = ImageLabels;
guidata(hObject, handles);

% set variables
if (~isfield(handles, 'DistanceFunctions') && ~isfield(handles, 'numOfReturnedImages'))
    metric = get(handles.popupmenu_DistanceFunctions, 'Value');
    %numOfReturnedImgs = get(handles.popupmenu_NumOfReturnedImages, 'Value');
elseif (~isfield(handles, 'DistanceFunctions') || ~isfield(handles, 'numOfReturnedImages'))
    if (~isfield(handles, 'DistanceFunctions'))
        metric = get(handles.popupmenu_DistanceFunctions, 'Value');
        %numOfReturnedImgs = handles.numOfReturnedImages;
    else
        metric = handles.DistanceFunctions;
        %numOfReturnedImgs = get(handles.popupmenu_NumOfReturnedImages, 'Value');
    end
else
    metric = handles.DistanceFunctions;
    %numOfReturnedImgs = handles.numOfReturnedImages;
end

if (metric == 1)
    L1(5, handles.queryImageFeature, handles.imageDataset.dataset, handles.folder_name, handles.img_ext, handles.ImageLists, handles.ImageNames, handles);
elseif (metric == 2 || metric == 3 || metric == 4 || metric == 5 || metric == 6  || metric == 7 || metric == 8 || metric == 9)
    L2(5, handles.queryImageFeature, handles.imageDataset.dataset, metric, handles.folder_name, handles.img_ext, handles.ImageLists, handles.ImageNames, handles);
else
    relativeDeviation(5, handles.queryImageFeature, handles.imageDataset.dataset, handles.folder_name, handles.img_ext, handles.ImageLists, handles.ImageNames, handles);
end
end

% --- Executes on button press in btnExecuteConfusionMatrix.
function btnExecuteConfusionMatrix_Callback(hObject, eventdata, handles)
% hObject    handle to btnExecuteConfusionMatrix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check for image query
if (~isfield(handles, 'queryImageFeature'))
    errordlg('Please select an image first!','Error');
    return;
end

% check for dataset existence
if (~isfield(handles, 'imageDataset'))
    errordlg('Please load a Feature Database first. If you dont have one, please consider to create one!','Error');
    return;
end

% construct database to store images and label automatically
ImagesDir = strcat(handles.ProjectPath,'Flowers');
ImageDatabase = imageDatastore(ImagesDir,'IncludeSubfolders',true,'FileExtensions','.jpg','LabelSource','foldernames');
ImageLists = ImageDatabase.Files;
ImageLabels = ImageDatabase.Labels;
handles.ImageLists = ImageLists;
handles.ImageLabels = ImageLabels;
guidata(hObject, handles);

%numOfReturnedImgs = get(handles.popupmenu_NumOfReturnedImages, 'Value');
metric = get(handles.popupmenu_DistanceFunctions, 'Value');

% call svm function passing as parameters the numOfReturnedImgs, queryImage and the dataset
 [~, ~, cmat] = svm(5, handles.imageDataset.dataset, handles.queryImageFeature, metric, handles.folder_name, handles.img_ext, handles.ImageLabels, handles.ImageLists, handles.ImageNames, handles);
% [~, ~, cmat] = knn(5, handles.imageDataset.dataset, handles.queryImageFeature, metric, handles.folder_name, handles.img_ext);

% plot confusion matrix
opt = confMatPlot('defaultOpt');
opt.className = {
    'Bird of Paradise', 'Crocus', 'Dahlia', ...
    'Daisy', 'Frangipani', 'Fritillary', ...
    'Gazania', 'Globe Thistle', 'Hard Leave Pocket Orchid', ...
    'Osteospermum', 'Rose', 'Stemless Gentian', ...
    'Sunflower', 'Tigerlily'
    };
opt.mode = 'both';
figure('Name', 'Confusion Matrix');
confMatPlot(cmat, opt);
xlabel('Confusion Matrix');
end

% --- Executes on button press in btnSelectImageDirectory.
function btnSelectImageDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to btnSelectImageDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% select image directory
folder_name = uigetdir(pwd, 'Select the directory of images');
if ( folder_name ~= 0 )
    handles.folder_name = folder_name;
    guidata(hObject, handles);
else
    return;
end
end

% --- Executes on button press in btnCreateDB.
function btnCreateDB_Callback(hObject, eventdata, handles)
% hObject    handle to btnCreateDB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (~isfield(handles, 'folder_name'))
    errordlg('Please select an image directory first!','Error');
    return;
end

% construct database to store images and label automatically
ImagesDir = fullfile(handles.folder_name);
ImageDatabase = imageDatastore(ImagesDir,'IncludeSubfolders',true,'FileExtensions','.jpg','LabelSource','foldernames');
ImageLists = ImageDatabase.Files;
ImageLabels = ImageDatabase.Labels;
handles.ImageLists = ImageLists;

totalImages = length(ImageLists);

if (totalImages > 0)
    % read jpg images from stored folder name
    % directory and construct the feature dataset
    oldHisv = 0;
    oldautoCorrelogram = 0;
    for k = 1:totalImages
        % read image
        ImagePath = string(ImageLists(k));
        image = imread(ImagePath);
        [pathstr, name, ext] = fileparts(ImagePath);
        image = imresize(image, [400 300]);
        imgInfo = imfinfo(ImagePath);
        
        %%Added to include keywords to dataset
        temp_desc = zeros(1,100);
        temp_tags_bytes = zeros(1,100);
        temp_imageinfo = imgInfo;
        temp_desc = temp_imageinfo.UnknownTags.Value;
        temp_tags_bytes(1:length(temp_desc)) = temp_desc;
        temp_len = length(temp_desc);
        
        if (strcmp(imgInfo.ColorType, 'grayscale') == 1)
            grayHist = imhist(image);
            grayHist = grayHist/sum(grayHist);
            grayHist = grayHist(:)';
            color_moments = [mean(mean(image)) std(std(double(image)))];
            [meanAmplitude, msEnergy] = gaborWavelet(image, 4, 6); % 4 = number of scales, 6 = number of orientations
            wavelet_moments = waveletTransform(image, imgInfo.ColorType);
            % construct the dataset
            set = [grayHist color_moments meanAmplitude msEnergy wavelet_moments temp_tags_bytes];
        elseif (strcmp(imgInfo.ColorType, 'truecolor') == 1)
            hsvHist = 0;
            try
                hsvHist = hsvHistogram(image);
                autoCorrelogram = colorAutoCorrelogram(image);
                oldHisv = hsvHist;
                oldautoCorrelogram = autoCorrelogram;
            catch
                hsvHist = oldHisv;
                autoCorrelogram = oldautoCorrelogram;
            end
            color_moments = colorMoments(image);
            % for gabor filters we need gray scale image
            img = double(rgb2gray(image))/255;
            [meanAmplitude, msEnergy] = gaborWavelet(img, 4, 6); % 4 = number of scales, 6 = number of orientations
            wavelet_moments = waveletTransform(image, imgInfo.ColorType);
            % construct the dataset
            set = [hsvHist autoCorrelogram color_moments meanAmplitude msEnergy wavelet_moments temp_tags_bytes];
        end

        % add to the last column the name of image file we are processing at
        % the moment
        dataset(k, :) = [set str2num(name)];
        
        % clear workspace
        clear('image', 'img', 'hsvHist', 'autoCorrelogram', 'color_moments', ...
            'gabor_wavelet', 'wavelet_moments', 'set', ...
            'imgInfo', 'temp_desc', 'temp_tags_bytes', 'temp_len', 'temp_imageinfo');
    end
    
    % prompt to save dataset
    uisave('dataset', 'dataset1');
    % save('dataset.mat', 'dataset', '-mat');
    clear('dataset');
end
end

% --- Executes on button press in btn_LoadDataset.
function btn_LoadDataset_Callback(hObject, eventdata, handles)
% hObject    handle to btn_LoadDataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fname, pthname] = uigetfile('*.mat', 'Select the Dataset');
if (fname ~= 0)
    dataset_fullpath = strcat(pthname, fname);
    [pathstr, name, ext] = fileparts(dataset_fullpath);
    if ( strcmp(lower(ext), '.mat') == 1)
        filename = fullfile( pathstr, strcat(name, ext) );
        img_dataset = load(filename);
        handles.imageDataset = img_dataset;
        handles.ImageNames = img_dataset.dataset(:,end);
        handles.ProjectPath = pthname;
        guidata(hObject, handles);
        % make dataset visible from workspace
        % assignin('base', 'database', handles.imageDataset.dataset);
        helpdlg('Feature Database is successfully loaded!','Load Feature Database');
    else
        errordlg('Please select the correct file type (.mat)','Error');
    end
else
    return;
end
end


function TextInput_Callback(hObject, eventdata, handles)
% hObject    handle to TextInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TextInput as text
%        str2double(get(hObject,'String')) returns contents of TextInput as a double
end

% --- Executes during object creation, after setting all properties.
function TextInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TextInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in Search_Bttn.
function Search_Bttn_Callback(hObject, eventdata, handles)
% hObject    handle to Search_Bttn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check for dataset existence
if (~isfield(handles, 'imageDataset'))
    errordlg('Please load a Feature Database first. If you dont have one, please consider to create one!','Error');
    return;
end

handles.SearchedText = get(handles.TextInput, 'String');

% construct database to store images and label automatically
ImagesDir = strcat(handles.ProjectPath,'Flowers');
ImageDatabase = imageDatastore(ImagesDir,'IncludeSubfolders',true,'FileExtensions','.jpg','LabelSource','foldernames');
ImageLists = ImageDatabase.Files;
ImageLabels = ImageDatabase.Labels;
handles.ImageLists = ImageLists;
handles.ImageLabels = ImageLabels;
handles.RelevantImage1 = '';
handles.RelevantImage2 = '';
handles.RelevantImage3 = '';
handles.RelevantImage4 = '';
handles.RelevantImage5 = '';
handles.RelevantImage6 = '';
guidata(hObject, handles);

TextSimilarity(5, handles.imageDataset.dataset, handles.ImageLabels, handles.ImageLists, handles.SearchedText, handles);
end

% --- Executes on button press in Relevant2.
function Relevant1_Callback(hObject, eventdata, handles)
% hObject    handle to Relevant2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[pathstr, name, ext] = fileparts(handles.RelevantImage1); % fileparts returns char type
queryImage = imread(handles.RelevantImage1);        
queryImage = imresize(queryImage, [400 300]);
imgInfo = imfinfo(handles.RelevantImage1);
handles.img_ext = ext;
handles.folder_name = pathstr;
        
% extract query image features
if (strcmp(imgInfo.ColorType, 'truecolor') == 1)
            hsvHist = hsvHistogram(queryImage);
            autoCorrelogram = colorAutoCorrelogram(queryImage);
            color_moments = colorMoments(queryImage);
            % for gabor filters we need gary scale image
            img = double(rgb2gray(queryImage))/255;
            [meanAmplitude, msEnergy] = gaborWavelet(img, 4, 6); % 4 = number of scales, 6 = number of orientations
            wavelet_moments = waveletTransform(queryImage, imgInfo.ColorType);
            % construct the queryImage feature vector
            queryImageFeature = [hsvHist autoCorrelogram color_moments meanAmplitude msEnergy wavelet_moments str2num(name)];
elseif (strcmp(imgInfo.ColorType, 'grayscale') == 1)
            grayHist = imhist(queryImage);
            grayHist = grayHist/sum(grayHist);
            grayHist = grayHist(:)';
            color_moments = [mean(mean(queryImage)) std(std(double(queryImage)))];
            [meanAmplitude, msEnergy] = gaborWavelet(queryImage, 4, 6); % 4 = number of scales, 6 = number of orientations
            wavelet_moments = waveletTransform(queryImage, imgInfo.ColorType);
            % construct the queryImage feature vector
            queryImageFeature = [grayHist color_moments meanAmplitude msEnergy wavelet_moments str2num(name)];
end
        
% construct database to store images and label automatically
ImagesDir = strcat(handles.ProjectPath,'Flowers');
ImageDatabase = imageDatastore(ImagesDir,'IncludeSubfolders',true,'FileExtensions','.jpg','LabelSource','foldernames');
ImageLists = ImageDatabase.Files;
ImageLabels = ImageDatabase.Labels;
handles.ImageLists = ImageLists;
handles.ImageLabels = ImageLabels;
        
% update handles
handles.queryImageFeature = queryImageFeature;
guidata(hObject, handles);

metric = get(handles.popupmenu_DistanceFunctions, 'Value');

if (metric == 1)
    L1(5, handles.queryImageFeature, handles.imageDataset.dataset, handles.folder_name, handles.img_ext, handles.ImageLists, handles.ImageNames, handles);
elseif (metric == 2 || metric == 3 || metric == 4 || metric == 5 || metric == 6  || metric == 7 || metric == 8 || metric == 9)
    L2(5, handles.queryImageFeature, handles.imageDataset.dataset, metric, handles.folder_name, handles.img_ext, handles.ImageLists, handles.ImageNames, handles);
else
    relativeDeviation(5, handles.queryImageFeature, handles.imageDataset.dataset, handles.folder_name, handles.img_ext, handles.ImageLists, handles.ImageNames, handles);
end
        
end


% --- Executes on button press in Relevant2.
function Relevant2_Callback(hObject, eventdata, handles)
% hObject    handle to Relevant2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[pathstr, name, ext] = fileparts(handles.RelevantImage2); % fileparts returns char type
queryImage = imread(handles.RelevantImage2);        
queryImage = imresize(queryImage, [400 300]);
imgInfo = imfinfo(handles.RelevantImage2);
handles.img_ext = ext;
handles.folder_name = pathstr;
        
% extract query image features
if (strcmp(imgInfo.ColorType, 'truecolor') == 1)
            hsvHist = hsvHistogram(queryImage);
            autoCorrelogram = colorAutoCorrelogram(queryImage);
            color_moments = colorMoments(queryImage);
            % for gabor filters we need gary scale image
            img = double(rgb2gray(queryImage))/255;
            [meanAmplitude, msEnergy] = gaborWavelet(img, 4, 6); % 4 = number of scales, 6 = number of orientations
            wavelet_moments = waveletTransform(queryImage, imgInfo.ColorType);
            % construct the queryImage feature vector
            queryImageFeature = [hsvHist autoCorrelogram color_moments meanAmplitude msEnergy wavelet_moments str2num(name)];
elseif (strcmp(imgInfo.ColorType, 'grayscale') == 1)
            grayHist = imhist(queryImage);
            grayHist = grayHist/sum(grayHist);
            grayHist = grayHist(:)';
            color_moments = [mean(mean(queryImage)) std(std(double(queryImage)))];
            [meanAmplitude, msEnergy] = gaborWavelet(queryImage, 4, 6); % 4 = number of scales, 6 = number of orientations
            wavelet_moments = waveletTransform(queryImage, imgInfo.ColorType);
            % construct the queryImage feature vector
            queryImageFeature = [grayHist color_moments meanAmplitude msEnergy wavelet_moments str2num(name)];
end
        
% construct database to store images and label automatically
ImagesDir = strcat(handles.ProjectPath,'Flowers');
ImageDatabase = imageDatastore(ImagesDir,'IncludeSubfolders',true,'FileExtensions','.jpg','LabelSource','foldernames');
ImageLists = ImageDatabase.Files;
ImageLabels = ImageDatabase.Labels;
handles.ImageLists = ImageLists;
handles.ImageLabels = ImageLabels;
        
% update handles
handles.queryImageFeature = queryImageFeature;
guidata(hObject, handles);

metric = get(handles.popupmenu_DistanceFunctions, 'Value');

if (metric == 1)
    L1(5, handles.queryImageFeature, handles.imageDataset.dataset, handles.folder_name, handles.img_ext, handles.ImageLists, handles.ImageNames, handles);
elseif (metric == 2 || metric == 3 || metric == 4 || metric == 5 || metric == 6  || metric == 7 || metric == 8 || metric == 9)
    L2(5, handles.queryImageFeature, handles.imageDataset.dataset, metric, handles.folder_name, handles.img_ext, handles.ImageLists, handles.ImageNames, handles);
else
    relativeDeviation(5, handles.queryImageFeature, handles.imageDataset.dataset, handles.folder_name, handles.img_ext, handles.ImageLists, handles.ImageNames, handles);
end

end


% --- Executes on button press in Relevant3.
function Relevant3_Callback(hObject, eventdata, handles)
% hObject    handle to Relevant3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[pathstr, name, ext] = fileparts(handles.RelevantImage3); % fileparts returns char type
queryImage = imread(handles.RelevantImage3);        
queryImage = imresize(queryImage, [400 300]);
imgInfo = imfinfo(handles.RelevantImage3);
handles.img_ext = ext;
handles.folder_name = pathstr;
        
% extract query image features
if (strcmp(imgInfo.ColorType, 'truecolor') == 1)
            hsvHist = hsvHistogram(queryImage);
            autoCorrelogram = colorAutoCorrelogram(queryImage);
            color_moments = colorMoments(queryImage);
            % for gabor filters we need gary scale image
            img = double(rgb2gray(queryImage))/255;
            [meanAmplitude, msEnergy] = gaborWavelet(img, 4, 6); % 4 = number of scales, 6 = number of orientations
            wavelet_moments = waveletTransform(queryImage, imgInfo.ColorType);
            % construct the queryImage feature vector
            queryImageFeature = [hsvHist autoCorrelogram color_moments meanAmplitude msEnergy wavelet_moments str2num(name)];
elseif (strcmp(imgInfo.ColorType, 'grayscale') == 1)
            grayHist = imhist(queryImage);
            grayHist = grayHist/sum(grayHist);
            grayHist = grayHist(:)';
            color_moments = [mean(mean(queryImage)) std(std(double(queryImage)))];
            [meanAmplitude, msEnergy] = gaborWavelet(queryImage, 4, 6); % 4 = number of scales, 6 = number of orientations
            wavelet_moments = waveletTransform(queryImage, imgInfo.ColorType);
            % construct the queryImage feature vector
            queryImageFeature = [grayHist color_moments meanAmplitude msEnergy wavelet_moments str2num(name)];
end
        
% construct database to store images and label automatically
ImagesDir = strcat(handles.ProjectPath,'Flowers');
ImageDatabase = imageDatastore(ImagesDir,'IncludeSubfolders',true,'FileExtensions','.jpg','LabelSource','foldernames');
ImageLists = ImageDatabase.Files;
ImageLabels = ImageDatabase.Labels;
handles.ImageLists = ImageLists;
handles.ImageLabels = ImageLabels;
        
% update handles
handles.queryImageFeature = queryImageFeature;
guidata(hObject, handles);

metric = get(handles.popupmenu_DistanceFunctions, 'Value');

if (metric == 1)
    L1(5, handles.queryImageFeature, handles.imageDataset.dataset, handles.folder_name, handles.img_ext, handles.ImageLists, handles.ImageNames, handles);
elseif (metric == 2 || metric == 3 || metric == 4 || metric == 5 || metric == 6  || metric == 7 || metric == 8 || metric == 9)
    L2(5, handles.queryImageFeature, handles.imageDataset.dataset, metric, handles.folder_name, handles.img_ext, handles.ImageLists, handles.ImageNames, handles);
else
    relativeDeviation(5, handles.queryImageFeature, handles.imageDataset.dataset, handles.folder_name, handles.img_ext, handles.ImageLists, handles.ImageNames, handles);
end

end


% --- Executes on button press in Relevant4.
function Relevant4_Callback(hObject, eventdata, handles)
% hObject    handle to Relevant4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[pathstr, name, ext] = fileparts(handles.RelevantImage4); % fileparts returns char type
queryImage = imread(handles.RelevantImage4);        
queryImage = imresize(queryImage, [400 300]);
imgInfo = imfinfo(handles.RelevantImage4);
handles.img_ext = ext;
handles.folder_name = pathstr;
        
% extract query image features
if (strcmp(imgInfo.ColorType, 'truecolor') == 1)
            hsvHist = hsvHistogram(queryImage);
            autoCorrelogram = colorAutoCorrelogram(queryImage);
            color_moments = colorMoments(queryImage);
            % for gabor filters we need gary scale image
            img = double(rgb2gray(queryImage))/255;
            [meanAmplitude, msEnergy] = gaborWavelet(img, 4, 6); % 4 = number of scales, 6 = number of orientations
            wavelet_moments = waveletTransform(queryImage, imgInfo.ColorType);
            % construct the queryImage feature vector
            queryImageFeature = [hsvHist autoCorrelogram color_moments meanAmplitude msEnergy wavelet_moments str2num(name)];
elseif (strcmp(imgInfo.ColorType, 'grayscale') == 1)
            grayHist = imhist(queryImage);
            grayHist = grayHist/sum(grayHist);
            grayHist = grayHist(:)';
            color_moments = [mean(mean(queryImage)) std(std(double(queryImage)))];
            [meanAmplitude, msEnergy] = gaborWavelet(queryImage, 4, 6); % 4 = number of scales, 6 = number of orientations
            wavelet_moments = waveletTransform(queryImage, imgInfo.ColorType);
            % construct the queryImage feature vector
            queryImageFeature = [grayHist color_moments meanAmplitude msEnergy wavelet_moments str2num(name)];
end
        
% construct database to store images and label automatically
ImagesDir = strcat(handles.ProjectPath,'Flowers');
ImageDatabase = imageDatastore(ImagesDir,'IncludeSubfolders',true,'FileExtensions','.jpg','LabelSource','foldernames');
ImageLists = ImageDatabase.Files;
ImageLabels = ImageDatabase.Labels;
handles.ImageLists = ImageLists;
handles.ImageLabels = ImageLabels;
        
% update handles
handles.queryImageFeature = queryImageFeature;
guidata(hObject, handles);

metric = get(handles.popupmenu_DistanceFunctions, 'Value');

if (metric == 1)
    L1(5, handles.queryImageFeature, handles.imageDataset.dataset, handles.folder_name, handles.img_ext, handles.ImageLists, handles.ImageNames, handles);
elseif (metric == 2 || metric == 3 || metric == 4 || metric == 5 || metric == 6  || metric == 7 || metric == 8 || metric == 9)
    L2(5, handles.queryImageFeature, handles.imageDataset.dataset, metric, handles.folder_name, handles.img_ext, handles.ImageLists, handles.ImageNames, handles);
else
    relativeDeviation(5, handles.queryImageFeature, handles.imageDataset.dataset, handles.folder_name, handles.img_ext, handles.ImageLists, handles.ImageNames, handles);
end

end


% --- Executes on button press in Relevant5.
function Relevant5_Callback(hObject, eventdata, handles)
% hObject    handle to Relevant5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[pathstr, name, ext] = fileparts(handles.RelevantImage5); % fileparts returns char type
queryImage = imread(handles.RelevantImage5);        
queryImage = imresize(queryImage, [400 300]);
imgInfo = imfinfo(handles.RelevantImage5);
handles.img_ext = ext;
handles.folder_name = pathstr;
        
% extract query image features
if (strcmp(imgInfo.ColorType, 'truecolor') == 1)
            hsvHist = hsvHistogram(queryImage);
            autoCorrelogram = colorAutoCorrelogram(queryImage);
            color_moments = colorMoments(queryImage);
            % for gabor filters we need gary scale image
            img = double(rgb2gray(queryImage))/255;
            [meanAmplitude, msEnergy] = gaborWavelet(img, 4, 6); % 4 = number of scales, 6 = number of orientations
            wavelet_moments = waveletTransform(queryImage, imgInfo.ColorType);
            % construct the queryImage feature vector
            queryImageFeature = [hsvHist autoCorrelogram color_moments meanAmplitude msEnergy wavelet_moments str2num(name)];
elseif (strcmp(imgInfo.ColorType, 'grayscale') == 1)
            grayHist = imhist(queryImage);
            grayHist = grayHist/sum(grayHist);
            grayHist = grayHist(:)';
            color_moments = [mean(mean(queryImage)) std(std(double(queryImage)))];
            [meanAmplitude, msEnergy] = gaborWavelet(queryImage, 4, 6); % 4 = number of scales, 6 = number of orientations
            wavelet_moments = waveletTransform(queryImage, imgInfo.ColorType);
            % construct the queryImage feature vector
            queryImageFeature = [grayHist color_moments meanAmplitude msEnergy wavelet_moments str2num(name)];
end
        
% construct database to store images and label automatically
ImagesDir = strcat(handles.ProjectPath,'Flowers');
ImageDatabase = imageDatastore(ImagesDir,'IncludeSubfolders',true,'FileExtensions','.jpg','LabelSource','foldernames');
ImageLists = ImageDatabase.Files;
ImageLabels = ImageDatabase.Labels;
handles.ImageLists = ImageLists;
handles.ImageLabels = ImageLabels;
        
% update handles
handles.queryImageFeature = queryImageFeature;
guidata(hObject, handles);

metric = get(handles.popupmenu_DistanceFunctions, 'Value');
        
if (metric == 1)
    L1(5, handles.queryImageFeature, handles.imageDataset.dataset, handles.folder_name, handles.img_ext, handles.ImageLists, handles.ImageNames, handles);
elseif (metric == 2 || metric == 3 || metric == 4 || metric == 5 || metric == 6  || metric == 7 || metric == 8 || metric == 9)
    L2(5, handles.queryImageFeature, handles.imageDataset.dataset, metric, handles.folder_name, handles.img_ext, handles.ImageLists, handles.ImageNames, handles);
else
    relativeDeviation(5, handles.queryImageFeature, handles.imageDataset.dataset, handles.folder_name, handles.img_ext, handles.ImageLists, handles.ImageNames, handles);
end

end


% --- Executes on button press in Relevant6.
function Relevant6_Callback(hObject, eventdata, handles)
% hObject    handle to Relevant6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[pathstr, name, ext] = fileparts(handles.RelevantImage6); % fileparts returns char type
queryImage = imread(handles.RelevantImage6);        
queryImage = imresize(queryImage, [400 300]);
imgInfo = imfinfo(handles.RelevantImage6);
handles.img_ext = ext;
handles.folder_name = pathstr;
        
% extract query image features
if (strcmp(imgInfo.ColorType, 'truecolor') == 1)
            hsvHist = hsvHistogram(queryImage);
            autoCorrelogram = colorAutoCorrelogram(queryImage);
            color_moments = colorMoments(queryImage);
            % for gabor filters we need gary scale image
            img = double(rgb2gray(queryImage))/255;
            [meanAmplitude, msEnergy] = gaborWavelet(img, 4, 6); % 4 = number of scales, 6 = number of orientations
            wavelet_moments = waveletTransform(queryImage, imgInfo.ColorType);
            % construct the queryImage feature vector
            queryImageFeature = [hsvHist autoCorrelogram color_moments meanAmplitude msEnergy wavelet_moments str2num(name)];
elseif (strcmp(imgInfo.ColorType, 'grayscale') == 1)
            grayHist = imhist(queryImage);
            grayHist = grayHist/sum(grayHist);
            grayHist = grayHist(:)';
            color_moments = [mean(mean(queryImage)) std(std(double(queryImage)))];
            [meanAmplitude, msEnergy] = gaborWavelet(queryImage, 4, 6); % 4 = number of scales, 6 = number of orientations
            wavelet_moments = waveletTransform(queryImage, imgInfo.ColorType);
            % construct the queryImage feature vector
            queryImageFeature = [grayHist color_moments meanAmplitude msEnergy wavelet_moments str2num(name)];
end
        
% construct database to store images and label automatically
ImagesDir = strcat(handles.ProjectPath,'Flowers');
ImageDatabase = imageDatastore(ImagesDir,'IncludeSubfolders',true,'FileExtensions','.jpg','LabelSource','foldernames');
ImageLists = ImageDatabase.Files;
ImageLabels = ImageDatabase.Labels;
handles.ImageLists = ImageLists;
handles.ImageLabels = ImageLabels;
        
% update handles
handles.queryImageFeature = queryImageFeature;
guidata(hObject, handles);

metric = get(handles.popupmenu_DistanceFunctions, 'Value');

if (metric == 1)
    L1(5, handles.queryImageFeature, handles.imageDataset.dataset, handles.folder_name, handles.img_ext, handles.ImageLists, handles.ImageNames, handles);
elseif (metric == 2 || metric == 3 || metric == 4 || metric == 5 || metric == 6  || metric == 7 || metric == 8 || metric == 9)
    L2(5, handles.queryImageFeature, handles.imageDataset.dataset, metric, handles.folder_name, handles.img_ext, handles.ImageLists, handles.ImageNames, handles);
end

end
