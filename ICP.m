clear;
close all;

% Config m, n
m = 50;
max_iter = 50;

[p,Fp] = read_vertices_and_faces_from_obj_file('health.obj');
[q,Fq] = read_vertices_and_faces_from_obj_file('injured.obj');
p = p';
q = q';

thershold = 0.01;
pArray = SampleMatrix(p, 100);
qArray = SampleMatrix(q, 100);
% PlotPoints(pArray, qArray, 'Origin');
k = 1;
pre_err = 1000;

while k < max_iter
    [idx, dist] = knnsearch(qArray', pArray');
    cArray = qArray(:,idx);
    [p0, q0, pCArray, qCArray] = Centralization(pArray, cArray);
    [M, N] = CalcSumProd(pCArray, qCArray);

    [quat, r, lambda] = CalcQuat(N);
    [s, t] = CalcScaleTrans(pCArray, qCArray, p0, q0, r);

    pArray = s * r * pArray + t * ones(1, length(cArray));
    err = sum(dist) / length(dist);
    fprintf('err: %f\n', err); 

    if pre_err - err < thershold
        fprintf('pre_err - err: %f\nk: %f\n',pre_err - err, k); 
        break
    end
    pre_err = err;
    k = k + 1;
end

resultPArray = s * r * p + t * ones(1, length(p));

PlotPoints(pArray, qArray, 'Transformed');

trisurf(Fp,resultPArray(1,1:end),resultPArray(2,1:end),resultPArray(3,1:end),'FaceColor',[0.26,0.33,1.0 ]);
light('Position',[-1.0,-1.0,100.0],'Style','infinite');
lighting phong;