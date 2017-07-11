function generateGif(imgCount, rate)
    outputVideo = VideoWriter('./result/skull.avi');
    outputVideo.FrameRate = rate;
    open(outputVideo);

    for i = 0:imgCount
        path = './result/';
        path = [path num2str(i) '.bmp'];
        img = imread(path);
        writeVideo(outputVideo, img)
    end
end
