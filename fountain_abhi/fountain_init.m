addpath(genpath(pwd));

%%  Dataset Params Like VOCinit (where to store etc.)
    
%devkitroot is where we write all the result files
dataset_params.dataset = 'peter_rephoto';

dataset_params.devkitroot = ['/home/aloks/masters-proj/exemplarSVM-abhi/'...
    'new_code/devkitroot-aloks' dataset_params.dataset];

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

%% Name Parameters (What to call the models?)
scenestring = 'exemplar';

%Choose a short string to indicate the type of training run we are doing
models_name = ['s.' scenestring];


%% How to initialize Exemplars?

%Choose Fixed-Frame initialization function, and its parameters
%init_function = @initialize_fixedframe_model;
%init_params.sbin = 8;nfs/onega_no_backups/users/ashrivas/datasets/new_rephoto
%init_params.hg_size = [8 8];

%Choose Goal-Cells initialize function, and its parameters
%150 is the no of hog cells that are allowed
init_params.goal_ncells = 150;
init_params.MAXDIM = 15;
init_params.sbin = 8;
init_params.init_type = 'goalsize';
%initializes exemplar according to parameters defined above
init_params.init_function = @initialize_goalsize_model;

%% Default Mining Parameters?

get_default_param_f = @get_default_mining_params;
default_mining_f = @get_default_mining_params_video;
training_function = @do_svm;
%Get the default mining parameters
mining_params = default_mining_f();

%% Setup Streams?
stream_f = @get_exemplar_stream_sketch;

% this path should have folders with images in it. Folder names are
% expected to be class/category names.
%images for which exemplars have to be created
folder = ['/home/aloks/masters-proj/dataset/'];
                        
%No of objects to select per frame..
N_Frame = 1;
e_stream_set = stream_f(dataset_params, folder, N_Frame);

%% Define the training set (neg, dowloaded set of randaom images)
%get the negative set for training1.0
%write your own function that returns the training settrain_set
files = dir('/home/aloks/masters-proj/Images/*.jpg')
pa = '/home/aloks/masters-proj/Images/'
train_set = cellfun(@(x) [pa x], {files.name}, 'UniformOutput', false);
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
% return;

%% RUN Actual Traning....
for i=1:length(cls)
    efiles = exemplar_initialize(dataset_params, e_stream_cls{i}, ...
        models_name, init_params)%andmark_fgs_rephoto
    models = load_all_models(dataset_params, cl s{i},models_name,efiles,1);
    train_all_exemplars(dataset_params, models, train_set, mining_params, ...
        training_function);
end

%% RUN TESTING
files = dir('/home/aloks/masters-proj/testset/*.jpeg');
pa = '/home/aloks/masters-proj/testset/';
test_set = cellfun(@(x) [pa x], {files.name}, 'UniformOutput', false);

for ii=1:length(cls) 
    models = load_all_models(dataset_params, cls{ii},[models_name '-svm'],[],1,1);
    dataset_params.NIMS_PER_CHUNK = 50;
    app_files = apply_all_exemplars(dataset_params, models, test_set, 'rephoto_test', [],...
        test_params);
end
%%
test_grid = load_result_grid(dataset_params, models, ...
                             'rephoto_test', app_files, test_params.thresh);
see_tops;
%%
for ii=1:length(cls)
        models = load_all_models(dataset_params, cls{ii},[models_name '-svm'],[],1,0);
        test_grid = load_result_grid(dataset_params, models, ...
                             'rephoto_test', app_files, test_params.thresh);
    see_tops;
end

