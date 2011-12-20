function cls = getCLS
VOCinit;
clsss = dir(fullfile(VOCopts.localdir, 'exemplars'));
cls = {};
for i=3:length(clsss)
    a = strread(clsss(i).name,'%s','delimiter', '.');
    if isempty(strfind(a{1}, 'mined')==0)
        if ~ismember(a(1), cls)
            cls(end+1) = a(1);
        end
    end
end
end