function rotCell = CalcTransCP(curCP, dstCP)
    global preCompStruct;
    nbr = preCompStruct.nbrPointers;
    g = preCompStruct.g;
    rotCell = cell((g+1)^3, 1);

    n = size(curCP, 2);

    for cpIdx = 1:n
        nPtrs = length(nbr{cpIdx});
        curNbr = curCP(:, nbr{cpIdx});
        dstNbr = dstCP(:, nbr{cpIdx});

        curCenter = curCP(:, cpIdx);
        dstCenter = dstCP(:, cpIdx);

        curEdge = curCenter * ones(1, nPtrs) - curNbr;
        dstEdge = dstCenter * ones(1, nPtrs) - dstNbr;

        [~, ~, pCEdge, qCEdge] = Centralization(curEdge, dstEdge);
        [~, N] = CalcSumProd(pCEdge, qCEdge);

        [~, r, ~] = CalcQuat(N);
%         scale = CalcScale(curNbr, dstNbr);
        scale = 1;
        rotation = scale * r;

        %collect rotation
        rotCell{cpIdx} = rotation;
    end

end

function scale = CalcScale(X, Y)
    meanX = mean(X, 2);
    meanY = mean(Y, 2);

    X = X - meanX;
    Y = Y - meanY;

    X = X(:);
    Y = Y(:);
    scale = sqrt(dot(Y, Y) / dot(X, X));
end
