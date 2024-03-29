function bsCoeff = CalcBSCoeff(X, g, orgCP)

    minX = orgCP(:, 1);
    maxX = orgCP(:, end);

    n = size(X, 2);
    D = X - minX * ones(1, n);
    L = maxX - minX;
    D = D ./ (L * ones(1, n));

    bsCoeffCell = cell(n, 1);
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
        for i = 0:g
            for j = 0:g
                for k = 0:g
                    tmp = combntnV(i + 1) * combntnV(j + 1) * combntnV(k + 1);
                    tmp = tmp * power(1 - s, g - i) * power(s, i);
                    tmp = tmp * power(1 - t, g - j) * power(t, j);
                    tmp = tmp * power(1 - u, g - k) * power(u, k);
                    coeff(entry) = tmp;
                    entry = entry + 1;
                end
            end
        end
        bsCoeffCell{index} = coeff;
    end

    bsCoeff = cell2mat(bsCoeffCell');


