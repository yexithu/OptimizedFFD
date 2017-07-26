function [pMean, qMean, pCArray, qCArray] = Centralization(pAry, qAry)

    % p, q: m * n matrix
    pMean = mean(pAry, 2);
    qMean = mean(qAry, 2);
    
    m = size(pAry, 2);

    pCArray = pAry - pMean * ones(1, m);
    qCArray = qAry - qMean * ones(1, m);
end
