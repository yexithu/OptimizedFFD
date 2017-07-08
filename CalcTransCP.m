function [rotCell] = CalcTransCP(curCP, dstCP, scale)
    if (nargin<3)
        scale = 1;
    end

    %%first divide control points
    groupSize = 3 * 3 * 3;
%     stride = 1;
    l = 8;
    m = 8;
    n = 8;
    
    rotCell = cell(l+1,m+1,n+1);
    
    % for a single cell
    for i = 1:(l+1)

        if i == 1
            startI = i;
        else
            startI = i-1;
        end
        if i == l+1
            endI = i;
        else
            endI = i+1;
        end
        
        for j = 1:(m+1)
            if j == 1
                startJ = j;
            else
                startJ = j-1;
            end
            
            if j == m+1
                endJ = j;
            else
                endJ = j+1;
            end
            
            for k = 1:(n+1)
                if k == 1
                    startK = 1;
                else
                    startK = k+1;
                end
                
                if k == n+1
                    endK = k;
                else
                    endK = k+1;
                end
                    
                
                curCube = curCP(startI:endI,startJ:endJ,startK:endK);
                dstCube = dstCP(startI:endI,startJ:endJ,startK:endK);
                
                curCenter = curCube(2,2,2);
                dstCenter = dstCube(2,2,2);

                curEdgeWithCenter = curCenter - reshape(cell2mat(curCube), 3, groupSize);
                dstEdgeWithCenter = dstCenter - reshape(cell2mat(dstCube), 3, groupSize);

                curEdge = curEdgeWithCenter;
                curEdge(:, (groupSize + 1)/2) = [];
                dstEdge = dstEdgeWithCenter;
                dstEdge(:, (groupSize + 1)/2) = [];


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