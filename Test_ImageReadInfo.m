%%Added to include keywords to dataset
temp_imageinfo = imfinfo('6.jpg')
temp_desc = zeros(100,0);
temp = temp_imageinfo.UnknownTags.Value;
temp_desc(1:length(temp)) = temp;
k = length(temp_desc);
key = cell(100,100);
%%Added to extract() keywords from dataset
temp_str = '';
char_length = zeros(length(temp_desc)/2,0);
for i = 1:(length(temp_desc)/2)
    j = [temp_desc(i*2-1) temp_desc(i*2)];
    int1 = typecast(uint8(j), 'uint16');
    char_value = deblank(char(j));
    char_length(i) = int1;
    temp_str = strcat(temp_str,char_value);
end

keywords = strsplit(temp_str,',');

txt = ["dog","animal"];

dist1 = zeros(length(keywords),1);
dist2 = zeros(length(keywords),length(txt));

num_char = length(char(keywords(1)))

for i = 1:length(keywords)
    for j = 1:length(txt)
        dist2(i,j) = EditDist(char(keywords(i)),char(txt(j)));
        dist1(i) = dist1(i) + EditDist(char(keywords(i)),char(txt(j)));
    end
end

dist3 = zeros(2,1);
dist3 = sum(dist2,1);
dist3 = sum(dist3);
dist = dist2(1:end-1,:)

str = 'Q!W@W#EE$R%%T123';
str = regexprep(str,'[^a-zA-Z1-9]',' ')      %# Remove characters using regexprep

[k l] = find(dist2==4)


