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

Is = cell(0,1);


Is{end+1} = I;
  
if exist('models','var')
    localizeparams = get_default_mining_params_video();
    localizeparams.FLIP_LR = 0;
    localizeparams.thresh = -0.8;
    localizeparams.TOPK = 5;
    localizeparams.lpo = 5;
    localizeparams.SAVE_SVS = 0;

    starter = tic;
    [rs,t] = localizemeHOG(I,models,localizeparams);

    coarse_boxes = cat(1,rs.bbs{:});
    if ~isempty(coarse_boxes)
        scores = coarse_boxes(:,end);
    else
        scores = [];
    end
    [aa,bb] = max(scores);
    fprintf(1,' took %.3fsec, maxhit=%.3f, #hits=%d\n',...
            toc(starter),aa,length(scores));
    
    % Transfer GT boxes from models onto the detection windows
    boxes = adjust_boxes(coarse_boxes,models);
    if 0
        if (default_params.MIN_SCENE_OS > 0.0)
          os = getosmatrix_bb(boxes,[1 1 size(I,2) size(I,1)]);
          goods = find(os>=default_params.MIN_SCENE_OS);
          boxes = boxes(goods,:);
          coarse_boxes = coarse_boxes(goods,:);
        end
    end

    if size(boxes,1)>=1
        boxes(:,5) = 1:size(boxes,1);
    end
    
    if numel(boxes)>0
        [aa,bb] = sort(boxes(:,end),'descend');
        boxes = boxes(bb,:);
    end
 
    boxes = nms_within_exemplars(boxes,.5);

%        ONLY SHOW TOP 5 detections or fewer
%     boxes = boxes(1:min(size(boxes,1),8),:);

    if size(boxes,1) >=1
        figure(1)
        clf
%         show_hits_figure(models, boxes, I);
        show_res(boxes, I);
        title(['top score: ' num2str(max(boxes(:,end)))]);
%         drawnow
      else
        figure(1)
        clf
        imagesc(I)
        axis image
        axis off
%         drawnow
        title('No detections in this Image');
     end
  drawnow
%   pause(0.001);
end

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