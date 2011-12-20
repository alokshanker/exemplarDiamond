function fg = get_exemplar_stream_folder(VOCopts, folder, N_PER_FRAME)
%Create an exemplar stream, such that each element fg{i} contains
%these fields: (I, bbox, cls, curid, [objectid], [anno])
%Make sure the exemplar has a segmentation associated with it if
%must_have_seg is provided

set_name = VOCopts.dataset;
dirs = struct2cell(dir(folder));
dirs = dirs(1,3:end);

endings = {'jpg','png','gif','JPEG','JPG', 'jpeg', 'bmp'};
basedir = sprintf('%s/models/streams/',VOCopts.localdir);
if ~exist(basedir,'dir')
  mkdir(basedir);
end

if ~exist('N_PER_FRAME', 'var')
    N_PER_FRAME = 0;
end
fg = cell(1,0);

for clsID = 1:length(dirs)
	cls = dirs{clsID};        
    fg_cls = cell(1,0);
    streamname = sprintf('%s/%s-%s-exemplar.mat',basedir,set_name,cls);
    if fileexists(streamname)
%         keyboard
        fprintf(1,'Loading %s\n',streamname);
        fgg = load(streamname, 'fg_cls');
        fg = cat(2, fg, fgg.fg_cls);
        continue;
    end
    
    exFolder = fullfile(folder, cls);
    files = cellfun2(@(x)dir([exFolder '/*.' x]), endings);
    files = cat(1,files{:});
    image_names = cellfun2(@(x)[exFolder '/' x],{files.name});
    
    for i = 1:length(image_names)
        Ibase = convert_to_I(image_names{i});
        fprintf(1,'.');
        
        if N_PER_FRAME    
             %% Get selection regions
            while 1
                figure(1)
                clf
                imagesc(Ibase)
                axis image
                axis off
                title(sprintf('IM %d/%d, Select Rectangular Region :', i,...
                            length(image_names)));
                fprintf(1,['Click a corner, hold until diagonally opposite corner,' ...
                         ' and release\n']);
                h = imrect;
                bbox = getPosition(h);

                if (bbox(3)*bbox(4) < 50)
                    fprintf(1,'Region too small, try again\n');
                else
                    break;
                end
            end

            bbox(3) = bbox(3) + bbox(1);
            bbox(4) = bbox(4) + bbox(2);
        else
            bbox = [1 1 size(Ibase,2) size(Ibase,1)];
        end
        bbox = clip_to_image(bbox, [1 1 size(Ibase,2) size(Ibase,1)]);
        bbox = round(bbox);
        plot_bbox(bbox)
        
        res.I = image_names{i};
        res.bbox = bbox;
        res.cls = cls;
        res.curid = 1;
        res.objectid = 1;
        
        fg_cls{end+1} = res;
    end
    save(streamname,'fg_cls');
    fg = cat(2, fg, fg_cls);
end