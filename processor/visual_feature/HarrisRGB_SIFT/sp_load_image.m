function I = sp_load_image(image_fname)
image_fname
I = imread(image_fname);
I = im2double(I);

