function [f] = plot_image(img1,img2, titles)
%PLOT_IMAGE: Plots a sinogram and its reconstructed image through subplots.
%   This function inputs two images (matrices) and a cell array containing
%   the titles of the images, and returns a figure containing the ploted
%   images. It takes the images and proceeds to plot them through the
%   imshow() function. First image must be a sinogram, and is plotted with
%   a colorbar. Second image is the reconstruced image.

f = figure('visible', 'off');   % New figure, not visible
subplot(1,2,1)
imshow(img1,[]); colorbar;      % Display sinogram with colorbar
title(titles(1))                % First title from title array
subplot(1,2,2)
imshow(img2,[])                 % Display reconstructed image
title(titles(2))                % Second title from title array
end

