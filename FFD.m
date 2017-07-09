function Y = FFD(bsCoeff, CP)
    % bsCoeff n by 1 cell
    % Y 3 by n matrix
    % CP 
    Y = CP * cell2mat(bsCoeff');
end