global config;
config = GenConfig();

modelIDs = config.modelIDs;
numP = length(modelIDs);

healthyRoot = config.healthyRoot;
resultRoot = config.resultRoot;

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

lambdaToSearch = { [0.1, 0.1],
                   [0.1, 1],
                   [0.1, 10],
                   [1, 0.1],
                   [1, 1],
                   [1, 10],
                   [10, 1],
                   [10, 10]
                };

for refIdx = 1:length(refModels)

    refObj = refModels(refIdx);

    subDir = [resultRoot num2str(refObj) '/'];
    if isdir(subDir)
        fprintf('skipping %d\n', refObj);
        continue;
    end

    mkdir(subDir);

%    ffdDFS = zeros(numP, 729 * 3);
%    ffdDist = zeros(numP, 2);
%    for dstIdx = 1:length(modelIDs)
%        dstObj = modelIDs(dstIdx);
%        fprintf('FFD Processing ref: %d -> %d\n', refObj, dstObj);

%        modelP = load([healthyRoot 'mat/' num2str(refObj) '.mat']);
%        modelQ = load([healthyRoot 'mat/' num2str(dstObj) '.mat']);

%       fPtsP = load([healthyRoot 'landmark/' num2str(refObj) '.mat']);
%        fPtsQ = load([healthyRoot 'landmark/' num2str(refObj) '.mat']);
%        fPtsP = fPtsP.fPts;
%        fPtsQ = fPtsQ.fPts;

%        trainFPtsP = fPtsP(:, trainIdx);
%        testFPtsP = fPtsP(:, testIdx);
%        trainFPtsQ = fPtsQ(:, trainIdx);
%        testFPtsQ = fPtsQ(:, testIdx);

%        modelP.fPts = trainFPtsP;
%        modelQ.fPts = trainFPtsQ;

%        ffdDF = OptFFD(modelP, modelQ);

%        ffdTrainFPtsP = Deform(ffdDF, trainFPtsP);
%        ffdTestFPtsP = Deform(ffdDF, testFPtsP);

%        ffdDFS(dstIdx, :) = ffdDF.dstCP(:);
%        ffdDist(dstIdx, 1) = mean(dot(trainFPtsQ- ffdTrainFPtsP, trainFPtsQ - ffdTrainFPtsP));
%        ffdDist(dstIdx, 2) = mean(dot(testFPtsQ - ffdTestFPtsP, testFPtsQ - ffdTestFPtsP));
%    end
%    save([subDir 'ffd.mat'], 'ffdDFS', 'ffdDist');


    for pairIdx = 1:size(pairToSearch, 1)
        for lambdaIdx = 1:length(lambdaToSearch)
            trainIdx = pairToSearch{pairIdx, 1};
            testIdx = pairToSearch{pairIdx, 2};
            lambda = lambdaToSearch{lambdaIdx};

            guidedDFS = zeros(numP, 729 * 3);
            guidedDist = zeros(numP, 2);
            for dstIdx = 1:length(modelIDs)
                dstObj = modelIDs(dstIdx);
                fprintf('Processing ref: %d -> %d, pair: %f, lambda1: %f, lambda2: %f\n', ...
                        refObj, dstObj, pairIdx, lambda(1), lambda(2));

                modelP = load([healthyRoot 'mat/' num2str(refObj) '.mat']);
                modelQ = load([healthyRoot 'mat/' num2str(dstObj) '.mat']);

                fPtsP = load([healthyRoot 'landmark/' num2str(refObj) '.mat']);
                fPtsQ = load([healthyRoot 'landmark/' num2str(refObj) '.mat']);
                fPtsP = fPtsP.fPts;
                fPtsQ = fPtsQ.fPts;

                trainFPtsP = fPtsP(:, trainIdx);
                testFPtsP = fPtsP(:, testIdx);
                trainFPtsQ = fPtsQ(:, trainIdx);
                testFPtsQ = fPtsQ(:, testIdx);

                modelP.fPts = trainFPtsP;
                modelQ.fPts = trainFPtsQ;

                guidedDF = GuidedFFD(modelP, modelQ, lambda(1), lambda(2));

                guidedTestFPtsP = Deform(guidedDF, testFPtsP);

                guidedDFS(dstIdx, :) = guidedDF.dstCP(:);
                guidedDist(dstIdx, 1) = guidedDF.trainningLoss;
                guidedDist(dstIdx, 1) = mean(dot(testFPtsQ - guidedTestFPtsP, testFPtsQ - guidedTestFPtsP));
            end
            save([subDir 'guided' num2str(pairIdx) '-' num2str(lambdaIdx) '.mat'], 'guidedDFS', 'guidedDist');
 
        end
    end

end

