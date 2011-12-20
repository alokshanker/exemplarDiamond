function testVideos(cls)
% Assumes that in a given directory, there are folders names cls's which
% have test videos for that particular cls. If no cls if provided, uses a
% predefined cls.

vidExPipe;
if ~exist('cls','var')
% 1    'bottle'
% 2    'box'
% 3   'chair'
% 4   'chair-img'
% 5   'cup'
% 6   'gsa'
% 7   'trash'
% 8   'trash-img'
% 9   'watch' 
    cls = {'bottle', 'box', 'chair', 'chair-img', 'cup', 'gsa', 'trash',...
        'trash-img', 'watch' };
end

test_dir = ['/nfs/onega_no_backups/users/ashrivas/datasets/'...
    'video_demo/test_vid/'];

res_dir = fullfile(dataset_params.devkitroot, 'tmp', 'result','/');

if ~exist(res_dir,'dir')
    mkdir(res_dir);
end
% tmp_dir_test = ['/nfs/onega_no_backups/users/ashrivas/datasets/'...
%     'video_demo/tmp_imgs/test/'];

tmp_dir_test = fullfile(dataset_params.devkitroot, 'tmp', 'test','/');

% tmp_dir_res = ['/nfs/onega_no_backups/users/ashrivas/datasets/'...
%     'video_demo/tmp_imgs/result/'];

tmp_dir_res = fullfile(dataset_params.devkitroot, 'tmp', 'result','/');

for cl = 1:length(cls)
   folder = [test_dir cls{cl} '/'];
   %convertWMV2AVI(folder);
   files = dir([folder '*.avi']);
   models = load_all_models(dataset_params, cls{cl},[models_name '-svm']...
    ,[],1,1);
   
   for vidNo = 1:length(files)
       tmpDir = fullfile(tmp_dir_test, cls{cl}, ...
           files(vidNo).name(1:end-4),'/');
       
       targetDir = fullfile(tmp_dir_res, cls{cl}, ...
           files(vidNo).name(1:end-4),'/');
       
       if (mymkdir_dist(tmpDir) == 0)
            if (mymkdir_dist(targetDir) == 0)
               continue
            end
       end
       createImages4mVideo([folder files(vidNo).name], tmpDir);
       
       main_test_fn(models, tmpDir, targetDir);
       
       createVideo4mImages(fullfile(res_dir, cls{cl}, ['/res_', ...
           files(vidNo).name]), targetDir);
   end
end


end

function main_test_fn(models, tmpDir, targetDir)

if ~exist(targetDir,'dir')
    mkdir(targetDir);
end
unix(sprintf('rm %s*', targetDir));

files = dir([tmpDir '*.jpg']);
for i=1:length(files)
    I = convert_to_I(fullfile(tmpDir, files(i).name));
    my_find_exemp(I, models);
    saveas(gcf, [targetDir files(i).name], 'jpg');
end

end

function createImages4mVideo(videoFile, tmpDir)

files = dir([tmpDir '*.jpg']);
if length(files)>0
    return;
end

ffmpegPath = '/nfs/baikal/tmalisie/ffmpeg/ffmpeg-0.6/ffmpeg ';
imgName = 'image%d.jpg';
cmd = sprintf('%s -i %s -r 25 %s%s',ffmpegPath, videoFile, tmpDir, imgName);
status = unix(cmd);

if status
    disp('debug me');
    keyboard;
end

end

function createVideo4mImages(fileName, tmpDir)
if exist(fileName, 'file')
    return;
end

ffmpegPath = '/nfs/baikal/tmalisie/ffmpeg/ffmpeg-0.6/ffmpeg ';
imgName = 'image%d.jpg';
cmd = sprintf('%s -f image2 -i %s%s %s',ffmpegPath, tmpDir, imgName, fileName);
status = unix(cmd);

if status
    disp('debug me');
    keyboard;
end


end

function convertWMV2AVI(folder)
ffmpegPath = '/nfs/baikal/tmalisie/ffmpeg/ffmpeg-0.6/ffmpeg ';
files = dir([folder '*.wmv']);
for i=1:length(files)
    fullname = [folder files(i).name];
    if ~exist([ folder files(i).name(1:end-4) '.avi'],'file')
        cmd = sprintf(['%s -i %s '...
           ' -b 940k -sameq -r 25 %s/%s.avi'],...
           ffmpegPath, fullname, folder, [files(i).name(1:end-4)]);
        status = unix(cmd);
        if status
            if 1
                disp('debug cmd');
                keyboard
            else
                error('debug cmd');
            end
        end 
    end
end

end