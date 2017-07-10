function drawPoint(dstCP, iter, lim)
    global preCompStruct;
    Y = FFD(preCompStruct.pBsCoeff, dstCP);
    scatter3(dstCP(1,1:end), dstCP(2,1:end), dstCP(3, 1:end),'MarkerFaceColor',[0 1 0]);
    hold on;
    scatter3(Y(1,1:end), Y(2,1:end), Y(3, 1:end),'MarkerFaceColor',[1 0 0]);
    hold off;
    set(gca, 'XLim', lim, 'YLim', lim, 'ZLim', lim);
    path = './result/';
    path = [path num2str(iter)];
    saveas(gcf, path, 'bmp');
end