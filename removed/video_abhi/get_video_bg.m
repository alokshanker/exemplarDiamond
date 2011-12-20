function bg = get_video_bg(neg_path)

if exist([neg_path 'bg.mat'], 'file')
   load([neg_path 'bg.mat']);
   return
end
%% init
ffmpegPath = '/nfs/baikal/tmalisie/ffmpeg/ffmpeg-0.6/ffmpeg ';
file_type = 'avi';
conv_type = 'wmv';

%% Convert to Images
% ffmpeg -i IMG_1130.MOV -acodec libmp3lame -ab 192k -vcodec libxvid -b ...
% 940k -sameq -r 25 -aspect 4:3 -s 640x480 room.avi
files = dir([neg_path '*.' conv_type]);
for i=1:length(files)
    fullname = [neg_path files(i).name];
    if ~exist([ neg_path files(i).name(1:end-4) '.avi'],'file')
        cmd = sprintf(['%s -i %s '...
           ' -b 940k -sameq -r 25 -aspect 4:3 -s 640x480 %s/%s.avi'],...
           ffmpegPath, fullname, neg_path, [files(i).name(1:end-4)]);
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

%% Make BG
files = dir([neg_path '*.' file_type]);
for i=1:length(files)
    mname = files(i).name;
    neg_folder = [neg_path 'negative_imgs'];
    if ~exist(neg_folder,'dir')
        mkdir(neg_folder);
    end
    
    full_name = [neg_path mname];
    img_name = 'image%d.jpg';
    cmd = sprintf('%s -i %s -r 5 %s/%s', ffmpegPath, full_name, ...
        neg_folder, img_name);
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
files11 = dir([neg_folder '/*.jpg']);
fprintf('\n# of Negative Images : %d', length(files11));

%% make bg datastrcture..

aa = struct2cell(files11);
b = aa(1,:);
bg = cellfun(@(x) fullfile(neg_folder,  x), b,'UniformOutput',false);
save([neg_path 'bg.mat'], 'bg');