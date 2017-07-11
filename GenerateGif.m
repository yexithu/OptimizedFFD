function GenerateGif(prefix, imgCount, rate)
    outputVideo = VideoWriter([prefix 'skull.avi']);
    outputVideo.FrameRate = rate;
    open(outputVideo);

    for i = 0:imgCount
        path = prefix;
        path = [path num2str(i) '.bmp'];
        img = imread(path);
        writeVideo(outputVideo, img)
    end
    close(outputVideo);
end
