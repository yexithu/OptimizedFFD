function [r, t, s] = AbsOrient(X, Y, scale)

    [p0, q0, pArray, qArray] = Centralization(X, Y);
    [~, N] = CalcSumProd(pArray, qArray);
    [~, r, ~] = CalcQuat(N);

    if nargin == 2
        [s, t] = CalcScaleTrans(pArray, qArray, p0, q0, r);
    else if nargin == 3
        s = scale;
        t = q0 - s * r * p0;
    end
end
