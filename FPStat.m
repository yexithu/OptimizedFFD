
global config;
config = GenConfig();

modelIDs = config.modelIDs;
m = length(modelIDs);

healthyRoot = config.healthyRoot;
resultRoot = config.resultRoot;

% dist = zeros(m, 37);

% for i = 1:m

%     idx = modelIDs(i);
%     model = load([healthyRoot 'mat/' num2str(idx) '.mat']);

%     lmIdx1 = importdata([healthyRoot 'landmark1/' num2str(idx) '.txt']);
%     lmIdx2 = importdata([healthyRoot 'landmark2/' num2str(idx) '.txt']);

%     pts1= model.p(:, lmIdx1);
%     pts2= model.p(:, lmIdx2);

%     dist(i, :) = dot(pts1 - pts2, pts1 - pts2);
% end
% save('dist.mat', 'dist');
dist = load('dist.mat');
dist = dist.dist;

goodIdx = [2, 3, 4, 5, 6, 7, 8, 14, 15, 17, 18, 19, 20, 21, 22, 23, 28, 29, 31, 32, 33, 34, 35, 36, 37];
mu = mean(dist, 1);
sigma = std(dist);
upper = mu + 3 * sigma;
toVerify = dist > ones(91, 1) * upper;
toVerify = toVerify(:, goodIdx);
for i = 1: length(modelIDs)
    if sum(toVerify(i, :) > 0)
        fprintf('%d\n', modelIDs(i));

        idx = modelIDs(i);
        model = load([healthyRoot 'mat/' num2str(idx) '.mat']);

        lmIdx1 = importdata([healthyRoot 'landmark1/' num2str(idx) '.txt']);
        lmIdx2 = importdata([healthyRoot 'landmark2/' num2str(idx) '.txt']);

        pts1= model.p(:, lmIdx1);
        pts2= model.p(:, lmIdx2);

        for j = 1:length(goodIdx)
            if (toVerify(i, j) > 0)
                fprintf('\t%d\n', goodIdx(j));
                pts1(:, goodIdx(j))
                pts2(:, goodIdx(j))
            end
        end
        fprintf('\n');
        pause;
    end
end

