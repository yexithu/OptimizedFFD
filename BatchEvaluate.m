dataRoot = '/h2/yexi/Desktop/data/healthy/';
resultRoot = '/h2/yexi/Desktop/result/';

rng(123);

testPair = 500;
testIdx = 0;

availableIdx = [1:1:94];
availableIdx(availableIdx == 1) = [];
availableIdx(availableIdx == 10) = [];
availableIdx(availableIdx == 74) = [];

initDist = zeros(testPair, 39);
icpDist = zeros(testPair, 39);
ffdDist = zeros(testPair, 39);

m = length(availableIdx);

while testIdx < testPair
    fprintf('Evaluating %d\n', testIdx);
    orgIdx = availableIdx(randi(m));
    dstIdx = availableIdx(randi(m));
    if orgIdx == dstIdx
        continue;
    end

    modelP = load([dataRoot 'mat/' num2str(orgIdx) '.mat']);
    modelQ = load([dataRoot 'mat/' num2str(dstIdx) '.mat']);

    fPtsIdxP = importdata([dataRoot 'landmark/' num2str(orgIdx) '.txt']);
    fPtsIdxQ = importdata([dataRoot 'landmark/' num2str(dstIdx) '.txt']);

    fPtsP = modelP.p(:, fPtsIdxP);
    fPtsQ = modelQ.p(:, fPtsIdxQ);

    DFICP = ICP(modelP, modelQ);
    DFFFD = OptFFD(modelP, modelQ);

    icpPts = Deform(DFICP, fPtsP);
    ffdPts = Deform(DFFFD, fPtsP);

    initDist(testIdx + 1, 1:2) = [orgIdx, dstIdx];
    icpDist(testIdx + 1, 1:2) = [orgIdx, dstIdx];
    ffdDist(testIdx + 1, 1:2) = [orgIdx, dstIdx];

    initDist(testIdx + 1, 3:end) = dot(fPtsQ - fPtsP, fPtsQ - fPtsP);
    icpDist(testIdx + 1, 3:end) = dot(fPtsQ - icpPts, fPtsQ - icpPts);
    ffdDist(testIdx + 1, 3:end) = dot(fPtsQ - ffdPts, fPtsQ - ffdPts);

    testIdx = testIdx + 1;
end


csvwrite([resultRoot 'init500.csv'], initDist);
csvwrite([resultRoot 'icp500.csv'], icpDist);
csvwrite([resultRoot 'ffd500.csv'], ffdDist);

