function [pArray, qArray] = SampleMatrix(p, q, m)
    
    l1 = floor(length(p) / m);
    l2 = floor(length(q) / m);
    
    pArray = zeros(3, l1);
    for i = 1:l1
        pArray(:,i) = p(:, i * m);
    end
    
    qArray = zeros(3, l2);
    for i = 1:l2
        qArray(:,i) = q(:, i * m);
    end
end