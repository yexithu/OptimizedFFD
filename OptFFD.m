clear;

% read objet
% [p,Fp] = read_vertices_and_faces_from_obj_file('health.obj');
% [q,Fq] = read_vertices_and_faces_from_obj_file('injured.obj');
% p = p';
% q = q';

load('data.mat');

% p source vertices , q target vertices
% pArray, qArray sample points
pArray = SampleMatrix(p, 100);
qArray = SampleMatrix(q, 100);

g = 8;

global preCompStruct;
preCompStruct = struct();
PreCompute(g);

% grid num g, current control point curCP
[orgCP, pBsCoeff] = CalcCtrlPt(pArray, g);
preCompStruct.orgCP = orgCP;
preCompStruct.pBsCoeff = pBsCoeff;

rotM = cell((g+1)^3, 1);
for index = 1: (g+1)^3
    rotM{index} = eye(3);
end

orgRotM = rotM;
curCP = preCompStruct.orgCP;
% iterative optimization
lim = [-50 150];
drawPoint(curCP, 0, lim);
maxIter = 30;
iter = 0;

lossCurve = zeros(3, maxIter);
while iter < maxIter
    % calcualte target control points
    fprintf('Iter %d\n', iter);

    [dstCP, loss] = CalcDstCP(curCP, pArray, qArray, rotM, 1);
    lossCurve(:, iter + 1) = loss;
    curCP = dstCP;
    % transform current control points in a as-rigid-as-possible way
    rotM = CalcTransCP(orgCP, dstCP);
    drawPoint(dstCP, iter, lim);
    iter = iter + 1;

end

generateGif(iter-1, 20);
save('loss.mat', 'lossCurve');
