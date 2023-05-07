function [d, mask] = intensity(img,threshold,f)
%INTENSITY Returns the mean intensity from a phantom in an image
%   This function inputs a reconstructed image, a given threshold for
%   masking and a flag value 't' for true or f for 'false', and it returns
%   the mean intensity of the phantom (d) and the mask (mask) containing 
%   said phantom.

m = fspecial('average',4);                  % Defines average filter kernel
image = img;                                % Keeps original image
img = img/max(img(:));                      % Maximizes image contrast

% Applies average filter 10 times, impementing a symmetric padding.
for x = 1:10
    img = imfilter(img,m,'symmetric');
end

% Conditional to check if phantom / tissue is more intense than
% surroundings, which may be the case when foreign bodies (like tumours)
% are present. f = f: Phantom / tissue is more intense. Otherwise, phantom
% / tissue is less intense.

if f == 'f'                                       
    mask = imbinarize(img,threshold);       % Create mask through 
                                            % binarization (using input
                                            % threshold)
else
    mask = ~imbinarize(img,threshold);      % Create mask through the 
                                            % negative of binarization 
                                            % (using input threshold)
end

% Implement mask to get an image were everything but phantom equals zero
new = image.*mask;     

% Obtains mean intensity by dividing the sum of valuse by the sum of pixels
% higher than zero
d = sum(new(:))/numel(new(new>0));

% In case sum of intensity equals zero
if isnan( d )
    d = 0;
end
end

