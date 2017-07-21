clear;
global preCompStruct;

maxNum = 50;
h_obj_id = [11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 2, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 3, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 4, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 5, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 6, 70, 71, 72, 73, 75, 76, 77, 78, 79, 7, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 8, 90, 91, 92, 93, 94, 9];
i_obj_id = [2,3];
for i = 1:maxNum
    pId = randsample(h_obj_id);
    qId = randsample(h_obj_id);
    
    while qId == pId
        qId = randsample(h_obj_id);
    end
    if mod(i,5) == 0
        qId = randsample(i_obj_id);
    end
    
    pId = int2str(pId); 
    qId = int2str(qId);
    
    p = load(['../mesh_data/mat/p' pId '.mat'], p);
    pTxt = ['../mesh_data/healthy_id/p' pId '.txt'];
    qTxt = ['../mesh_data/healthy_id/p' qId '.txt'];
    if mod(i,5) == 0
        qTxt = ['../mesh_data/injured_id/q' qId '.txt'];
        q = load(['../mesh_data/mat/q' qId '.mat'], p);
    else
        q = load(['../mesh_data/mat/p' qId '.mat'], p);
    end
    
    p = p';
    q = q';
    % p source vertices , q target vertices
    % pArray, qArray sample points
    pArray = SampleMatrix(p, 100);
    qArray = SampleMatrix(q, 100);
    g = 8;
    preCompStruct = struct();
    PreCompute(g);

    % grid num g, current control point curCP
    [orgCP, pBsCoeff] = CalcCtrlPt(pArray, g);
    preCompStruct.orgCP = orgCP;
    preCompStruct.pBsCoeff = pBsCoeff;

    rotM = cell((g+1)^3, 1);
    for index = 1: (g+1)^3
        rotM{index} = eye(3);
    end

    orgRotM = rotM;
    curCP = preCompStruct.orgCP;
    % iterative optimization
    thershold = 0.01;
    maxIter = 30;
    iter = 0;
    preLoss = 0;

    lossCurve = zeros(3, maxIter);
    while iter < maxIter
        % calcualte target control points
        fprintf('Iter %d\n', iter);

        [dstCP, loss] = CalcDstCP(curCP, pArray, qArray, rotM, 0.1);
        lossCurve(:, iter + 1) = loss;
        curCP = dstCP;
        % transform current control points in a as-rigid-as-possible way
        rotM = CalcTransCP(orgCP, dstCP);

        Y = FFD(pBsCoeff, curCP);
        iter = iter + 1;
        if iter > 1 && preLoss - loss < thershold
            break;
        end
        preLoss = loss;
    end

    [~, pBsCoeffAll] = CalcCtrlPt(p, g);
    YAll = FFD(pBsCoeffAll, curCP);
    [pLP, qLP, pointErr, evalErr] = Evaluate(pTxt, qTxt, YAll, q);
    rId = int2str(i);
    region = ['A' rId ':AK' rId];
    xlswrite('../eval.csv', pointErr, 'Sheet1', rId);
end
