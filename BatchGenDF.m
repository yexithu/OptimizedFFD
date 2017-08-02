global config;
config = GenConfig();

modelIDs = config.modelIDs;
numP = length(modelIDs);

healthyRoot = config.healthyRoot;
resultRoot = config.resultRoot;

trainIdx = config.trainIdx;
testIdx = config.testIdx;

nTrain = length(trainIdx);
nTest = length(testIdx);

for refIdx = 1:numP
    refObj = modelIDs(refIdx);

    subDir = [resultRoot num2str(refObj) '/'];
    if isdir(subDir)
        fprintf('skipping %d\n', refObj);
        continue;
    end
    mkdir(subDir);

    ffdDFS = zeros(numP, 729 * 3);
    ffdDist = zeros(numP, 3);
    guidedDFS = zeros(numP, 729 * 3);
    guidedDist = zeros(numP, 3);

    for dstIdx = 1:numP
        dstObj = modelIDs(dstIdx);

        fprintf('Processing: %d -> %d\n', refObj, dstObj);
        modelP = load([healthyRoot 'mat/' num2str(refObj) '.mat']);
        modelQ = load([healthyRoot 'mat/' num2str(dstObj) '.mat']);
        fPtsP = load([healthyRoot 'landmark/' num2str(refObj) '.mat']);
        fPtsQ = load([healthyRoot 'landmark/' num2str(dstObj) '.mat']);
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

        ffdDFS(dstIdx, :) = ffdDF.dstCP(:);
        ffdDist(dstIdx, 1) = mean(dot(trainFPtsQ- ffdTrainFPtsP, trainFPtsQ - ffdTrainFPtsP));
        ffdDist(dstIdx, 2) = mean(dot(testFPtsQ - ffdTestFPtsP, testFPtsQ - ffdTestFPtsP));
        fprintf('\tFFD test error: %f\n', ffdDist(dstIdx, 2));

        guidedDF = GuidedFFD(modelP, modelQ);
        guidedTestFPtsP = Deform(guidedDF, testFPtsP);

        guidedDFS(dstIdx, :) = guidedDF.dstCP(:);
        guidedDist(dstIdx, 1) = guidedDF.trainningLoss;
        guidedDist(dstIdx, 2) = mean(dot(testFPtsQ - guidedTestFPtsP, testFPtsQ - guidedTestFPtsP));
        fprintf('\tGuided test error: %f\n', guidedDist(dstIdx, 2));
    end
    ffdDist(:, 3) =  (nTrain * ffdDist(:, 1) +  nTest * ffdDist(:, 2)) / (nTrain + nTest);
    guidedDist(:, 3) = (nTrain * guidedDist(:, 1) + nTest * guidedDist(:, 2)) / (nTrain + nTest);

    save([subDir 'ffd.mat'], 'ffdDFS', 'ffdDist');
    save([subDir 'guided.mat'], 'guidedDFS', 'guidedDist');
end
