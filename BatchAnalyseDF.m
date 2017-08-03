global config;
config = GenConfig();

modelIDs = config.modelIDs;
numP = length(modelIDs);
p = (config.numGrid + 1)^3;

healthyRoot = config.healthyRoot;
resultRoot = config.resultRoot;

trainIdx = config.trainIdx;
testIdx = config.testIdx;

nTrain = length(trainIdx);
nTest = length(testIdx);

ffdError = zeros(numP, 1);
guidedError = zeros(numP, 1);
propRate = zeros(numP, 1);

for refIdx = 1:numP
    fprintf('processing %d\n', refIdx);
    refObj = modelIDs(refIdx);

    subDir = [resultRoot num2str(refObj) '/'];

    ffdInfo = load([subDir 'ffd.mat']);
    guidedInfo = load([subDir 'guided.mat']);

    numQ = size(ffdInfo.ffdDFS, 1);

    ffdOrg = ffdInfo.ffdDFS(refIdx, :);
    ffdOrg = reshape(ffdOrg, 3, p);
    guidedOrg = guidedInfo.guidedDFS(refIdx, :);
    guidedOrg = reshape(guidedOrg, 3, p);

    ffdError(refIdx) = mean(ffdInfo.ffdDist(:, 2));
    guidedError(refIdx) = mean(guidedInfo.guidedDist(:,2));
    propRate(refIdx) = sum(guidedInfo.guidedDist(:, 2) <= ffdInfo.ffdDist(:, 2) ) / numQ;


%        if ffdInfo.ffdDist(dstIdx, 2) < guidedInfo.guidedDist(dstIdx, 2)
%            ffdInfo.ffdDist(dstIdx, 2)
%            guidedInfo.guidedDist(dstIdx, 2)
%            pause;
%        end

    ffdSpace = zeros(numQ, 3 * p);
    guidedSpace = zeros(numQ, 3 * p);

    for dstIdx = 1:numQ
        ffdDst = ffdInfo.ffdDFS(dstIdx, :);
        ffdDst = reshape(ffdDst, 3, p);
        guidedDst = guidedInfo.guidedDFS(dstIdx, :);
        guidedDst = reshape(guidedDst, 3, p);
        % Y align to X
        [ffdR, ffdT] = AbsOrient(ffdDst, ffdOrg, 1);
        [guidedR, guidedT] = AbsOrient(guidedDst, guidedOrg, 1);

        ffdDiff = ffdR * ffdDst + ffdT * ones(1, p) - ffdOrg;
        guidedDiff = guidedR * guidedDst + guidedT * ones(1, p) - guidedOrg;

        ffdSpace(dstIdx, :) = ffdDiff(:);
        guidedSpace(dstIdx, :) = guidedDiff(:);
    end

    save([subDir 'space.mat'], 'ffdSpace', 'guidedSpace');
end

save([resultRoot 'error.mat'], 'ffdError', 'guidedError', 'propRate');
