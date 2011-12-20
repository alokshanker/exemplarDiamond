% Running Script
video_pref = '/nfs/onega_no_backups/users/ashrivas/current/research_data/';
file_type = 'avi';
files = dir([video_pref '*.' file_type]);
save_folder_exemplar = '/nfs/onega_no_backups/users/ashrivas/current/new_data/';

for i=1:length(files)
    mname = files(i).name;
    if strfind(mname, 'room') > 0
%         full_name = [video_pref mname];
%         nsec = get_video_time(full_name);
%         bg = {};
%         bg = get_movie_bg(full_name, max(round(nsec*30), 3000));
%         keyboard
%         fprintf('\nSaving %d for BG',  length(bg));
%         save([save_folder_exemplar 'bg.mat'],'bg');
        continue;
%     else
%         continue;
    end
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
    
    nsec = get_video_time(full_name);
    fg = {};
    fg = get_movie_bg(full_name, round(nsec*25/20));
    fprintf('\n# of Exemplars for %s : %d', mname(1:end-4), length(fg));
    for j=1:length(fg)
        imshow(convert_to_I(fg{j}));
        imwrite(convert_to_I(fg{j}), sprintf('%s/%d.jpg',exemplar_folder,j));
        pause(0.1);
    end
end
