function DeformationField = ICP(modelP, modelQ, thershold)
    if nargin < 3
        thershold = 0;
    end
    
    DeformationField = struct();
    DeformationField.method = 'ICP';
    p = modelP.p;
    q = modelQ.p;
    pArray = SampleMatrix(p, 100);
    qArray = SampleMatrix(q, 100);

    max_iter = 50;
    k = 0;
    preErr = 0;

    while k < max_iter
        [idx, dist] = knnsearch(qArray', pArray');
        cArray = qArray(:,idx);
        [p0, q0, pCArray, qCArray] = Centralization(pArray, cArray);
        [~, N] = CalcSumProd(pCArray, qCArray);

        [~, r, ~] = CalcQuat(N);
        [s, t] = CalcScaleTrans(pCArray, qCArray, p0, q0, r);

        pArray = s * r * pArray + t * ones(1, length(cArray));
        err = mean(dist.^2);
%         fprintf('err: %f\n', err); 
        k = k + 1;
        if k > 1 && preErr - err < thershold
            break;
        end
        preErr = err;
    end
    fprintf('\t ICP MaxIter %d\n', k);
    DeformationField.R = r;
    DeformationField.S = s;
    DeformationField.T = t;
end

