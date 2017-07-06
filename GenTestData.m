function [pArray, qArray, R, S, T] = GenTestData(m)

    % random rotaion matrix
    [R,~] = qr(randn(3));
    % random translation
    T = 4 * rand(3, 1);
    S = 2 * rand();
    pArray = randn(3, m);

    qArray = S * R * pArray + T * ones(1, m); 

    % random perturbation
    sigma = 0.5 * randn(3, m);
    qArray = qArray + sigma;
end