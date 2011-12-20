function [] = my_find_exemp(I, models)
% Capture NITER frames from the screen (run initialize_screenshot first!)
% Show detections from models and keep top TOPK images with those
% detections
% --inputs--
% NITER:      number of frames to capture
% [models]:   the models to fire in the screenshot
% [TOPK]:     the number of topk images to keep (default is NITER)
% --outputs--
% Is:         cell array of TOPK images
% xs:         best detections from models{1}
% scores:     the output detection scores
% Tomasz Malisiewicz (tomasz@cmu.edu)

NITER = 1;
TOPK = 10;
i=1;
xs = cell(0,1);
scores = zeros(0,1);
Is = cell(0,1);
bbs = cell(0,1);

Is{end+1} = I;
  
  if exist('models','var')
    
    localizeparams.thresh = -0.9;
    localizeparams.TOPK = 15;
    localizeparams.lpo = 5;
    localizeparams.SAVE_SVS = 1;
    
    tic
    [rs,t] = localizemeHOG(I,models,localizeparams);
    toc
    [coarse_boxes,scoremasks] = extract_bbs_from_rs(rs,models);
    
    %map GT boxes from training images onto test image
    bb = adjust_boxes(coarse_boxes,models);
    
    bb = nms_within_exemplars(bb,.5);
    
%     xraw = get_box_features(bb, size(M.C,1), M.neighbor_thresh);

%     res2 = apply_boost_M(xraw,bb,M);

%     if length(res2)>0
%       res2
%     end
    
%     bb(:,end) = res2;
    
%     bbs{end+1} = bb;
    bb = nms(bb,.5);
    if sum(size(rs.support_grid{1}))>0
      xs{end+1}= rs.support_grid{1}{1};
      scores(end+1) = rs.score_grid{1}(1);
    else
      xs{end+1} = models{1}.model.w(:)*0;
      scores(end+1) = -2.0;
    end
    
  end
  
  %just keep the TOPK images
  if length(xs) > TOPK
      [alpha,beta] = sort(scores,'descend');
      goods = beta(1:min(length(beta),TOPK));
      Is = Is(goods);
      xs = xs(goods);
      scores = scores(goods);
      bbs = bbs(goods);
  end

  clf
%   subplot(2,1,1)
  imagesc(I);
  titler = num2str(i);

  axis image
  axis off
  if size(bb,1)>0
  titler = [titler  ' ' num2str(bb(1,end))];
  title(titler);    
      bb = nms(bb,.5);
      sc = max(-1.0,min(1.0,(bb(:,end))));
      g = 1+floor(((sc+1)/2)*20);
      colors = jet(21);
      for i = 1:size(bb,1)
          col1 = colors(g(i),:);
          plot_bbox(bb(i,:),'',col1,col1);
      end
  end
  drawnow
  pause(0.01);

%%
return


ws = cellfun2(@(x)x.model.w,models);
bs = cellfun2(@(x)x.model.b,models);

xs = cell(0,1);
scores = zeros(0,1);
Is = cell(0,1);
bbs = cell(0,1);
figure(1)
%%%%%%%%%5 READ I HERE
Is{end+1} = I;

localizeparams.thresh = -1.0;
localizeparams.TOPK = 10;
localizeparams.lpo = 5;
localizeparams.SAVE_SVS = 1;

tic
[rs,t] = localizemeHOG(I,models,localizeparams);
toc

[coarse_boxes,scoremasks] = extract_bbs_from_rs(rs,models);
    
bb = adjust_boxes(coarse_boxes,models);    
bb = nms_within_exemplars(bb,.5);
    
bb = nms(bb,.5);
if sum(size(rs.support_grid{1}))>0
  xs{end+1}= rs.support_grid{1}{1};
  scores(end+1) = rs.score_grid{1}(1);
else
  xs{end+1} = models{1}.model.w(:)*0;
  scores(end+1) = -2.0;
end

clf
imagesc(I);
% titler = num2str(i);
titler = [];
axis image
axis off
if exist('models','var') && size(bb,1)>0
    %   titler = [titler  ' ' num2str(bb(1,end))];
else
  imagesc(I)
  axis image
  axis off
  h=title(titler);
  set(h,'FontSize',20);
  drawnow
  return;
end
title(titler);
if size(bb,1)>0
    bb = nms(bb,.5);
    sc = max(-1.0,min(1.0,(bb(:,end))));
    g = 1+floor(((sc+1)/2)*20);
    colors = jet(21);
    for i = 1:size(bb,1)
        col1 = colors(g(i),:);
        plot_bbox(bb(i,:)-400,'',col1,col1);
    end
  drawnow
end