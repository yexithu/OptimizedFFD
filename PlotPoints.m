function PlotPoints(x, y, t)
    figure
    title(t);
    scatter3(x(1, 1:end), x(2, 1:end), x(3, 1:end), 'MarkerFaceColor', 'red');
    hold on
    scatter3(y(1, 1:end), y(2, 1:end), y(3, 1:end), 'MarkerFaceColor', 'blue');
    hold off
end