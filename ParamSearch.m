dataRoot = '/h2/yexi/Desktop/data/healthy/';
resultRoot = '/h2/yexi/Desktop/result/';

rng(123);

availableIdx = [1:1:5];
availableIdx(availableIdx == 1) = [];
availableIdx(availableIdx == 10) = [];
availableIdx(availableIdx == 74) = [];

numP = length(availableIdx);

% tested
% refModels = [3, 8, 13, 16, 17, 32, 36, 39, 49, 54];
refModels = [3, 8];

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

for pairIdx = 1:size(pairToSearch, 1)
    for lambdaIdx = 1:length(lambdaToSearch)

        trainIdx = pairToSearch{pairIdx, 1};
        testIdx = pairToSearch{pairIdx, 2};
        lambda = lambdaToSearch(lambdaIdx);

        subDir = [resultRoot num2str(pairIdx) '-' num2str(lambda) '/'];
        if isdir(subDir)
            rmdir(subDir, 's');
        end
        mkdir(subDir);


        for refIdx = 1:length(refModels)
            refObj = refModels(refIdx);
             ffdDFS = zeros(numP, 729 * 3);
            ffdDist = zeros(numP, 2);
            guidedDFS = zeros(numP, 729 * 3);
            guidedDist = zeros(numP, 2);

            for dstIdx = 1:length(availableIdx)
                dstObj = availableIdx(dstIdx);
                fprintf('Processing pair: %d, lambda: %f, %d -> %d\n', pairIdx, lambda, refObj, dstObj);

                modelP = load([dataRoot 'mat/' num2str(refObj) '.mat']);
                modelQ = load([dataRoot 'mat/' num2str(dstObj) '.mat']);

                fPtsIdxP = importdata([dataRoot 'landmark1/' num2str(refObj) '.txt']);
                fPtsIdxQ = importdata([dataRoot 'landmark1/' num2str(dstObj) '.txt']);

                fPtsP = modelP.p(:, fPtsIdxP);
                fPtsQ = modelQ.p(:, fPtsIdxQ);

                trainFPtsP = fPtsP(:, trainIdx);
                testFPtsP = fPtsP(:, testIdx);
                trainFPtsQ = fPtsQ(:, trainIdx);
                testFPtsQ = fPtsQ(:, testIdx);

                modelP.fPts = trainFPtsP;
                modelQ.fPts = trainFPtsQ;

                guidedDF = GuidedFFD(modelP, modelQ, lambda);
                ffdDF = OptFFD(modelP, modelQ);

                guidedTestFPtsP = Deform(guidedDF, testFPtsP);
                ffdTestFPtsP = Deform(ffdDF, testFPtsP);

                ffdDFS(dstIdx, :) = ffdDF.dstCP(:);
                guidedDFS(dstIdx, :) = guidedDF.dstCP(:);

                ffdDist(dstIdx, 1) = mean(dot(testFPtsQ - ffdTestFPtsP, testFPtsQ - ffdTestFPtsP));
                ffdDist(dstIdx, 2) = ffdDF.closeLoss;
                guidedDist(dstIdx, 1) = mean(dot(testFPtsQ - guidedTestFPtsP, testFPtsQ - guidedTestFPtsP));
                guidedDist(dstIdx, 2) = guidedDF.closeLoss;
            end
            save([subDir num2str(refObj) '.mat'], 'guidedDFS', 'ffdDFS', 'guidedDist', 'ffdDist');
        end
    end
end



