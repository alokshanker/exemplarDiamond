%% function getEplars4mVideo

%% init
video_pref = '/nfs/onega_no_backups/users/ashrivas/datasets/gDemo/videos/';
neg_path = '/nfs/onega_no_backups/users/ashrivas/datasets/gDemo/negative/';
ffmpegPath = '/nfs/baikal/tmalisie/ffmpeg/ffmpeg-0.6/ffmpeg ';
file_type = 'avi';
conv_type = 'wmv';
fps = 0.8; %FPS to use to store images from Videos...
save_folder_exemplar = '/nfs/onega_no_backups/users/ashrivas/datasets/gDemo/input_exemplars/';
% save_folder_exemplar = '/nfs/onega_no_backups/users/ashrivas/current/new_data/';


%% Convert to AVI
% write code to convert other mov/wmv files to avi
% pending..


% ffmpeg -i IMG_1130.MOV -acodec libmp3lame -ab 192k -vcodec libxvid -b ...
% 940k -sameq -r 25 -aspect 4:3 -s 640x480 room.avi
files = dir([video_pref '*.' conv_type]);
for i=1:length(files)
    fullname = [video_pref files(i).name];
    if ~exist([ video_pref files(i).name(1:end-4) '.avi'],'file')
        cmd = sprintf(['%s -i %s '...
           ' -b 940k -sameq -r 25 -aspect 4:3c -s 320x240 %s/%s.avi'],...
           ffmpegPath, fullname, video_pref, [files(i).name(1:end-4)]);
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
%% Make Exemplar images..
% read video files
files = dir([video_pref '*.' file_type]);
% actual code.
for i=1:length(files)
    mname = files(i).name;
    exemplar_folder = [save_folder_exemplar mname(1:end-4)];
    
    if ~exist(exemplar_folder,'dir')
        mkdir(exemplar_folder);
    else
        files11 = dir([exemplar_folder '/*.jpg']);
        if ~isempty(files11)
            fprintf('\n***%d # of Exemplars already stored for %s (delete folder to save again)\n'...
                , length(files11), mname(1:end-4));    
            continue;
        end
    end
    
    full_name = [video_pref mname];
    img_name = 'image%d.jpg';
    cmd = sprintf('%s -i %s -r %f %s/%s', ffmpegPath, full_name, ...
        fps, exemplar_folder, img_name);
    status = unix(cmd);
    if status
        if 1
            disp('debug cmd');
            keyboard
        else
            error('debug cmd');
        end
    end
    files11 = dir([exemplar_folder '/*.jpg']);
    fprintf('\n# of Exemplars for %s : %d', mname(1:end-4), length(files11));
end


%%

addpath(genpath('exemplarsvm'));
initialize_exemplars_dir(save_folder_exemplar, 1);

%%

