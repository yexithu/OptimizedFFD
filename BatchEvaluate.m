dataRoot = '/h2/yexi/Desktop/data/healthy/';
resultRoot = '/h2/yexi/Desktop/result/';

rng(233);

minIdx = 1;
maxIdx = 94;

testPair = 1;
testIdx = 0;

initDist = zeros(testPair, 39);
icpDist = zeros(testPair, 39);
ffdDist = zeros(testPair, 39);

while testIdx < testPair
    orgIdx = randi([minIdx, maxIdx]);
    dstIdx = randi([minIdx, maxIdx]);

    modelP = load([dataRoot 'mat/' num2str(orgIdx) '.mat']);
    modelQ = load([dataRoot 'mat/' num2str(dstIdx) '.mat']);

    fPtsIdxP = importdata([dataRoot 'landmark/' num2str(orgIdx) '.txt']);
    fPtsIdxQ = importdata([dataRoot 'landmark/' num2str(dstIdx) '.txt']);

    fPtsP = modelP.p(:, fPtsIdxP);
    fPtsQ = modelQ.p(:, fPtsIdxQ);

    DFICP = ICP(modelP, modelQ);
    % DFFFD = OptFFD(modelP, modelQ);

    icpPts = Deform(DFICP, fPtsP);
    % ffdPts = Deform(DFFFD, fPtsP);

    initDist(testIdx + 1, 1:2) = [orgIdx, dstIdx];
    icpDist(testIdx + 1, 1:2) = [orgIdx, dstIdx];
    % ffdDist(testIdx + 1, 1:2) = [orgIdx, dstIdx];

    initDist(testIdx + 1, 3:end) = dot(fPtsQ - fPtsP, fPtsQ - fPtsP);
    icpDist(testIdx + 1, 3:end) = dot(fPtsQ - icpPts, fPtsP - icpPts);
    % ffdDist(testIdx + 1, 3:end) = dot(fPtsQ - ffdPts, fPtsP - ffdPts);

    testIdx = testIdx + 1;
end


csvwrite([resultRoot 'init.csv'], initDist);
csvwrite([icpRoot 'icp.csv'], icpDist);
% csvwrite([resultRoot 'ffd.csv'], ffdDist);

