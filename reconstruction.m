function [sinogram,img] = reconstruction(filename)
%RECONSTRUCTION: Reconstructs CT image from .txt file.
%   This function inputs a file name and returns the sinogram
%   extracted from the file and the reconstruced image. It conducts iradon
%   for the back-projection of the image, applying a frequency filter to
%   said image. The sinogram matrix from filename is of N x X, where the N
%   dimension represents the angle of proyection in degrees and the X
%   dimension represents the displacement of proyection (width).

delimiterIn = ',';  %Delimiter of the .txt matrix

sinogram = importdata(filename,delimiterIn);    % Imports the matrix                   
sinogram = uint8(sinogram);                     % Turns to 8-bit
sinogram = imcomplement(sinogram);              % Takes the complement 
                                                % (inverts colors)

sz = size(sinogram);                            % Size of sinogram
theta = (0:sz(1)-1)*(180/sz(1));                % Degrees vector, of size
                                                % N were N = 180 degrees

% Back-projection through the iradon function, applying a spline
% interpolation and a Ram-Lak frequency filter.
img = iradon(sinogram', theta,'spline','Ram-Lak',sz(1));

% Normalization of the image, done by substracting the minimum and dividing
% by the range, not the maximimun, in order to maintain the ratio between
% pixels
img = (img-min(img(:)))/(max(img(:))-min(img(:)));
end

