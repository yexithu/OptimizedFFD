global config;
config = GenConfig();

modelIDs = config.modelIDs;
numP = length(modelIDs);
p = (config.numGrid + 1)^3;

healthyRoot = config.healthyRoot;
resultRoot = config.resultRoot;
rank = 40;

for refIdx = 1:numP
    fprintf('processing %d\n', refIdx);
    refObj = modelIDs(refIdx);

    subDir = [resultRoot num2str(refObj) '/'];
    spaceInfo = load([subDir 'space.mat']);

    ffdSp = spaceInfo.ffdSpace;
    guidedSp = spaceInfo.guidedSpace;

    [~, ffdS, ~] = svd(ffdSp);
    ffdS = diag(ffdS);
    ffdS = ffdS / sum(ffdS);
    [~,guidedS, ~] = svd(guidedSp);
    guidedS = diag(guidedS);
    guidedS = guidedS / sum(guidedS);

    plot(ffdS, 'red');
    hold on;
    plot(guidedS, 'blue');
    title(sprintf('FFD: %f, Guided: %f', sum(ffdS(1:rank)), sum(guidedS(1:rank))));
    hold off;

    Y = ffdSp';
    X = guidedSp';

    U = linsolve(X, Y);
    diff = Y - X * U;
    sinVal =sqrt(sumsqr(diff) / sumsqr(Y));
    angle = asin(sinVal) / pi * 180;
    fprintf('diff: %f, angle: %f\n', sinVal, angle);
    pause;
end

