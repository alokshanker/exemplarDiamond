function show_res(topboxes,I)

topboxes = topboxes(1:min(5,size(topboxes,1)),:);

%use colors where 'hot' aka red means high score, and 'cold' aka
%blue means low score
colors = jet(size(topboxes,1));
colors = colors(end:-1:1,:);

imagesc(I)

% PADDER = 100;
% Ipad = pad_image(I,PADDER);

for q = size(topboxes,1):-1:1
  plot_bbox(topboxes(q,:),'',colors(q,:))
end
axis image
axis off