function [dstCP, loss] = CalcGuidedDstCP(curCP, pArray, qArray, rotM, lambda1, lambda2)

    if nargin < 6
        lambda1 = 1;
        lambda2 = 1;
    end

    global preCompStruct;
    [obsLHS, obsRHS, obsLoss] = CalcFObsCoeff(curCP, preCompStruct.pBsCoeff, qArray);
    [regLHS, regRHS, regLoss] = CalcFRegCoeff(rotM, preCompStruct.orgCP, curCP, ...
                            preCompStruct.nbrPointers, preCompStruct.g);

    [guidedLHS, guidedRHS, guidedLoss] = CalcFObsCoeff(curCP, preCompStruct.fpBsCoeff,...
                                                        preCompStruct.fqPts);
    LHS = obsLHS + lambda1 * regLHS + lambda2 * guidedLHS;
    RHS = obsRHS + lambda1 * regRHS + lambda2 * guidedRHS;
    % save
    dstCP = linsolve(LHS, RHS);
    dstCP = dstCP';
    loss = [obsLoss; regLoss; guidedLoss; obsLoss + lambda1 * regLoss + lambda2 * guidedLoss];
end

function [obsLHS, obsRHS, obsLoss] = CalcFObsCoeff(curCP, bsCoeff, qArray)
    n = size(bsCoeff, 2);
    % apply FFD on pArray
    tArray = FFD(bsCoeff, curCP);

    % find correspounding closest point
    % knnSearch
    [idx, dist] = knnsearch(qArray', tArray');
    cArray = qArray(:, idx);

    % formulation 2B * B' * P = 2B * C
    % p: num ctrl pts, n: num samples
    % B: p by n, P: p by 3, C: n by 3
    B = bsCoeff;
    C = cArray';

    obsLoss = sum(dist .^ 2) / n;

    obsLHS = 2 * B * B' / n;
    obsRHS = 2 * B * C / n;
end

function [regLHS, regRHS, regLoss] = CalcFRegCoeff(rotM, orgCP, curCP, nbrPointers, g)
    p = (g + 1)^3;

    regLHS = zeros(p, p);
    regRHS = zeros(p, 3);

    regLoss = 0;
    % formulation A * P = B
    for i = 1:p
        ptrs = nbrPointers{i};

        orgCenter = orgCP(:, i);
        curCenter = curCP(:, i);
        orgEdges = orgCP(:, ptrs) - orgCenter;
        curEdges = curCP(:, ptrs) - curCenter;
        diffEdges = curEdges - rotM{i} * orgEdges;

        regLoss = regLoss + sum(dot(diffEdges, diffEdges));

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
    
    regLoss = regLoss / p;
    regLHS = regLHS / p;
    regRHS = regRHS / p;
end
