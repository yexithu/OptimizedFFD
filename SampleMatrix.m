function [pArray] = SampleMatrix(p, m)

    l1 = floor(length(p) / m);

    pArray = zeros(3, l1);
    for i = 1:l1
        pArray(:,i) = p(:, i * m);
    end

end