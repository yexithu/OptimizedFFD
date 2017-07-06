function [s, t] = CalcScaleTrans(pCAry, qCAry, p0, q0, rotM)
    pFlat = pCAry(:);
    qFlat = qCAry(:);
    
    s = sqrt(dot(qFlat, qFlat) / dot(pFlat, pFlat));
    t = q0 - s * rotM * p0;
end