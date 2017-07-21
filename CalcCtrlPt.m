function CP = CalcCtrlPt(X, g)
    minX = min(X, [], 2);
    maxX = max(X, [], 2);
    diffX = (maxX - minX);

    marginX = 0.05 * diffX;

    minX = minX - marginX;
    maxX = maxX + marginX;
    unitX = (maxX - minX) ./ g;

    CP = zeros(3, (g + 1) ^ 3);
    entry = 1;
    for i = 0:g
        for j = 0:g
            for k = 0:g
                CP(:, entry) = minX  + unitX .* [i; j; k];
                entry = entry + 1;
            end
        end
    end
end
