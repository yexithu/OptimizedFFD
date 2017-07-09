function rotCell = CalcTransCP(curCP, dstCP, scale)
    global preComputeStruct;
    
    if (nargin<3)
        scale = 1;
    end
    
    nbr = preComputeStruct.nbrPointers;
    g = preComputeStruct.g;
    idx = 1;
    gsqure = (g+1)^2;
    rotCell = cell((g+1)^3, 1);
    
    for i = 1:(g+1)
        for j = 1:(g+1)
            for k = 1:(g+1)

                curNbr = curCP(nbr(idx));
                dstNbr = dstCP(nbr(idx));
                
                curCenter = curCP(i * gsqure + j * (g + 1) + k + 1);
                dstCenter = dstCP(i * gsqure + j * (g + 1) + k + 1);

                curEdge = curCenter - curNbr;
                dstEdge = dstCenter - dstNbr;

                [idx, dist] = knnsearch(curEdge', dstEdge');
                cEdge = dstEdge(:,idx);
                [~, ~, pCEdge, qCEdge] = Centralization(curEdge, cEdge);
                [~, N] = CalcSumProd(pCEdge, qCEdge);

                [~, r, ~] = CalcQuat(N);
                rotation = scale * r;
                
                %collect rotation
                rotCell((i * gsqure + j * (g + 1) + k + 1), 1) = {rotation};
                   
                err = sum(dist) / length(dist);
                fprintf('err: %f\n', err);
            end
        end
    end
    
end
