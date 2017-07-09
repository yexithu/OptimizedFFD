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


curCP = preCompStruct.orgCP;
% iterative optimization

maxIter = 10;
iter = 1;
while iter < maxIter
    % calcualte target control points
    dstCP = CalcDstCP(curCP, pArray, qArray, rotM, 1);

    % transform current control points in a as-rigid-as-possible way
    rotM = CalcTransCP(orgCP, dstCP);

    iter = iter + 1;
end

