function [lsf,esf,fwhm,f1,f2,f3] = resolution_esf(fname)
%RESOLUTION_ESF Estimates spatial resolution through ESF & LSF curves.
%   This function inputs the filename of an image with a sharp density 
%   change and returns the linear spread function (LSF) and edge spread
%   function (ESF) curves of the tomograph, as well as the full width at 
%   half maximum (FWHM) of the lsf curve to obtain the spatial resolution 
%   of the system. 
%
%   The function reconstructs one angle from the image through
%   retro-projection, removes noise in the change of intensities and
%   defines the line in which intensity changes from a maximum to a
%   minimum. After this, it defines the ESF curve as a linear vector of the 
%   intensities of the line and the LSF curve as the difference of said 
%   intensities, both normalized. Finally, it calculates the FWHM of the
%   LSF curve by obtaining the limits at the 0.5 mark and obtaining the 
%   difference. 
%
%   The function also returns figure 1, 2 and 3. Figure 1 displays the 
%   filtered image as well as the line of intensity change used to extract 
%   the ESF curve. Figure 2 displays the ESF curve. Figure 3 displays the
%   LSF curve, as well as the limits of the FWHM, a horizontal dotted line
%   at the half of the height mark, and the value of the FWHM in text.

delimiterIn = ',';  %Delimiter of the .txt matrix

sinogram = importdata(fname,delimiterIn);   % Imports the matrix                   
sinogram = uint8(sinogram);                 % Turns to 8-bit
sinogram = imcomplement(sinogram);          % Takes the complement 
                                            % (inverts colors)
                                                
x = sinogram(1,:);                          % Displacement of first angle
                                                
% Back-projection of one degree through the iradon function
img = iradon([x' x'], [0 0])/2;

% Normalization of the image, done by substracting the minimum and dividing
% by the range, not the maximimun, in order to maintain the ratio between
% pixels
img = (img-min(img(:)))/(max(img(:))-min(img(:)));

sz = size(img);                         % Size of image
x1 = round(sz(2)/2)-8; x2 = x1+10;      % Limits of noise
img(:,x1:x2) = [];                      % Noise removal

f1 = figure('visible','off');           % New figure, not visible

x1 = 9; x2 = 20;                        % Limits of intensity change
imshow(img); hold on                    % Show reconstructed angle
line([x1 x2], [20 20]), hold off        % Shows intenisty change line

esf = flip(img(1,x1:x2));               % Generates ESF
x = 0:size(esf')-1;                     % X vector of ESF
xq = 0:0.5:size(esf')-1;                % New interpolated X vector
esf = interp1(x,esf,xq);                % Applies interpolation
esf = esf/(max(esf)-min(esf));          % Normalization of ESF curve
lsf = diff(esf);                        % Calculates LSF as the derivative 
                                        % of the ESF curve
lsf = lsf/max(lsf);                     % Normalization of LSF curve

f2 = figure('visible','off');           % New figure, not visible
plot(0:size(esf')-1,esf)                % Plot ESF curve
xlabel('Pixels'); ylabel('Amplitute/Pixel'); title('ESF')

f3 = figure('visible','off');           % New figure, not visible
plot(0:size(lsf')-1,lsf), hold on       % Plot LSF curve
xlabel('Pixels');ylabel('Amplitute'); title('LSF'); 

limits = zeros(1,2);                    % Limits vector for preallocation
x = 1;                                  % Counteror for limits vector

% Loops through the lsf vector, checks if the value is equal to half of the
% curve height, or if it passes through half of the curve either through
% the rise or fall of the curve, and adds it to the limits vector 
for i = 2:size(lsf,2)
    if lsf(i)==0.5
        limits(x) = i;
        x = x+1;
    elseif (lsf(i-1) < 0.5 && lsf(i) > 0.5)
        limits(x) = i;
        x = x+1;
    elseif (lsf(i-1) > 0.5 && lsf(i) < 0.5)
        limits(x) = i;
        x = x+1;
    end
end

fwhm = limits(end)-limits(1);   % FWHM as difference of limits (width)
sz = size(lsf);                 % Size of the lsf vector

plot(0:size(lsf')-1,zeros(1,sz(2))+.5,'r--');   % Plot the 0.5 mark
plot(limits-1,zeros(1,2)+.5,'bo');              % Plot limits
text(.5,0.95,['FWHM: ' num2str(fwhm) ' pixels'])% Display FWHM
end

