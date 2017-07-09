function [dstCP] = CalcDstCP(curCP, pArray, qArray, rotM, lamda)

    if nargin < 5
        lamda = 1;
    end

    global preCompStruct;
    [obsLHS, obsRHS] = CalcFObsCoeff(curCP, preCompStruct.pBsCoeff, qArray);
    [regLHS, regRHS] = CalcFRegCoeff(rotM, preCompStruct.orgCP, ...
                            preCompStruct.nbrPointers, preCompStruct.g);
    
    LHS = obsLHS + lamda * regLHS;
    RHS = obsRHS + lamda * regRHS;
    %solve linaer equations
    dstCP = linsolve(LHS, RHS);
    dstCP = dstCP';
end

function [obsLHS, obsRHS] = CalcFObsCoeff(curCP, bsCoeff, qArray)
    n = length(bsCoeff);
    % apply FFD on pArray
    tArray = FFD(bsCoeff, curCP);

    % find correspounding closest point
    % knnSearch
    idx = knnsearch(qArray', tArray');
    cArray = qArray(:, idx);

    % formulation 2B * B' * P = 2B * C
    % p: num ctrl pts, n: num samples
    % B: p by n, P: p by 3, C: n by 3
    B = cell2mat(bsCoeff');
    C = cArray';

    obsLHS = 2 * B * B' / n;
    obsRHS = B * C / n;
end

function [regLHS, regRHS] = CalcFRegCoeff(rotM, orgCP, nbrPointers, g)
    p = (g + 1)^3;

    regLHS = zeros(p, p);
    regRHS = zeros(p, 3);
    % formulation A * P = B
    for i = 1:p
        ptrs = nbrPointers{p};

        lineA = zeros(1, p);
        lineA(i) = length(ptrs);
        lineA(ptrs) = -1;
        lineA = 4 * lineA;
        regLHS(i, :) = lineA;
        
        lineB = zeros(1, 3);
        for nbrIndex = 1:length(ptrs)
            j = ptrs(nbrIndex);
            temp = (rotM{i} + rotM{j}) * (orgCP(:, i) - orgCP(:, j));
            lineB = lineB + temp';
        end
        lineB = 2 * lineB;

        regRHS(i, :) = lineB;
    end

    regLHS = regLHS / p;
    regRHS = regRHS / p;
end
