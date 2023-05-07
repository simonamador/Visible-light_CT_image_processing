clc; clear all; close all;
%% Reconstruction of empty capture
% Define directory were images are located
directory = 'C:\Users\Simon\MATLAB\Projects\Image_processing\images\';

filename = [directory 'F' '.txt'];      % Generate filename of empy image
[s, img] = reconstruction(filename);    % Reconstruct image
d0 = intensity(img,0.2,'f');            % Obtain intesity value

% Show both sinogram and reconstruction
f = plot_image(s,img,{'Sinogram', 'Empty capture'});
set(f,'visible','on')

%% Reconstruction of three phantoms of sample tissues
% Names of previously defined tissue examples in phantom samples
DenseT = {'Spongial Bone (Child)', 'Muscle Tissue (Child)', 'Fat Tissue (Child)'};

d = zeros(1,3);             % Intensity array for preallocation
masks = zeros(3,100,100);   % Masks array for preallocation
snr = zeros(1,3);           % Signal-to-noise (SNR) array for preallocation

% Loops 3 times because of the three samples
for i =1:3
    filename = [directory 'Fd_' num2str(i) '.txt']; % Filename of sample
    [s, img] = reconstruction(filename);            % Reconstruct image
    f = plot_image(s,img,{'Sinogram', DenseT{i}});  % Plot sinogram and 
                                                    % reconstructed image
    [d(i), masks(i,:,:)] = intensity(img,0.5,'f');  % Obtain intensity of 
                                                    % the sample phantom
    snr(i) = SNR(img,0.5,d(i));                     % Obtain SNR of image
    set(f,'visible','on')                           % Show images
end
%% Regression of Hounsfield-intensity relation

f1 = figure('visible','off');           % New figure, not visible
y = [-1000 370.5 57 -142];              % Hounsfield values of 4 captures
lr = fitlm([d0 d],y);                   % Hounsfield-Intensity regression       
r2 = lr.Rsquared.Adjusted;              % R^2 value
rmse = lr.RMSE;                         % Root mean squared error
coef = table2array(lr.Coefficients);    % Coefficients of the regression 
                                        % equation

% Plot the regression model
scatter([d0 d],y,'k'), hold on          % Scatter plot of points
plot(lr), title('Linear Regression'),   % Regression model display

% Display R^2, RMSE, and regression equation through text
text(0.27, 750, {['R^2: ' num2str(r2)], ['RMSE: ' num2str(rmse)], ...
    ['Equation: ' num2str(coef(end,1)) 'x + (' num2str(coef(1,1)) ')']}, ...
    'Color','k', 'Fontsize',8)
xlabel('Intensity'); ylabel('Hounsfield Unit (HU)');
set(f1,'visible','on')                  % Show figure
%% Estimation of spatial resolution

% Obtain LSF, ESF, and FWHM through resolution_esf function
[lsf,esf,fwhm,f1,f2,f3] = resolution_esf([directory 'esf.txt']);
set(f1,'visible','on')  % Display one angle reconstruction
set(f2,'visible','on')  % Display ESF curve
set(f3,'visible','on')  % Display LSF curve and its FWHM

filename = [directory 'Rd1.txt'];   % Filename of phantom with line pattern
                                    % arranged at different separations 
                                    % between lines
                                    
[s, img] = reconstruction(filename);% Image reconstruction

% Show sinogram and reconstructed image
f = plot_image(s,img,{'Sinogram', 'Pattern Reconstruction'});
set(f,'visible','on')

%% Identification of tissue and foreign body recognition algorithm

filename = [directory 'Fd_obj2.txt'];   % Filename of example image of soft
                                        % tissue with a foreign object
[s, img] = reconstruction(filename);    % Image reconstruction

% Identification of tissue and foreign object segmentation algorithm
[tissue,per,f,mask,H] = identify_segment(img, coef);

% Show figure
set(f,'visible','on')