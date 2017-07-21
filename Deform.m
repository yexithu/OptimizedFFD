function Y = Deform(DF, X)
    if strcmp(DF.method, 'ICP')
        Y = ICPDeform(DF, X)
    elseif strcmp(DF.method, 'FFD')
        Y = FFDDeform(DF, X)
    else
        throw 'No Such Deformation Method!'
    end
end

function Y = ICPDeform(DF, X)
    n = size(X, 2);
    Y = DF.S * DF.R * X + DF.T * ones(1, n);
end

function Y = FFDDeform(DF, X)
    bsCoeff = CalcBSCoeff(X, DF.g, DF.orgCP);
    Y = FFD(bsCoeff, DF.dstCP);
end
