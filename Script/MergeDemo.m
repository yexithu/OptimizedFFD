clear;
icp_prefix = './icp_result/';
ffd_prefix = './ffd_result/';

count = 49;
i = 0;

videoName = './mVideo';

outputVideo = VideoWriter(videoName);
outputVideo.FrameRate = 10;
open(outputVideo);

idxs = [0:count];
idxs = [count, idxs];
for idx = 1:length(idxs)
    i = idxs(idx);
    fprintf('iter: %d\n', i);
    suffix = [num2str(i) '.bmp'];

    ffdPath = [ffd_prefix suffix];
    icpPath = [icp_prefix suffix];

    ffdImg = imread(ffdPath);
    icpImg = imread(icpPath);

    [h, w, c] = size(ffdImg);
    halfW = floor(w/2);

    nImg = cat(2, ffdImg(:, 1:halfW,:), icpImg(:, 1:halfW, :));
    writeVideo(outputVideo, nImg);
end

close(outputVideo);

