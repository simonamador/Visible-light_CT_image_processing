function [SNR] = SNR(img,threshold,d)
%SNR Obtains the signal-to-noise ratio from an image.
%   This function inputs a reconstructed image, a given threshold for
%   masking and the average intensity of the phanton in the image (d), and
%   returns the signal-to-noise ratio (SNR) of the imaging system for a 
%   given image.

m = fspecial('average',4);                  % Defines average filter kernel
image = img;                                % Keeps original image
img = img/max(img(:));                      % Maximizes image contrast

% Applies average filter 10 times, impementing a symmetric padding.
for x = 1:10
    img = imfilter(img,m,'symmetric');
end

mask = imbinarize(img,threshold);           % Create mask through 
                                            % binarization (using input
                                            % threshold)

% Generate the ideal image by the product of the mask and average intensity
% of phantom, used as the pure signal
signal = mask.*d;

% Calculate the SNR, were the noise is the difference of the ideal image
% and the image obtained, and the SNR is equal to the squared sum of all 
% pixels from the pure signal divided by the square sum of all pixels from 
% the noise. Converted to decibels

SNR = 10*log10(sum(signal.^2,'all')/sum((signal-image).^2,'all')); % dB
end

