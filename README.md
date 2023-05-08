# Visible Light Computer Tomography Image Processing Project

*This project was conducted for an Image Processing course final project.*

Evaluation of a visible-light tomography scanner through an estimation of the signal-to-noise ration (SNR) and spatial resolution. It also conducts a linear regression to predict the Hounsfield Unit of a given tissue based on the image intensity. Finally, it contains an algorithm which detects the tissue shown on the image based on it's intensity, and segments foreign bodies found on the image.

## Reconstruction

It conducts a reconstruction of an image through the back-projection of an obtained sinogram, applying a frequency filter to said image. The sinogram matrix from filename is of N x X, where the N dimension represents the angle of proyection in degrees and the X dimension represents the displacement of proyection (width). The image is also a normalized float type, not 8-bit.

## Intensity and Hounsfield scale

Given an image, the phantom inside said image is segmented through a mask, and the the mean intensity of the phantom (d) is obtained by averaging the intensities of said phantom. In order to generate the mask, the image is preprocessed through applying a 4x4 average filter kernel 10 times and then binarizing the image with a given threshold. This process is repeated for phantoms of different densities meant to represent different tissues, as well as air (which Hounsfield unit is -1000 HU), to perform a regression with the obtained intensities and their corresponding Hounsfield units. The result of the regression model is an equation to calculate the Hounsfield unit of a scanned tissue based on it's intensity.

## SNR and Spatial Resolution

The signal-to-noise ration (SNR) of the image is calculated by generating an ideal image capture through the product of a mask with the shape of the phantom and the average intensity, which will work as the signal with no noise. The equation to calculate the SNR of an image can be seen [here.](https://www.researchgate.net/post/How_is_SNR_calculated_in_images)

To analyze the spatial resolution of the system, the linear spread function (LSF) and edge spread function (ESF) curves of the tomography scanner are obtained, as well as the full width at half maximum (FWHM) of the LSF curve to obtain the spatial resolution of the system. This is done through the reconstruction one angle from the image through retro-projection, removing noise in the change of intensities and defining a line in which intensity changes from a maximum to a minimum. After this, the  ESF curve is obtained as a linear vector of the intensities of the defined line and the LSF curve as the difference of said intensities, both normalized. Afterwards, the FWHM of the LSF curve is obtained by finding the limits at the 0.5 mark and obtaining the difference. The FWHM of the LSF curve will give the number of pixels required for the LSF curve to drop half of the maximum value, which indicates the number of pixmber of pixels required to identify an intensity change.

## Identification & Segmentation algorithm

The algorithm uses the intensity function to obtain the average intensity of the tissue, then uses the conversion equation from the input coefficients to obtain the Hounsfield units from the intensity and compares it to a database of known tissues and their average Hounsfield units to find the most similar tissue. The difference between Hounsfield units is used to calculate the similarity percentage of the tissue. It also conducts a pre-processing and masking process on the image, to later apply a Canny border detection algorithm, as well as finding circles of specific radius to search for foreign bodies in the image.
