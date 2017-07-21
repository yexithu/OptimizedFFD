function [pPoints, qPoints, err, meanErr] = Evaluate(pPath, qPath, pArray, qArray)
    pIdx = importdata(pPath);
    qIdx = importdata(qPath);
    pPoints = pArray(:, pIdx);
    qPoints = qArray(:, qIdx);
    err = pPoints - pPoints;
    err = err.^2;
    err = sum(err, 1);
    meanErr = mean(err);
end