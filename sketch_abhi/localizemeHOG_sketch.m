function [resstruct,t] = localizemeHOG_sketch(I, models, localizeparams)

tic
localizeparams.FLIP_LR = 0;
[rs1, t1] = localizemeHOGdriverBLOCK(I, models, localizeparams);
toc
resstruct = rs1;
t = t1;
return;

function [resstruct,t] = localizemeHOGdriverBLOCK(I, models, ...
                                             localizeparams)

N = length(models);
ws = cellfun2(@(x)x.model.w,models);
bs = cellfun(@(x)x.model.b,models)';

sbin = models{1}.model.init_params.sbin;
t = get_pyramid(I, sbin, length(models), localizeparams);
resstruct.padder = t.padder;
osThresh = [0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9];
% gt_bbs = cell2mat(cellfun(@(x) x.gt_box, models,'UniformOutput',false)');
% 
% hgs = cellfun(@(x) prod(x.model.hg_size), models);
% [mm lind] = min(hgs);
% [mm uind] = min(hgs);
% 
% [allbb1] = pad_and_get_all_bb(t,models{lind}.model.hg_size,sbin);
% [allbb2] = pad_and_get_all_bb(t,models{uind}.model.hg_size,sbin);
% oss1 = getosmatrix_bb(allbb1, models{lind}.gt_box);
% oss2 = getosmatrix_bb(allbb2, models{uind}.gt_box);
% keep = union(find(oss1>=min(osThresh)), find(oss2>=min(osThresh)));

for exid = 1:N
    exid
    sz = size(ws{exid});
    [allbb, alluv, alllvl, t] = pad_and_get_all_bb(t,sz,sbin);
%     oss = getosmatrix_bb(allbb, models{exid}.gt_box);
    oss = getosmatrix_bb1(allbb, models{exid}.gt_box);
    
    keepIds = find(oss>=min(osThresh));
    os = oss(keepIds);
    bbs = allbb(keepIds, :);
    uvs = alluv(keepIds,:);
    lvls = alllvl(keepIds);
    feats = zeros(prod(sz), length(lvls));
    
    for id = 1:length(lvls)
        feats(:,id) = reshape(...
            t.hog{lvls(id)}(uvs(id,1):uvs(id,1)+sz(1)-1, ...
            uvs(id,2):uvs(id,2)+sz(2)-1, :),[],1);
    end

    scores = ws{exid}(:)'*feats - bs(exid);
    %[sorted_scores, sorted_ind] = sort(scores, 'descend');
%     bbb = zeros(length(osThresh), 12);
    for o = 1:length(osThresh)
        ids = find(os>=osThresh(o));
        [score, ind] = max(scores(ids));
        if ~isempty(ind)
            bbb(o,1:4) = bbs(ids(ind(1)),:);        
            bbb(o,5:12) = 0;
            bbb(o,5) = 1;
            bbb(o,6) = exid;
            bbb(o,8) = lvls(ids(ind(1)));
            bbb(o,9) = uvs(ids(ind(1)),1);
            bbb(o,10) = uvs(ids(ind(1)),2);
            bbb(o,12) = score;
            ooo(o) = osThresh(o);
        else
            break;
        end
    end
  if (localizeparams.FLIP_LR == 1)
    bbb = flip_box(bbb,t.size);
    bbb(:,7) = 1;
  end
  resstruct.bbs{exid} = bbb;
  resstruct.oss{exid} = ooo;
end
resstruct.xs = cell(N,1);
fprintf(1,'\n');

function t = get_pyramid(I, sbin, N, localizeparams)
%Extract feature pyramid from variable I (which could be either an image,
%or already a feature pyramid)

if isnumeric(I)

  flipstring = '';
  if (localizeparams.FLIP_LR == 1)
    flipstring = '@F';
    I = flip_image(I);
  else    
    %take unadulterated "aka" un-flipped image
  end
  
  clear t
  t.size = size(I);

  fprintf(1,'Localizing %d in I=[%dx%d@%d%s]',N,...
          t.size(1),t.size(2),localizeparams.lpo,flipstring);

  %Compute pyramid
  [t.hog,t.scales] = featpyramid2(I, sbin, localizeparams);  
  t.padder = localizeparams.pyramid_padder;
  for level = 1:length(t.hog)
    t.hog{level} = padarray(t.hog{level}, [t.padder t.padder 0], 0);
  end
  
  minsizes = cellfun(@(x)min([size(x,1) size(x,2)]), t.hog);
  t.hog = t.hog(minsizes >= t.padder*2);
  t.scales = t.scales(minsizes >= t.padder*2);
  
  
  %if only_compute_pyramid == 1
  %  resstruct = t;
  %  return;
  %end
  
else
  fprintf(1,'Already found features\n');
  
  if iscell(I)
    if localizeparams.FLIP_LR==1
      t = I{2};
    else
      t = I{1};
    end
  else
    t = I;
  end
  
  fprintf(1,'Localizing %d in I=[%dx%d@%d]',N,...
        t.size(1),t.size(2),localizeparams.lpo);
end


function [allbb,alluv,alllvl,t] = pad_and_get_all_bb(t,hg_size,sbin)
%Extract all bounding boxes from the feature pyramid (and pad the pyramid)

allbb = cell(length(t.hog),1);
alluv = cell(length(t.hog),1);
alllvl= cell(length(t.hog),1);
for level = 1:length(t.hog)
  t.hog{level} = padarray(t.hog{level}, [t.padder t.padder 0], ...
                          0);
  curids = zeros(size(t.hog{level},1),size(t.hog{level},2));
  curids = reshape(1:numel(curids),size(curids));
  goodids = curids(1:size(curids,1)-hg_size(1)+1,1:size(curids,2)- ...
                   hg_size(2)+1);
  [rawuuu,rawvvv] = ind2sub(size(curids),goodids(:));
  uuu = rawuuu - 2*t.padder;
  vvv = rawvvv - 2*t.padder;
  
  bb = ([vvv uuu vvv+hg_size(2) uuu+hg_size(1)] -1) * ...
       sbin/t.scales(level) + 1;
  bb(:,3:4) = bb(:,3:4) - 1;
  
  allbb{level} = bb;
  alluv{level} = [rawuuu rawvvv];
  alllvl{level} = goodids(:)*0+level;
end
% alluv = cell2mat(alluv);
% allbb = cell2mat(allbb);
% alllvl = cell2mat(alllvl);
alluv = cat(1,alluv{:});
allbb = cat(1,allbb{:});
alllvl = cat(1,alllvl{:});

