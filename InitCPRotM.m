function [curCP, rotM] = InitCPRotM(pArray, qArray, orgCP)
    global preCompStruct;
    g = preCompStruct.g;
    [p0, q0, pCArray, qCArray] = Centralization(pArray, qArray);
    [~, N] = CalcSumProd(pCArray, qCArray);
    [~, r, ~] = CalcQuat(N);
    t = q0 - p0;

    rotM = cell((g+1)^3, 1);
    for index = 1: (g+1)^3
        rotM{index} = r;
    end
    curCP = r * orgCP + t * ones(1, (g + 1)^3);
end