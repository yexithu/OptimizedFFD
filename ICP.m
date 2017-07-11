clear;

% [p,Fp] = read_vertices_and_faces_from_obj_file('health.obj');
% [q,Fq] = read_vertices_and_faces_from_obj_file('injured.obj');
% p = p';
% q = q';

load('data.mat');
prefix = './icp_result/';
thershold = 0.01;
pArray = SampleMatrix(p, 100);
qArray = SampleMatrix(q, 100);
% PlotPoints(pArray, qArray, 'Origin');
pre_err = 1000;

% Config m, n
lim = [-25 200];
DrawPoint(prefix, pArray, qArray, 0, lim);
max_iter = 50;
k = 0;

while k < max_iter
    [idx, dist] = knnsearch(qArray', pArray');
    cArray = qArray(:,idx);
    [p0, q0, pCArray, qCArray] = Centralization(pArray, cArray);
    [M, N] = CalcSumProd(pCArray, qCArray);

    [quat, r, lambda] = CalcQuat(N);
    [s, t] = CalcScaleTrans(pCArray, qCArray, p0, q0, r);

    pArray = s * r * pArray + t * ones(1, length(cArray));
    DrawPoint(prefix, pArray, qArray, k, lim);
    err = sum(dist) / length(dist);
    fprintf('err: %f\n', err); 

%    if pre_err - err < thershold
%        fprintf('pre_err - err: %f\nk: %f\n',pre_err - err, k); 
%        break
%    end
    pre_err = err;
    k = k + 1;
end

GenerateGif(prefix, k-1, 10);
% resultPArray = s * r * p + t * ones(1, length(p));

% PlotPoints(pArray, qArray, 'Transformed');

% trisurf(Fp,resultPArray(1,1:end),resultPArray(2,1:end),resultPArray(3,1:end),'FaceColor',[0.26,0.33,1.0 ]);
% light('Position',[-1.0,-1.0,100.0],'Style','infinite');
% lighting phong;
