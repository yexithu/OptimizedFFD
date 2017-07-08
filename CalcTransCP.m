function [rotCell] = CalcTransCP(curCP, dstCP, scale)
    if (nargin<3)
        scale = 1;
    end

    %%first divide control points
%     stride = 1;
    l = 8;
    m = 8;
    n = 8;
    
    rotCell = cell(l+1,m+1,n+1);
    
    % for a single cell
    for i = 1:(l+1)

        [startI, endI, lengthI, centerI] = getNbrArg(i, l+1);
        
        for j = 1:(m+1)
           
            [startJ, endJ, lengthJ, centerJ] = getNbrArg(j, m+1);
            
            for k = 1:(n+1)
                
                [startK, endK, lengthK, centerK] = getNbrArg(k, n+1);
                
                curCube = curCP(startI:endI,startJ:endJ,startK:endK);
                dstCube = dstCP(startI:endI,startJ:endJ,startK:endK);
                
                curCenter = curCube(centerI,centerJ,centerK);
                dstCenter = dstCube(centerI,centerJ,centerK);
                
                groupSize = lengthI * lengthJ * lengthK;

                curEdgeWithCenter = curCenter - reshape(cell2mat(curCube), 3, groupSize);
                dstEdgeWithCenter = dstCenter - reshape(cell2mat(dstCube), 3, groupSize);

                curEdge = curEdgeWithCenter;
                centerIdx = find(curEdge==[0,0,0]');
                curEdge(:, centerIdx) = [];
                dstEdge = dstEdgeWithCenter;
                dstEdge(:, centerIdx) = [];


                [idx, dist] = knnsearch(curEdge', dstEdge');
                cEdge = dstEdge(:,idx);
                [~, ~, pCEdge, qCEdge] = Centralization(curEdge, cEdge);
                [~, N] = CalcSumProd(pCEdge, qCEdge);

                [~, r, ~] = CalcQuat(N);
                rotation = scale * r;
                
                %collect rotation
                rotCell(i,j,k) = {rotation};
                   
                err = sum(dist) / length(dist);
                fprintf('err: %f\n', err);
            end
        end
    end
    
end

function [startX, endX, centerX, lengthX] = getNbrArg(x, maxX)
    if x == 1
        startX = 1;
        centerX = 1;
    else
        startX = x-1;
        centerX = 2;
    end

    if x == maxX
        endX = x;
    else
        endX = x+1;
    end

    lengthX = 3;
    if x == 1 || x == maxX
        lengthX = 2;
    end
end