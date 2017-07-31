config = GenConfig();

id = 75;

fPtsIdx1 = importdata([config.healthyRoot 'landmark1/' num2str(id) '.txt']);
fPtsIdx2 = importdata([config.healthyRoot 'landmark2/' num2str(id) '.txt']);

model = load([config.healthyRoot 'mat/' num2str(id) '.mat']);

fPts1 = model.p(:, fPtsIdx1);
fPts2 = model.p(:, fPtsIdx2);

fPts = (fPts1 + fPts2) / 2;

save([config.healthyRoot 'landmark/' num2str(id) '.mat'], 'fPts');
