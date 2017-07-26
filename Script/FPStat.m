dataRoot = '/h2/yexi/Desktop/data/healthy/';
resultRoot = '/h2/yexi/Desktop/result/';

availableIdx = [1:1:94];
availableIdx(availableIdx == 1) = [];
availableIdx(availableIdx == 10) = [];
availableIdx(availableIdx == 74) = [];

m = length(availableIdx);

dist = zeros(m, 37);

for i = 1:m

    idx = availableIdx(i);
    model = load([dataRoot 'mat/' num2str(idx) '.mat']);

    lmIdx1 = importdata([dataRoot 'landmark1/' num2str(idx) '.txt']);
    lmIdx2 = importdata([dataRoot 'landmark2/' num2str(idx) '.txt']);

    pts1= model.p(:, lmIdx1);
    pts2= model.p(:, lmIdx2);

    dist(i, :) = dot(pts1 - pts2, pts1 - pts2);
end

save([resultRoot 'dist.mat'], 'dist');

