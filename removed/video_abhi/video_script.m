%%

addpath(genpath(pwd));
VOCinit;

load cls;

models = load_all_models('chair');
% models = load_all_models;
%% generate iamges from Video file..
videoFile = '/home/abhinav/research/data/new_data/test_vid/1.wmv';
% videoFile = '/home/abhinav/Desktop/1.avi';
tmpDir = '/home/abhinav/research/data/tmp/';

% Clear tmp dir.
unix(sprintf('rm %s*', tmpDir));

% generate images from video
imgName = 'image%d.jpg';
cmd = sprintf('ffmpeg -i %s -r 25 %s%s',videoFile, tmpDir, imgName);
status = unix(cmd);

if status
    disp('debug me');
    keyboard;
end


%%
files = dir([tmpDir '*.jpg']);
tmpDir1 = '/home/abhinav/research/data/tmp1/';
mkdir(tmpDir1);
for i=1:length(files)
    disp(i);
    I = convert_to_I(imread([tmpDir files(i).name]));
    my_find_exemp(I, models);
    saveas(gcf, [tmpDir1 files(i).name], 'jpg');
end

%%
sz = '1280x960';
device = '/dev/video3';

while 1
    tic
    unix(sprintf('streamer -q -s %s -c %s -f jpeg -o %simg.jpeg',sz,device,VOCopts.dumpdir));
    toc
    
    I = convert_to_I(imread(fullfile(VOCopts.dumpdir,'img.jpeg')));
    my_find_exemp(I, models);
    drawnow
    pause(0.001);
end
