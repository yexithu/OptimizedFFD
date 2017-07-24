function GenerateGif(prefix, imgCount, rate)
    outputVideo = VideoWriter([prefix 'skull.avi']);
    outputVideo.FrameRate = rate;
    open(outputVideo);
    
    idxMap = [0:1:imgCount];
    idxMap = [imgCount, idxMap];
    for j = 1:length(idxMap)
        i = idxMap(j);
        path = prefix;
        path = [path num2str(i) '.bmp'];
        img = imread(path);
        writeVideo(outputVideo, img)
    end
    close(outputVideo);
end
