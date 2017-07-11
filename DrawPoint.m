function DrawPoint(prefix, Y, Q, iter, lim, Grid)

    subplot(2, 2, 1);
    if nargin == 6
        scatter3(Grid(1,:), Grid(2,:), Grid(3, :), 5, ...
            'MarkerEdgeColor', 'none','MarkerFaceColor',[0 1 0]);
        hold on;
    end

    scatter3(Y(1,:), Y(2,:), Y(3, :), 5, ...
            'MarkerEdgeColor', 'none','MarkerFaceColor',[1 0 0]);
    hold off;
    set(gca, 'XLim', lim, 'YLim', lim, 'ZLim', lim);

    subplot(2, 2, 2);
    scatter(Y(1,:), Y(2,:), 4, 'MarkerFaceColor', [0 1 0]);
    hold on;
    scatter(Q(1,:), Q(2,:), 4, 'MarkerFaceColor', [1 0 0]);
    hold off;
    set(gca, 'XLim', lim, 'YLim', lim);

    subplot(2, 2, 3);
    scatter(Y(1,:), Y(3,:), 4, 'MarkerFaceColor', [0 1 0]);
    hold on;
    scatter(Q(1,:), Q(3,:), 4, 'MarkerFaceColor', [1 0 0]);
    hold off;
    set(gca, 'XLim', lim, 'YLim', lim);

    subplot(2, 2, 4);
    scatter(Y(2,:), Y(3,:), 4, 'MarkerFaceColor', [0 1 0]);
    hold on;
    scatter(Q(2,:), Q(3,:), 4, 'MarkerFaceColor', [1 0 0]);
    hold off;
    set(gca, 'XLim', lim, 'YLim', lim);

    path = [prefix num2str(iter)];
    saveas(gcf, path, 'bmp');
end
