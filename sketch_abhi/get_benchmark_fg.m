function [fg, image_order, mapping] = get_benchmark_fg()

if exist('/nfs/onega_no_backups/users/ashrivas/datasets/sketch_bechmark/fg.mat', 'file')
    load /nfs/onega_no_backups/users/ashrivas/datasets/sketch_bechmark/fg.mat;
    return
end

fg_dir = '/nfs/onega_no_backups/users/ashrivas/datasets/sketch_bechmark/benchmark/images/';
dis_dir = '/nfs/onega_no_backups/users/ashrivas/datasets/image_100k/';

fg_dirs = dir(fg_dir);
fg_dirs = fg_dirs(3:end);


fg_s = cell(1, length(fg_dirs));
image_order = cell(1, length(fg_dirs));
mapping = cell(1, length(fg_dirs));
for i=1:length(fg_dirs)
    i
    image_order{i} = fg_dirs(i).name;
    fil = dir([fg_dir fg_dirs(i).name '/*.jpg']);
    fg_s{i} = cell(1,length(fil));
    mapping{i} = cell(1,length(fil));
    for j=1:length(fil)
        fg_s{i}{j} = fullfile(fg_dir, fg_dirs(i).name, fil(j).name);
        mapping{i}{j}.name = fil(j).name;
    end
end

dis_dirs = dir(dis_dir);
dis_dirs = dis_dirs(3:end);


dis_s = cell(1, length(dis_dirs));
arr = [];
for i=1:length(dis_dirs)
    i
    fil = dir([dis_dir dis_dirs(i).name '/*.jpg']);
    if isempty(fil)
        arr(end+1) = str2num(dis_dirs(i).name);
    end
    dis_s{i} = cell(1,length(fil));
    for j=1:length(fil)
        dis_s{i}{j} = fullfile(dis_dir, dis_dirs(i).name, fil(j).name);
    end
end

clc
arr

fg_s = cat(2,fg_s{:});
fg_dis = cat(2,dis_s{:});
fg = cat(2,fg_s, fg_dis);
save('/nfs/onega_no_backups/users/ashrivas/datasets/sketch_bechmark/fg.mat','fg');

end