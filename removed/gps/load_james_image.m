function I = load_james_image(i)
%Given an integer index, load an image from james' dataset
NMAX = 6471706;
if i > NMAX || i <=0
  fprintf(1,'Wrong dimensions of i\d');
  I = zeros(100,100,3);
else
  I = imread(['/home/aloks/masters-proj/Images/' ...
              james_name(i)]);
end

