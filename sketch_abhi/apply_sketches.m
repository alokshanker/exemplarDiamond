function allfiles = apply_sketches(...
    dataset_params,models,fg,setname,M,default_params)
% Apply a set of models (raw exemplars, trained exemplars, dalals,
% poselets, components, etc) to a set of images.  Script can be ran in
% parallel with no arguments.  After running script, use
% grid=load_result_grid(models) to load results.
%
% models: Input cell array of models (try models=load_all_models)
% M: The boosting Matrix (optional)
% curset: The PASCAL VOC image set to apply the exemplars to
%   ('trainval' or 'test')
%
% Tomasz Malisiewicz (tomasz@cmu.edu)

%Save results every NIMS_PER_CHUNK images

if length(fg) == 0
  allfiles = {};
  return;
end

NIMS_PER_CHUNK = dataset_params.NIMS_PER_CHUNK;

default_params.thresh = -100000;

setname = [setname '.' models{1}.cls];
lrstring = '';

baser = sprintf('%s/applied/%s-%s/',dataset_params.localdir,setname, ...
                models{1}.models_name);

if ~exist(baser,'dir')
  fprintf(1,'Making directory %s\n',baser);
  mkdir(baser);
end

%% Chunk the data into NIMS_PER_CHUNK images per chunk so that we
%process several images, then write results for entire chunk

inds = do_partition(1:length(fg),NIMS_PER_CHUNK);

% randomize chunk orderings
myRandomize;
ordering = randperm(length(inds));
allfiles = cell(length(ordering), 1);

for i = 1:length(ordering)

  ind1 = inds{ordering(i)}(1);
  ind2 = inds{ordering(i)}(end);
  filer = sprintf('%s/result_%05d-%05d.mat',baser,ind1,ind2);
  allfiles{i} = filer;
  filerlock = [filer '.lock'];

  if fileexists(filer) || (mymkdir_dist(filerlock) == 0)
    continue
  end

    res = cell(0,1);

  %% pre-load all images in a chunk
  fprintf(1,'Preloading %d images\n',length(inds{ordering(i)}));
  clear Is;
  Is = cell(1, length(inds{ordering(i)}));
  for j = 1:length(inds{ordering(i)})
    Is{j} = convert_to_I(fg{inds{ordering(i)}(j)});
  end
  
  for j = 1:length(inds{ordering(i)})
    index = inds{ordering(i)}(j);
    fprintf(1,'   ---image %d\n',index);
    Iname = fg{index};
    [tmp,curid,tmp] = fileparts(Iname);
    I = Is{j};
    starter = tic;
    [rs,t] = localizemeHOG_sketch(I, models, default_params);
    for q = 1:length(rs.bbs)
      if ~isempty(rs.bbs{q})
        rs.bbs{q}(:,11) = index;
        if length(rs.bbs{q}(1,:))==11
          fprintf(1,'keyboard at shorty\n');
          keyboard
        end
      end
    end
    coarse_boxes = cat(1,rs.bbs{:});
    oss = cat(2,rs.oss{:});
    if ~isempty(coarse_boxes)
      scores = coarse_boxes(:,end);
    else
      scores = [];
    end
    [aa,bb] = max(scores);
    fprintf(1,' took %.3fsec, maxhit=%.3f, #hits=%d\n',...
            toc(starter),aa,length(scores));
    extras = [];
    res{j}.coarse_boxes = coarse_boxes;
    res{j}.bboxes = coarse_boxes;
    res{j}.oss = oss;
    res{j}.index = index;
    res{j}.extras = extras;
    res{j}.imbb = [1 1 size(I,2) size(I,1)];
    res{j}.curid = curid;
  end
  
  % save results into file and remove lock file
  save(filer,'res');
  try
    rmdir(filerlock);
  catch
    fprintf(1,'Directory %s already gone\n',filerlock);
  end
  
end

[allfiles,bb] = sort(allfiles);
