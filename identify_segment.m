function [tissue,per,f,mask,H] = identify_segment(image, coef)
%IDENTIFY_SEGMENT Identifies tissue in image and segments foreign bodies
%   This function inputs an image and a coefficient matrix of a linear
%   equation which converts intensity to Hounsfield scale, and returns the 
%   identified tissue in the image and the similarity percentage between
%   the tissue in the image and the ideal tissuem, as well as a figure with
%   the original image with a black circle segmenting the foreign body in
%   the tissue.
%
%   The function uses the intensity function to obtain the average
%   intensity of the tissue, then uses the conversion equation from the
%   input coefficients to obtain the Hounsfield units from the intensity
%   and compares it to a database of known tissues and their average
%   Hounsfield units to find the most similar tissue. The difference
%   between Hounsfield units is used to calculate the similarity percentage
%   of the tissue. It also conducts a pre-processing and masking process on
%   the image, to later apply a Canny border detection algorithm, as well
%   as the findcircles function to search for foreign bodies in the image.
%
%   The function also returns the mask from the first intensity function,
%   and the value of Hounsfield units of the tissue in the image.

% Array containing the names of studied tissues 
tissues = {'Skin Tissue (Child)', 'Skin Tissue (Adult)', ... 
    'Fat Tissue (Child)', 'Fat Tissue (Adult)', 'Muscle Tissue (Child)', ... 
    'Muscle Tissue (Adult)', 'Spongial Bone (Child)', ...
    'Spongial Bone (Adult)', 'Compact Bone (Child)', ... 
    'Compact Bone (Adult)', 'Enamel (Child)', 'Enamel (Adult)', ... 
    'Soft Tissue', 'Bone'};

% Array containing the respective Hounsfield units of the previous array
hounsfield = [-484 -447.5 -142 -128 57 65 370.5 404.5 1392 1325 2556.5 ...
    2201.5 -237.5 1648.5];

[d, mask] = intensity(image,0.4,'t');   % Obtain the intensity value of the
                                        % tissue
H = d*coef(end,1) + coef(1,1);          % Calculate the Hounsfield units

[val,idx]=min(abs(hounsfield-H));   % Obtain the minimum difference 
                                    % between known hounsfield values 
                                    % and the tissue's value

tissue=tissues(idx);                % Use index to obtain the tissue name

% Obtain the similarity percentage with the difference of values
if val == 0
    per = 1;                % Perfect match
else
    per = 1-abs(val/H);     % Similarity percentage as the complement of
                            % difference percentage
end

O1 = image;                                 % New image to alter
m = fspecial('average',[4 4]);              % Defines average filter kernel

% Applies average filter and median filter twice to reduce noise
for i =1:2
    O1 = medfilt2(O1, [3 3], 'symmetric'); 
    O1 = imfilter(O1,m);
end

O1 = O1/max(O1(:));                 % Increase contrast to a maximum
segment = imbinarize(O1,0.85);      % Generate mask through binarization,
                                    % threshold aims to separate foreign
                                    % object of high intensity

segment = edge(segment,'Canny');    % Border detection through Canny

%Find circles of a known radius range to find the foreign body in the image
[centers, radii] = imfindcircles(segment, [1 2], 'Sensitivity', 0.95, 'EdgeThreshold',0.5, ...
    'ObjectPolarity', "dark");

f = figure('visible', 'off');       % New figure, not visible
imshow(image,[]), hold on           % Show original image

% Plot found circles with 10 more pixels of radius, so circles surround
% foreign bodies
viscircles(centers(1,:), radii(1)+10, 'Color', 'k');

% Display obtained Hounsfiel, Tissue and Similarity Percentage values
text(5, 20, {['Hounsfield: ' num2str(H) ' HU'], ['Tissue: ' tissue{1}], ... 
    ['Percentage: ' num2str(per*100) '%']}, ...
    'Color','w', 'Fontsize',8)
end

