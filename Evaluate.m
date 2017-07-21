function [err, meanErr] = EvaluateEuclid(pPoints, qPoints)
    err = pPoints - qPoints;
    err = err.^2;
    err = sum(err, 1);
    meanErr = mean(err);
end