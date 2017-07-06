% read objet
[p,Fp] = read_vertices_and_faces_from_obj_file('health.obj');
[q,Fq] = read_vertices_and_faces_from_obj_file('injured.obj');
p = p';
q = q';

% p source vertices , q target vertices
% pArray, qArray sample points
[pArray, qArray] = SampleMatrix(p, q, 100);

% grid num g, current control point curCP
g = 8;
curCP = CalcCtrlPt(pArray, g);

% iterative optimization
while true
    % calcualte target control points
    dstCP = CalcDstCP(curCP, pArray, qArray);

    % transform current control points in a as-rigid-as-possible way
    transCP = CalcTransCP(curCP, dstCP);

    % apply transformation to current control points
    curCP = transCP;
end

% apply free form deformation with final control points
transP = FFD(curCP, p);

% show final result