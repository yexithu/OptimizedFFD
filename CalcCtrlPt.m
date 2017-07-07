function [CP, bsCoeff] = CalcCtrlPt(X, g)    
    minX = min(X, [], 2);
    maxX = max(X, [], 2);
    unitX = (maxX - minX) ./ g;

    CP = cell(g + 1, g + 1, g + 1);
    for i = 1:g + 1
        for j = 1:g + 1
            for k = 1:g + 1
                CP{i, j, k} = minX  + unitX .* [i - 1; j - 1; k - 1];
            end
        end
    end

    n = size(X, 2);
    D = X - minX * ones(1, n);
    L = maxX - minX;
    D = D ./ (L * ones(1, n));

    % bsCoeff = cell(g + 1, g + 1, g + 1);
    bsCoeff = cell(n, 1);
    combntnV = zeros(g + 1, 1);
    for index = 1:g + 1
        combntnV(index) = nchoosek(g, index - 1);
    end

    for index = 1:n
        s = D(1, index);
        t = D(2, index);
        u = D(3, index);

        entry = 1;
        coeff = zeros((g + 1)^3, 1);
        for k = 0:g
            for j = 0:g
                for i = 0:g
                    tmp = combntnV(i + 1) * combntnV(j + 1) * combntnV(k + 1);
                    tmp = tmp * power(1 - s, g - i) * power(s, i);
                    tmp = tmp * power(1 - t, g - j) * power(t, j);
                    tmp = tmp * power(1 - u, g - k) * power(u, k);
                    coeff(entry) = tmp;
                    entry = entry + 1;
                end
            end
        end
        bsCoeff{index} = coeff;
    end

end
