function [quat, rotM, lambda] = CalcQuatRotM(N)
    [V, D] = eig(N);
    [D, I] = sort(diag(D), 'descend');
    V = V(:, I);

    quat = V(:, 1);
    lambda = D(1);

    if lambda < 0
        fprintf('Something wrong\n');
        error('Lambda < 0\n');
    end

    rotM = quat2rotm(quat');
end