sketch_init;
models = load_all_models(dataset_params, 'sketches',[models_name '-svm'],[],1,1);
%Select only the full-image sketches
models = models(1:2:end);

%%
grid = load_result_grid_sketch(dataset_params,models,'sketch_benchmark');
n = length(grid);
largeMatrix = cell2mat(cellfun(@(x)[x.bboxes x.oss'], grid,'UniformOutput',false)');
%%
rootPath = '/nfs/onega_no_backups/users/ashrivas/current/benckmark_new_results/%d/';
for os = [0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9]
    osInd = (find((largeMatrix(:,end)==os)));
    osLarge = largeMatrix(osInd,1:12);
    for exid = 1:length(models)
       eInd = find(osLarge(:,6)==exid);
       if length(eInd)==0
           continue;
       end
       exemp = osLarge(eInd,:);  
       [scores, ranks] = sort(exemp(:,end),'descend');
       exemp(:,7) = ranks;

       new_ordering = ranks;
       mkdir(sprintf(rootPath, exid));
       file = sprintf('%s/0.%d_ordering.mat',sprintf(rootPath, exid), os*10);
    %    id11 = exid;
    %    htmlize_new;
       save(file, 'new_ordering');
    end

end