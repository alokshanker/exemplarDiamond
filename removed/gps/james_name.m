function str = james_name(i)
%Given an integer index i, read in the location of the ith image
%returns a pathname for one of James Hays' Flickr images
N = 10;
i = double(i);
i1 = floor(i/N);
%i2 = double(mod(i,N));
file_list = dir('/home/aloks/masters-proj/Images/*.bmp');
str = file_list(i1).name;

%N = 592;
%i = double(i);
%i1 = floor(i/N);
%i2 = double(mod(i,N));

%filename = sprintf('indfile_%.5d.txt',i1);
%sss = textread(['/nfs/baikal/tmalisie/gps/names/' filename],'%s',i2+1);
%str = sss{i2+1};