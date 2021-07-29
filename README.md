# EgocentricBoundaryCells
Matlab code for egocentric boundary cell identification in freely behaving animals.

To run, add these files to your Matlab directory. Then, create an struct with the following fields:

x - The animal's x position over time

y - y position over time

md - Movement direction (or head direction) in radians

spike - Binarized spike train 

ts - time stamp

All fields should be the same length (eg: Nx1 where N is the number of samples in the session). For the purposes of simplicity in the distributed code, we assume your behavioral variables are cleaned already. Additionally, distance output measures will be in the same measure as x & y (eg: pixels or cm, depending on your input dimensions), and "firing rates" will be per video frame (instead of Hz). 


Finally,to get egocentric responses, run:
```matlab
out = EgocentricRatemap(r); % where r is your behavioral/ephys struct
plotEBC(r, out)
```
## Parametric Generalized Linear Model
In an additional paper (AlexanderHasselmo2020), we designed a generalized linear model to test for significance of EBC tuning. For simplicity, the predictor here is angle and distance to the center of the environment, rather than to every point on the walls. This code lies in `ebcTest.m` and relies on the additional "pippin"(https://github.com/hasselmonians/pippin) package, which simply wraps Matlab's glmfit functionality. 


## Credit
If you use this code, please reference the originating article: Hinman, Chapman, and Hasselmo, “Neuronal Representation of Environmental Boundaries in Egocentric Coordinates.” Nature Communications, 2019. https://www.nature.com/articles/s41467-019-10722-y

If you utilize the statistical test, please additionally cite the paper it was created for: Andrew S. Alexander, Lucas C. Carstensen, James R. Hinman, Florian Raudies, G. William Chapman and Michael E. Hasselmo. "Egocentric boundary vector tuning of the retrosplenial cortex". Science Advances, February 2020. https://advances.sciencemag.org/content/6/8/eaaz2322.abstract
