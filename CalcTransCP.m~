function [rotation_collection] = CalcTransCP(curCP, dstCP, scale)
    if (nargin<3)
        scale = 1;
    end

    %%first divide control points
    groupSize = 3 * 3 * 3;
    stride = 1;
    l = 8;
    m = 8;
    n = 8;
    
    % for a single cell
    for i = 1:(l+1)
        
        if l == 1
                    startI = 
                elseif l == 9
                    
                else
                    
                end
        for j = 1:(m+1)
            for k = 1:(n+1)
                if l == 1
                    startI = 
                elseif l == 9
                    
                else
                    
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
                
                %adapt rotation
                curEdgeWithCenter = rotation * curEdgeWithCenter();
                dstEdgeWithCenter = rotation * dstEdgeWithCenter();
                
                
                curCP()
                   
                err = sum(dist) / length(dist);
                fprintf('err: %f\n', err);
            end
        end
    end

end
