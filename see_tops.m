    % function perform_calibration(grid, models, bg, dataset_params,sett)
bg = test_set;
sett='rephoto_test';
grid = test_grid;
%if enabled, do NMS, if disabled return raw detections
DO_NMS = 1;

%only keep detections that have this overlap score with the entire image
for OS_THRESH = [0 0.4 0.6];

if OS_THRESH > 0
  fprintf(1,'WARNING: only keeping detections above OS threshold: %.3f\n',...
          OS_THRESH);
end

% if enabled, display images
display = 1;

% if display is enabled and dump_images is enabled, then dump images into DUMPDIR
dump_images = 1;

DUMPDIR = sprintf('%s/%s/%s_os0.%d/',dataset_params.wwwdir, sett,cls{ii}, OS_THRESH*10);
if ~exist(DUMPDIR,'dir')
  mkdir(DUMPDIR);
end
% show A NxN grid of top detections (if display is turned on)
SHOW_TOP_N_SVS = 10;

% if nargin < 1
%   fprintf(1,'Not enough arguments, need at least the grid\n');
%   return;
% end

targets = 1:length(models);


% cls = models{1}.cls;
if 1
    for i = 1:length(grid)    
      if mod(i,100)==0
        fprintf(1,'.');
      end
      cur = grid{i};

      %do os pruning, BEFORE NMS!
      if OS_THRESH > 0
        curos = getosmatrix_bb(cur.bboxes(:,1:4),cur.imbb);
        cur.bboxes = cur.bboxes(curos>=OS_THRESH,:);
      end

      if size(cur.bboxes,1) >= 1
        cur.bboxes(:,5) = 1:size(cur.bboxes,1);    
        if DO_NMS == 0
          fprintf(1,'HACK: disabled NMS!\n');
        else
          cur.bboxes = nms_within_exemplars(cur.bboxes,.5);
        end
        if length(cur.extras)>0
          cur.extras.os = cur.extras.os(cur.bboxes(:,5),:);
        end
      end

      cur.bboxes(:,5) = grid{i}.index;

      bboxes{i} = cur.bboxes;

      %if we have overlaps, collect them
      if length(cur.extras) > 0
        %use all objects as ground truth
        goods = 1:length(cur.extras.cats);
        exids = cur.bboxes(:,6);

        if length(goods) == 0
          os{i} = zeros(size(bboxes{i},1),1);
        else
          curos = cur.extras.os(:,goods);
          os{i} = max(curos,[],2);
        end    
      else
        os{i} = zeros(size(bboxes{i},1),1);    
      end

      scores{i} = cur.bboxes(:,7)';
    end
  
    ALL_bboxes = cat(1,bboxes{:});
    ALL_os = cat(1,os{:});
end

for exid = 1:length(models)
  fprintf(1,'.');
  hits = find(ALL_bboxes(:,6)==exid);
  all_scores = ALL_bboxes(hits,end);
  all_os = ALL_os(hits,:);

  if (display == 0)
    continue
  end
      
  figure(1)
  clf
  
  %subplot(2,2,1)
  if isfield(models{exid},'I')
  Iex = im2double(imread(models{exid}.I)); 
  bbox = models{exid}.model.bb;
  Iex = pad_image(Iex,300);
  bbox = bbox+300;
  bbox = round(bbox);
  Iex = Iex(bbox(2):bbox(4),bbox(1):bbox(3),:);
  
  show1 = Iex;

  hogpic = (HOGpicture(models{exid}.model.w));
  
  NC = 200;
  colorsheet = jet(NC);
  dists = hogpic(:);    
  dists = dists - min(dists);
  dists = dists / (max(dists)+eps);
  dists = round(dists*(NC-1)+1);
  colors = colorsheet(dists,:);
  show2 = reshape(colors,[size(hogpic,1) size(hogpic,2) 3]);

  %axis image
  %axis off
  %title('Learned Template')
  %drawnow
    
  all_bb = ALL_bboxes(hits,:);
  [alpha,beta] = sort(all_bb(:,end),'descend');

  NNN = SHOW_TOP_N_SVS;

  clear III
  clear IIIscores
  for aaa = 1:NNN*NNN
    III{aaa} = zeros(100,100,3);
    IIIscores(aaa) = -10;
  end
  
  
  for aaa = 1:NNN*NNN
    fprintf(1,'.');
    if aaa > length(beta)
      break
    end
    curI = convert_to_I(bg{all_bb(beta(aaa),5)});   
    %curI = imread(sprintf(VOCopts.imgpath,sprintf('%06d', ...
    %                                              all_bb(beta(aaa),5))));
    %curI = im2double(curI);
    
    bbox = all_bb(beta(aaa),:);
 
    curI = pad_image(curI,300);
    bbox = bbox+300;
    bbox = round(bbox);

    %figure(1)
    %imagesc(curI)
    %drawnow
    try
      Iex = curI(bbox(2):bbox(4),bbox(1):bbox(3),:);
    catch
      Iex = rand(100,100,3);
    end
    Iex = max(0.0,min(1.0,Iex));
    III{aaa} = Iex;
    IIIscores(aaa) = all_bb(beta(aaa),end);
  end
  
  sss = cellfun2(@(x)size(x),III);
  meansize = round(mean(cat(1,sss{:}),1));

  III = cellfun2(@(x)min(1.0,max(0.0,imresize(x,meansize(1:2)))), ...
                 III);  
  
  III2 = cell(1,length(III)+2);

  III2(3:end) = III;

  III2{1} = imresize(show1,meansize(1:2));
  III2{2} = imresize(show2,meansize(1:2));
  III = III2(1:(end-2));
  

  III = reshape(III,[NNN NNN]);
  for i = 1:NNN
    Irow{i} = cat(1,III{i,:}); 
  end
  
  I = cat(2,Irow{:});
  imshow(I)
  title(sprintf('Top scores %.3f %.3f %.3f',IIIscores(1),IIIscores(2),IIIscores(3)));
  if dump_images == 1
    figure(1)
    filer = sprintf('%s/result.%d.%s.%s.png', DUMPDIR, ...
                    exid,sett,models{exid}.models_name);
    set(gcf,'PaperPosition',[0 0 20 20]);
    print(gcf,filer,'-dpng');
    
  else
    pause
  end  
end
end
end
