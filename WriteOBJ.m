function WriteOBJ(filename, p, Fp, centroid)
    if nargin == 3
        centroid == false
    end
    if centroid
        sigma = mean(p, 2);
        p = p - sigma  * ones(1, size(p, 2));
    end
    
    fid = fopen(filename, 'w');

    for i = 1:size(p, 2)
        fprintf(fid, 'v %.5f %.5f %.5f\n', p(1, i), p(2, i), p(3, i));
    end
    
    for i = 1:size(Fp, 2)
        fprintf(fid, 'f %d %d %d\n', Fp(1, i), Fp(2, i), Fp(3, i));
    end
    fclose(fid);
end