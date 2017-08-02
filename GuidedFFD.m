function DF = GuidedFFD(modelP, modelQ, gamma1, gamma2, maxIter, threshold)

    vis = false;
    prefix = './guided/';
    if vis
        if isdir(prefix)
            rmdir(prefix ,'s');
        end
        mkdir(prefix);
    end
    if nargin < 4
        gamma1 = 2;
        gamma2 = 2;
    end
    if nargin < 5
        maxIter = 100;
    end
    if nargin < 6
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

    [curCP, rotM] = InitCPRotM(modelP.fPts, modelQ.fPts, orgCP);
    % iterative optimization
    lim = [-25 200];

    if vis
        Y = FFD(pBsCoeff, curCP);
        DrawPoint(prefix, Y, qArray, 0, lim, curCP);
    end

    iter = 0;
    preloss = 0;
    lossCurve = zeros(4, maxIter);

    CalcGuidedDstCP();
    while iter < maxIter
        % calcualte target control points
        lambda1 = 0.1 + 0.9 * (1 - iter / maxIter) ^ gamma1;
        lambda2 = 0.1 + 0.9 * (iter / maxIter) ^ gamma2;
        [dstCP, loss] = CalcGuidedDstCP(lambda1, lambda2, curCP, pArray, qArray, rotM);
        lossCurve(:, iter + 1) = loss;        
        curCP = dstCP;
        % transform current control points in a as-rigid-as-possible way
        rotM = CalcTransCP(orgCP, dstCP);

        if vis
            Y = FFD(pBsCoeff, curCP);
            DrawPoint(prefix, Y, qArray, iter, lim, curCP);
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
    DF.trainningLoss = loss(end);
    fprintf('\t GuiedeFFD MaxIter %d\n', iter);
end
