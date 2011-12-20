addpath(genpath(pwd));
sketch_init;
%% RUN Actual Traning....

% efiles = exemplar_initialize(dataset_params, e_stream_set, ...
%         models_name, init_params);
% 
% models = load_all_models(dataset_params, 'sketches',models_name,efiles,1);
% 
% train_all_exemplars(dataset_params, models, train_set, mining_params, ...
%     training_function);
% 
% %%
% 
models = load_all_models(dataset_params, 'sketches',[models_name '-svm'],[],1,1);

%%

dataset_params.testset_name = 'sketch_benchmark_selected';
% models = models(1:3);
test_files = apply_sketches(dataset_params, models(2:2:end), test_set, ...
                                 dataset_params.testset_name , [], test_params);
% dataset_params,models,fg,setname,M,default_params,gt_function)
