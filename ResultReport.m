dataRoot = '/h2/yexi/Desktop/data/healthy/';
resultRoot = '/h2/yexi/Desktop/result/';

rng(123);

availableIdx = [1:1:5];
availableIdx(availableIdx == 1) = [];
availableIdx(availableIdx == 10) = [];
availableIdx(availableIdx == 74) = [];

numP = length(availableIdx);

% tested
refModels = [3, 8, 13, 16, 17, 32, 36, 39, 49, 54];
% refModels = [3, 8];

% good point 2, 3, 4, 5, 6, 7, 8
% good pair 14, 15, 17, 18, 19, 20, 21, 22, 23
%           28, 29, 31, 32, 33, 34, 35, 36, 37
% bad point 1, 9 bad pair (10, 24), (11, 25), (12, 26), (13, 27), (16, 30)

% trainIdx = [2, 4, 8, 14, 28, 17, 31, 18, 32, 22, 36];
% testIdx = [3, 5, 6, 7, 15, 29, 19, 33, 20, 34, 21, 35, 23, 37];

pairToSearch = {[2, 4, 8, 14, 28, 17, 31, 18, 32, 22, 36], [3, 5, 6, 7, 15, 29, 19, 33, 20, 34, 21, 35, 23, 37]; ...
                [2, 5, 8, 14, 28, 17, 31, 18, 32, 22, 36], [3, 4, 6, 7, 15, 29, 19, 33, 20, 24, 21, 35, 23, 37]; ...
                [2, 5, 8, 15, 29, 18, 32, 21, 35, 22, 36], [3, 4, 6, 7, 14, 28, 17, 31, 19, 33, 20, 34, 23, 37]};

lambdaToSearch = [0.1, 1, 10];

mapSize = [size(pairToSearch, 1), length(lambdaToSearch)];
guidedFpErrorMap = zeros(mapSize);
guidedCloseErrorMap = zeros(mapSize);
ffdFpErrorMap = zeros(mapSize);
ffdCloseErrorMap = zeros(mapSize);
fpCountMap = zeros(mapSize);

for pairIdx = 1:size(pairToSearch, 1)
    for lambdaIdx = 1:length(lambdaToSearch)

        trainIdx = pairToSearch{pairIdx, 1};
        testIdx = pairToSearch{pairIdx, 2};
        lambda = lambdaToSearch(lambdaIdx);
        subDir = [resultRoot num2str(pairIdx) '-' num2str(lambda) '/'];

        guidedFpError = 0;
        guidedCloseError = 0;
        ffdFpError = 0;
        ffdCloseError = 0;
        fpCount = 0;
        n = 0;

        for refIdx = 1:length(refModels)
            refObj = refModels(refIdx);
            % save([subDir num2str(refObj) '.mat'], 'guidedDFS', 'ffdDFS', 'guidedDist', 'ffdDist');
            temp = load([subDir num2str(refObj) '.mat']);
            n = n + size(temp.ffdDist, 1);
            temp.guidedDist(:, 1)
            temp.ffdDist(:, 1)
            guidedFpError = guidedFpError + sum(temp.guidedDist(:, 1));
            guidedCloseError = guidedCloseError + sum(temp.guidedDist(:, 2));
            ffdFpError = ffdFpError + sum(temp.ffdDist(:, 1));
            ffdCloseError = ffdCloseError + sum(temp.ffdDist(:, 2));
            fpCount = fpCount + sum(temp.guidedDist(:, 1) <= temp.ffdDist(:, 1));
            % pause;
        end

        guidedFpErrorMap(pairIdx, lambdaIdx) = guidedFpError / n;
        guidedCloseErrorMap(pairIdx, lambdaIdx) = guidedCloseError / n;
        ffdFpErrorMap(pairIdx, lambdaIdx) = ffdFpError / n;
        ffdCloseErrorMap(pairIdx, lambdaIdx) = ffdCloseError / n;
        fpCountMap(pairIdx, lambdaIdx) = fpCount / n;
    end
end
guidedFpErrorMap
guidedCloseErrorMap
ffdFpErrorMap
ffdCloseErrorMap
fpCountMap
