%%

addpath(genpath(pwd));
VOCinit;
% cls = {'chair-img', 'trash-img', 'chair-vid', 'trash-vid'};
cls = {...
    'dragon',...
    'gsa_bottle',...
    'trans1',...
    'trans2',...
    'mickey',...
    'starbucks',...
    'la_prima'
    };
% models = load_all_models(cls{2});
% models = load_all_models('gsa');
models = load_all_models('bottle');
%%
vidExPipe;
files = dir(['/nfs/onega_no_backups/users/ashrivas/current/summer11'...
    '/google_demo/local/models/streams/*.mat']);
aa = struct2cell(files);
aa = aa(1,:);
cls = cellfun(@(x)x(13:end-13),aa, 'UniformOutput', false);
% %%
% 1    'bottle'
% 2    'box'
% 3   'chair'
% 4   'chair-img'
% 5   'cup'
% 6   'gsa'
% 7   'trash'
% 8   'trash-img'
% 9   'watch'

models = load_all_models(dataset_params, cls{8},[models_name '-svm']...
    ,[],1,1);
%%
models = models(1:4:end);
%% sub-Script to read files written by OpenCV!

lastIndexFile = '/home/abhinav/research/opencvCodes/lastIndex.txt';
oldFname{1} = '';

fName = textread(lastIndexFile,'%s');
while 1
    while strcmp(oldFname{1}, fName{1})
        while 1
            try
                fName = textread(lastIndexFile,'%s');
                break
            catch e
                continue;
            end
        end
    end
    I = convert_to_I(imread(fName{1}));
    my_find_exemp(I, models);
    pause(0.01);
    oldFname = fName;
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