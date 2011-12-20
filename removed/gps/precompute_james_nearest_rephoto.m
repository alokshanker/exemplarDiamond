function res = precompute_james_nearest_rephoto
%Load landmark/name/fg/bg sets

% filer = '/nfs/onega_no_backups/users/ashrivas/siggraph2011/new_set.mat';
% filer = '/nfs/onega_no_backups/users/ashrivas/iccv2011/landmark_fgs_new.mat';
filer = '/nfs/onega_no_backups/users/ashrivas/landmark_fgs_rephoto.mat';
if fileexists(filer)
  res = load(filer);
  return;
end

%Get gps coordinates from wikipedia search
landmark_gps = cell(0,1);
landmark_name = cell(0,1);

landmark_fg = cell(0,1);
landmark_bg = cell(0,1);

landmark_gps{end+1} = [48.853033; 2.34969]; %notre dame
landmark_name{end+1} = 'notre_dame'; %'Notre Dame de Paris';

landmark_gps{end+1} = [27.174799; 78.042111]; % taj mahal
landmark_name{end+1} = 'taj_mahal';%'Taj Mahal';

landmark_gps{end+1} = [48.8583; 2.2945]; % Eiffel Tower
landmark_name{end+1} = 'eiffel_tower';%'Eiffel Tower';

landmark_gps{end+1} = [43.783333; 11.25]; 
landmark_name{end+1} = 'florence';%'florence';

landmark_gps{end+1} = [45.4375; 12.335833]; % Venice City
landmark_name{end+1} = 'venice';%'Venice City';

landmark_gps{end+1} = [48.876944; 2.359167];
landmark_name{end+1} = 'gare_de';%'gare de paris';

landmark_gps{end+1} = [48.876944; 2.324444];
landmark_name{end+1} = 'gare_saint_lazare';

landmark_gps{end+1} = [59.9364; 30.3022]; 
landmark_name{end+1} = 'horseman';%'the bronze horseman russia';

landmark_gps{end+1} = [48.8738; 2.295];
landmark_name{end+1} = 'arc_de';

landmark_gps{end+1} = [43.296386; 5.369954];
landmark_name{end+1} = 'marseille';%france

landmark_gps{end+1} = [48.8675; 2.329444];
landmark_name{end+1} = 'place_vendome';%'Place Vendôme


landmark_gps{end+1} = [48.871944; 2.331667];
landmark_name{end+1} = 'palais_garnier';%


landmark_gps{end+1} = [59.9341; 30.3062];
landmark_name{end+1} = 'stisaac_cathedral';%

landmark_gps{end+1} = [59.9343; 30.3245]; % Venice City
landmark_name{end+1} = 'kazan';%'Venice City';

%Load gps coordinates of all 6.5 million images
load all_gps.mat
gps = double(gps);

for i = 1:length(landmark_name)
  fprintf(1,'%d/%d\n',i,length(landmark_name));
  
  %Get distances between gps of all images to to landmark gps
  distances = get_gps_ball(gps,landmark_gps{i});
  
  %Take top 10000 closest images to landmark
  [aa,bb] = sort(distances);
  
  %"fg" are the close images
  fg = bb(1:2:10000);
  %"bg" are the faraway images (randomly dispersed from all far images)
  bg = bb(1000000:end);
  subinds = round(linspace(1,length(bg),4000));
  bg = bg(subinds);
  
  landmark_fg{end+1} = fg;
  landmark_bg{end+1} = bg;  
end

save(filer,'landmark_gps','landmark_name','landmark_fg', ...
     'landmark_bg');

res.landmark_gps = landmark_gps;
res.landmark_name = landmark_name;
res.landmark_fg = landmark_fg;
res.landmark_bg = landmark_bg;
