function DF = OptFFD(modelP, modelQ, threshold)

    if nargin < 3
        threshold = 0;
    end
    p = modelP.p;
    q = modelQ.p;

    pArray = SampleMatrix(p, 100);
    qArray = SampleMatrix(q, 100);

    g = 8;

    global preCompStruct;
    preCompStruct = struct();
    PreCompute(g);

    % grid num g, current control point curCP
    orgCP = CalcCtrlPt(pArray, g);
    pBsCoeff = CalcBSCoeff(pArray, g, orgCP);
    preCompStruct.orgCP = orgCP;
    preCompStruct.pBsCoeff = pBsCoeff;

    rotM = cell((g+1)^3, 1);
    for index = 1: (g+1)^3
        rotM{index} = eye(3);
    end

    orgRotM = rotM;
    curCP = preCompStruct.orgCP;
    % iterative optimization
    lim = [-25 200];
    % DrawPoint(prefix, pArray, qArray, 0, lim, orgCP);
    maxIter = 50;
    iter = 0;
    preloss = 0;
    lossCurve = zeros(3, maxIter);
    while iter < maxIter
        % calcualte target control points

        [dstCP, loss] = CalcDstCP(curCP, pArray, qArray, rotM, 0.1);
        lossCurve(:, iter + 1) = loss;
        curCP = dstCP;
        % transform current control points in a as-rigid-as-possible way
        rotM = CalcTransCP(orgCP, dstCP);

        Y = FFD(pBsCoeff, curCP);
        % DrawPoint(prefix, Y, qArray, iter, lim, dstCP);

        if iter > 5 && preloss - loss(1) < threshold
            break;
        end
        preloss = loss(1);
        iter = iter + 1;
    end

    % GenerateGif(prefix, iter-1, 10);
    % save('loss.mat', 'lossCurve');

    DF = struct();
    DF.method = 'FFD';
    DF.g = g;
    DF.orgCP = orgCP;
    DF.dstCP = dstCP;
    fprintf('\t FFD MaxIter %d\n', iter);
end
