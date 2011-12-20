addpath(genpath(pwd));
%% Dataset Params Like VOCinit (where to store etc.)

%devkitroot is where we write all the result files
dataset_params.dataset = 'sketch_benchmark';

dataset_params.devkitroot = ['/nfs/onega_no_backups/users/ashrivas/'...
    'current/summer11/' dataset_params.dataset];

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
%init_params.sbin = 8;
%init_params.hg_size = [8 8];

%Choose Goal-Cells initialize function, and its parameters
init_params.goal_ncells = 100;
init_params.MAXDIM = 15;
init_params.sbin = 8;
init_params.init_type = 'goalsize';
init_params.init_function = @initialize_goalsize_model_wARwigg;

%% Default Mining Parameters?

% get_default_param_f = @get_default_mining_params;
default_mining_f = @get_default_mining_params_video;
training_function = @do_svm;
%Get the default mining parameters
mining_params = default_mining_f();

%% Setup Streams?
stream_f = @get_exemplar_stream_sketch;

folder = ['/nfs/onega_no_backups/users/ashrivas/datasets/sketch_bechmark/'...
    'benchmark/sketches/'];
                        
%No of objects to select per frame..
N_Frame = 1;
e_stream_set = stream_f(dataset_params, folder, N_Frame);

%% 
%get the negative set for training
neg_path = '/nfs/onega_no_backups/users/ashrivas/datasets/sketches/bg/';
files = dir([neg_path,'*.jpg']);
ss = struct2cell(files);
train_set = cellfun(@(x) [neg_path x], ss(1,:),'UniformOutput',false);
% make length atleast 10000
if length(train_set)<10000
    bg = get_james_bg(10000-length(train_set));
    train_set = cat(2, train_set, bg');
end
%% Define Test set for the benchmark dataset.
test_set = get_benchmark_fg();
test_gt_function = [];
test_params = get_default_mining_params;
test_params.thresh = -100000;

return;
%% RUN Actual Traning....

efiles = exemplar_initialize(dataset_params, e_stream_set, ...
        models_name, init_params);

models = load_all_models(dataset_params, 'sketches',models_name,efiles,1);

train_all_exemplars(dataset_params, models, train_set, mining_params, ...
    training_function);
