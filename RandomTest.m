
global config;
config = GenConfig();

modelIDs = config.modelIDs;
numP = length(modelIDs);

healthyRoot = config.healthyRoot;
resultRoot = config.resultRoot;

% tested
%refModels = [3, 8, 13, 16, 17, 32, 36, 39, 49, 54];

% good point 2, 3, 4, 5, 6, 7, 8
% good pair 14, 15, 17, 18, 19, 20, 21, 22, 23
%           28, 29, 31, 32, 33, 34, 35, 36, 37
% bad point 1, 9 bad pair (10, 24), (11, 25), (12, 26), (13, 27), (16, 30)

% trainIdx = [2, 4, 8, 14, 28, 17, 31, 18, 32, 22, 36];
% testIdx = [3, 5, 6, 7, 15, 29, 19, 33, 20, 34, 21, 35, 23, 37];
pairToSearch = {[2, 4, 8, 14, 28, 17, 31, 18, 32, 22, 36], [3, 5, 6, 7, 15, 29, 19, 33, 20, 34, 21, 35, 23, 37]; ...
                [2, 5, 8, 14, 28, 17, 31, 18, 32, 22, 36], [3, 4, 6, 7, 15, 29, 19, 33, 20, 24, 21, 35, 23, 37]; ...
                [2, 5, 8, 15, 29, 18, 32, 21, 35, 22, 36], [3, 4, 6, 7, 14, 28, 17, 31, 19, 33, 20, 34, 23, 37]};

lambdaToSearch = {
                   [0.1, 0.1],
                   [1, 1],
                   [10, 10]
                   [0.1, 1],
                   [1, 10],
                   [1, 0.1],
                   [10, 1],
                   [0.1, 10],
                   [10, 0.1]
                };

rng(123);
testPair = 100;
tIdx = 0;

m = length(modelIDs);

pairIdx = 1;
trainIdx = pairToSearch{pairIdx, 1};
testIdx = pairToSearch{pairIdx, 2};

nTrain = length(trainIdx);
nTest = length(testIdx);
ffdTrainMat = zeros(testPair, 1);
ffdTestMat = zeros(testPair, 1);

guidedTrainMat = zeros(testPair, 8);
guidedTestMat = zeros(testPair, 8);

while tIdx < testPair
    orgIdx = modelIDs(randi(m));
    dstIdx = modelIDs(randi(m));
    if orgIdx == dstIdx
        continue;
    end

    modelP = load([healthyRoot 'mat/' num2str(orgIdx) '.mat']);
    modelQ = load([healthyRoot 'mat/' num2str(dstIdx) '.mat']);
    fPtsP = load([healthyRoot 'landmark/' num2str(orgIdx) '.mat']);
    fPtsQ = load([healthyRoot 'landmark/' num2str(dstIdx) '.mat']);
    fPtsP = fPtsP.fPts;
    fPtsQ = fPtsQ.fPts;

    trainFPtsP = fPtsP(:, trainIdx);
    testFPtsP = fPtsP(:, testIdx);
    trainFPtsQ = fPtsQ(:, trainIdx);
    testFPtsQ = fPtsQ(:, testIdx);

    modelP.fPts = trainFPtsP;
    modelQ.fPts = trainFPtsQ;

    ffdDF = OptFFD(modelP, modelQ);
    ffdTrainFPtsP = Deform(ffdDF, trainFPtsP);
    ffdTestFPtsP = Deform(ffdDF, testFPtsP);
    ffdTrainMat(tIdx + 1, 1) = mean(dot(trainFPtsQ - ffdTrainFPtsP, trainFPtsQ - ffdTrainFPtsP));
    ffdTestMat(tIdx + 1, 1) = mean(dot(testFPtsQ - ffdTestFPtsP, testFPtsQ - ffdTestFPtsP));
    for lambdaIdx = 1:length(lambdaToSearch)
        fprintf('Evaluating %d, %d->%d, lambda: %d\n', tIdx, orgIdx, dstIdx, lambdaIdx);
        lambda = lambdaToSearch{lambdaIdx};
        guidedDF = GuidedFFD(modelP, modelQ, lambda(1), lambda(2));
        guidedTestFPtsP = Deform(guidedDF, testFPtsP);
        guidedTrainMat(tIdx + 1, lambdaIdx) = guidedDF.trainningLoss;
        guidedTestMat(tIdx + 1, lambdaIdx) = mean(dot(testFPtsQ - guidedTestFPtsP, testFPtsQ - guidedTestFPtsP));
    end
    tIdx = tIdx + 1;
end

trainMat = [ffdTrainMat guidedTrainMat];
testMat = [ffdTestMat guidedTestMat];
allMat = (nTrain * trainMat + nTest * testMat) / (nTrain + nTest);
save('tmp.mat', 'trainMat', 'testMat', 'allMat');

