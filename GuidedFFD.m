function DF = GuidedFFD(modelP, modelQ, lambda1, lambda2, threshold)

    vis = false;
    prefix = './guided/';

    if nargin < 5
        threshold = 0.001;
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
    fpBsCoeff = CalcBSCoeff(modelP.fPts, g, orgCP);
    preCompStruct.orgCP = orgCP;
    preCompStruct.pBsCoeff = pBsCoeff;
    preCompStruct.fpBsCoeff = fpBsCoeff;
    preCompStruct.fqPts = modelQ.fPts;

    rotM = cell((g+1)^3, 1);
    for index = 1: (g+1)^3
        rotM{index} = eye(3);
    end

    orgRotM = rotM;
    curCP = preCompStruct.orgCP;
    % iterative optimization
    lim = [-25 200];

    if vis
        DrawPoint(prefix, pArray, qArray, 0, lim, orgCP);
    end

    maxIter = 200;
    iter = 0;
    preloss = 0;
    lossCurve = zeros(4, maxIter);

    CalcGuidedDstCP(lambda1, lambda2);
    while iter < maxIter
        % calcualte target control points

        [dstCP, loss] = CalcGuidedDstCP(lambda1, lambda2, curCP, pArray, qArray, rotM);
        lossCurve(:, iter + 1) = loss;
        curCP = dstCP;
        % transform current control points in a as-rigid-as-possible way
        rotM = CalcTransCP(orgCP, dstCP);

        Y = FFD(pBsCoeff, curCP);
        if vis
            DrawPoint(prefix, Y, qArray, iter, lim, dstCP);
        end

        if iter > 5 && preloss - loss(end) < threshold
            break;
        end
        preloss = loss(end);
        iter = iter + 1;
    end

    if vis
        GenerateGif(prefix, iter-1, 10);
    end
    % save('loss.mat', 'lossCurve');

    DF = struct();
    DF.method = 'FFD';
    DF.g = g;
    DF.orgCP = orgCP;
    DF.dstCP = dstCP;
    DF.trainningLoss = loss(3);
    fprintf('\t GuiedeFFD MaxIter %d\n', iter);
end
