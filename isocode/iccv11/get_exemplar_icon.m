function [Iex,Iexmask,Icb,Icbmask] = get_exemplar_icon(models, ...
                                                  index,flip,subind, ...
                                                  loadseg, VOCopts)
%Extract an exemplar visualization image (one from gt box, one from
%cb box) [and does flip if specified]
%Allows allows for the loading of a segmentation icon
%
%Tomasz Malisiewicz (tomasz@cmu.edu)

%Subind indicates which window to show (defaults to the base)
if ~exist('subind','var')
  subind = 1;
else
  flip = models{index}.model.bb(subind,7);
end

if ~exist('flip','var')
  flip = 0;
end

if ~exist('loadseg','var')
  loadseg = 1;
end

cb = models{index}.model.bb(subind,1:4);
d1 = max(0,1 - cb(1));
d2 = max(0,1 - cb(2));
d3 = max(0,cb(3) - models{index}.sizeI(2));
d4 = max(0,cb(4) - models{index}.sizeI(1));
mypad = max([d1,d2,d3,d4]);
PADDER = round(mypad)+2;

I = convert_to_I(models{index}.I);
mask = zeros(size(I,1),size(I,2));
g = models{index}.gt_box;
mask(g(2):g(4),g(1):g(3)) = 1;

if loadseg == 1 && exist('VOCopts','var')
  [I2, mask2] = load_seg(VOCopts,models{index});
  if numel(I2) > 0
    I = I2;
    mask = mask2;
  end
end

cb = models{index}.gt_box;    
Iex = pad_image(I, PADDER);
mask = pad_image(mask, PADDER);
cb = round(cb + PADDER);

Iex = Iex(cb(2):cb(4),cb(1):cb(3),:);
Iexmask = mask(cb(2):cb(4),cb(1):cb(3));

cb = models{index}.model.bb(subind,1:4);
Icb = pad_image(I, PADDER);
cb = round(cb + PADDER);
Icb = Icb(cb(2):cb(4),cb(1):cb(3),:);
Icbmask = mask(cb(2):cb(4),cb(1):cb(3));

if flip == 1
  Iex = flip_image(Iex);
  Icb = flip_image(Icb);
  Iexmask = flip_image(Iexmask);
  Icbmask = flip_image(Icbmask);
end

function [I, mask] = load_seg(VOCopts, model)

filer = sprintf('%s/%s/SegmentationObject/%s.png',VOCopts.datadir, ...
                VOCopts.dataset,model.curid);

filer_class = sprintf('%s/%s/SegmentationClass/%s.png',VOCopts.datadir, ...
                      VOCopts.dataset,model.curid);


cmap=VOClabelcolormap;

if ~fileexists(filer)
  Iex = [];
  Iexmask = [];
  return;
end
  
classes = {'aeroplane','bicycle','bird','boat','bottle','bus', ...
           'car','cat','chair','cow','diningtable','dog','horse', ...
           'motorbike','person','pottedplant','sheep','sofa', ...
           'train','tvmonitor'};

clsid = find(ismember(classes,model.cls));

has_seg = 1;
res = imread(filer);
res_class = imread(filer_class);
res_class = reshape(cmap(res_class(:)+1,:),size(res_class,1), ...
                    size(res_class,2),3);

mask = double((res==model.objectid));
I= res_class;

