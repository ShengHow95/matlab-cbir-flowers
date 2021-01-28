function  jaro = JaroDist(s1,s2)
% jw = jarowinkler(s1,s2) calculates the Jaro Winker string distance between
% strings s1 and s2

s1 = lower(s1);
s2 = lower(s2);
s1l = length(s1);
s2l = length(s2);
s11 = repmat(s1,s2l,1);
s22 = repmat(s2',1,s1l);
% Calculate the matching distance
mtxwin = floor(max(length(s1),length(s2))/2)-1;
mtxmat = double(s11 == s22);
% Ignore the matched characters outside of matching distance
mtxmat = mtxmat - tril(mtxmat,-mtxwin-1) - triu(mtxmat,mtxwin+1);
% Ignore additional matches beyond first match
m = zeros(s2l,s1l);
for i=1:s1l
    if any(mtxmat(:,i))
        fmatid = find(~any(m,2) & mtxmat(:,i),1);
        m(fmatid,i) = mtxmat(fmatid,i);
    end
end
s1m = any(m);
s2m = any(m,2);
% Calculate the number of transpositions
t = sum(~mtxmat(sub2ind(size(m),find(s2m),find(s1m)')))/2;
% Calculate the number of matches
m = sum(s1m);

if m == 0
    jaro = 0;
else
    % Jaro distance
    jaro = (m/s1l + m/s2l + (m-t)/m)/3;
    % Winkler modification
    %jw = dj + 0.1*(s1(1:3)==s2(1:3))*cumprod(s1(1:3)==s2(1:3))'*(1-dj);
end