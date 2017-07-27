function [dstCP, loss] = CalcGuidedDstCP(lambda1, lambda2, curCP, pArray, qArray, rotM)

    persistent LHS;
    global preCompStruct;

    if nargin == 2
        LHS = CalcLHS(preCompStruct.pBsCoeff, preCompStruct.fpBsCoeff, ...
                    preCompStruct.nbrPointers, preCompStruct.g, lambda1, lambda2);
        return;
    end

    if nargin < 6
        lambda1 = 1;
        lambda2 = 1;
    end

    [obsRHS, obsLoss] = CalcFObsCoeff(curCP, preCompStruct.pBsCoeff, qArray);
    [regRHS, regLoss] = CalcFRegCoeff(rotM, preCompStruct.orgCP, curCP, ...
                            preCompStruct.nbrPointers, preCompStruct.g);

    [guidedRHS, guidedLoss] = CalcFObsCoeff(curCP, preCompStruct.fpBsCoeff,...
                                                        preCompStruct.fqPts);
    RHS = obsRHS + lambda1 * regRHS + lambda2 * guidedRHS;
    % save
    dstCP = linsolve(LHS, RHS);
    dstCP = dstCP';
    loss = [obsLoss; regLoss; guidedLoss; obsLoss + lambda1 * regLoss + lambda2 * guidedLoss];
end

function LHS = CalcLHS(pBsCoeff, fpBsCoeff, nbrPointers, g, lambda1, lambda2)

    nObs = size(pBsCoeff, 2);
    obsLHS = 2 * pBsCoeff * pBsCoeff' / nObs;

    p = (g + 1)^3;

    regLHS = zeros(p, p);

    % formulation A * P = B
    for i = 1:p
        ptrs = nbrPointers{i};

        lineA = zeros(1, p);
        lineA(i) = length(ptrs);
        lineA(ptrs) = -1;
        lineA = 4 * lineA;
        regLHS(i, :) = lineA;
    end
    regLHS = regLHS / p;

    nGuided = size(fpBsCoeff, 2);
    guidedLHS = 2 * fpBsCoeff * fpBsCoeff' / nGuided;

    LHS = obsLHS + lambda1 * regLHS + lambda2 * guidedLHS;
end

function [obsRHS, obsLoss] = CalcFObsCoeff(curCP, bsCoeff, qArray)
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

    obsRHS = 2 * B * C / n;
end

function [regRHS, regLoss] = CalcFRegCoeff(rotM, orgCP, curCP, nbrPointers, g)
    p = (g + 1)^3;

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
    regRHS = regRHS / p;
end
