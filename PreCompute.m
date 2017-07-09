function PreCompute(g)
    global preCompStruct;
    
    preCompStruct.g = g;
    nbrIndices = cell((g + 1)^3, 1);

    index = 1;
    for i = 0:g
        for j = 0:g
            for k = 0:g
                nbrIndices{index} = CalCNbr(g, i, j, k);
                index = index + 1;
            end
        end
    end

    preCompStruct.nbrPointers = nbrIndices;
end

function nbr = CalCNbr(g, i, j, k)
    lowI = max(i - 1, 0);
    highI = min(i + 1, g);

    lowJ = max(j - 1, 0);
    highJ = min(j + 1, g + 1);

    lowK = max(k - 1, 0);
    highK = min(k + 1, g);

    gsqure = (g + 1)^2;

    entrance = 1;
    nbr = zeros(1, (highI - lowI + 1) * (highJ - lowJ + 1) * (highK - lowK + 1));
    for i = lowI:highI
        for j = lowJ:highJ
            for k = lowK: highK
                nbr(entrance) = i * gsqure + j * (g + 1) + k + 1;
                entrance = entrance + 1;
            end
        end
    end
end