function rotCell = CalcTransCP(curCP, dstCP, scale)
    global preComputeStruct;
    
    if (nargin<3)
        scale = 1;
    end
    
    nbr = preComputeStruct.nbrPointers;
    g = preComputeStruct.g;
    cpIdx = 1;
    rotCell = cell((g+1)^3, 1);
    
    for i = 1:(g+1)
        for j = 1:(g+1)
            for k = 1:(g+1)

                curNbr = curCP(nbr(cpIdx));
                dstNbr = dstCP(nbr(cpIdx));
                
                curCenter = curCP(cpIdx);
                dstCenter = dstCP(cpIdx);

                curEdge = curCenter - curNbr;
                dstEdge = dstCenter - dstNbr;

                [idx, ~] = knnsearch(curEdge', dstEdge');
                cEdge = dstEdge(:,idx);
                [~, ~, pCEdge, qCEdge] = Centralization(curEdge, cEdge);
                [~, N] = CalcSumProd(pCEdge, qCEdge);

                [~, r, ~] = CalcQuat(N);
                rotation = scale * r;
                
                %collect rotation
                rotCell{cpIdx} = {rotation};
                cpIdx = cpIdx + 1;
            end
        end
    end
    
end
