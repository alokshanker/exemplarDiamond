function [score image] = test(img)
addpath(genpath(pwd));



%% %%  Dataset Params Like VOCinit (where to store etc.)
    
%devkitroot is where we write all the result files
dataset_params.dataset = '/learnt_models';
 
dataset_params.devkitroot = ['/home/exemplar' dataset_params.dataset];

dataset_params.wwwdir = [dataset_params.devkitroot '/www/'];

% change this path to a writable local directory for the example code
dataset_params.localdir=[dataset_params.devkitroot '/local/'];

% change this path to a writable directory for your results
dataset_params.resdir=[dataset_params.devkitroot ['/' ...
                    'results/']];
dataset_params.display = 0;
dataset_params.NIMS_PER_CHUNK = 50;
%dataset_params.testset = 'test';
%dataset_params = VOCinit(dataset_params);

scenestring = 'exemplar';

%Choose a short string to indicate the type of training run we are doing
models_name = ['s.' scenestring];
init_params.goal_ncells = 150;
init_params.MAXDIM = 15;
init_params.sbin = 8;
init_params.init_type = 'goalsize';
%initializes exemplar according to parameters defined above
init_params.init_function = @initialize_goalsize_model;
get_default_param_f = @get_default_mining_params;
default_mining_f = @get_default_mining_params_video;
mining_params = default_mining_f();

%% setup streams
stream_f = @get_exemplar_stream_sketch;

% this path should have folders with images in it. Folder names are
% expected to be class/category names.
%images for which exemplars have to be created
folder = ['/home/exemplar/dataset/'];
                        
%No of objects to select per frame..
N_Frame = 1;
e_stream_set = stream_f(dataset_params, folder, N_Frame);

%% Define Test set for the benchmark dataset.
% test_set = get_benchmark_fg();
test_gt_function = [];
test_params = get_default_mining_params;
test_params.thresh = -1;

%%get_james_bg(10000);value proposition for security
clss = cellfun(@(x) x.cls, e_stream_set, 'UniformOutput',false);
clssU = unique(clss);
e_stream_cls = cell(0, length(clssU));
for cl = 1:length(clssU)
    e_stream_cls{cl} = e_stream_set(cell2mat(cellfun(@(x)...
        strcmp(x.cls, clssU{cl}),  e_stream_set, 'UniformOutput',false)));
end
cls = clssU;
%% RUN TESTING
%files = dir('/home/exemplar/testset/*.bmp');
%pa = '/home/exemplar/testset/';
%test_set = cellfun(@(x) [pa x], {files.name}, 'UniformOutput', false);
%
score = 0;
for ii=1:length(cls) 
    models = load_all_models(dataset_params, cls{ii},[models_name '-svm'],[],0,1);
    dataset_params.NIMS_PER_CHUNK = 50;
    test_set = cell(1,1);
    imwrite(img, 'temp.bmp');
    test_set{1} = 'temp.bmp';
    test_set
    app_files = apply_all_exemplars(dataset_params, models, test_set, 'rephoto_test', [],...
        test_params);
    %result = load(app_files{ii});
 
   % grid = result.res{ii}.coarse_boxes;
   app_files
   if(length(app_files))
       
    mygrid = app_files(:,end);
    length(mygrid)
   
    if(length(mygrid) == 0)
        score = 0;
    else 
        score = abs(max(mygrid));
    end  
   else 
      score = 0;
   end 
    
end

image = img;
end 
%%
%for ii=1:length(cls)
 %       models = load_all_models(dataset_params, cls{ii},[models_name '-svm'],[],0,1);
  %      test_grid = load_result_grid(dataset_params, models, ...
   %                          'rephoto_test', app_files, test_params.thresh);
    %see_tops;
%end