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

If you use this code, please reference the originating article: Hinman, Chapman, and Hasselmo, “Neuronal Representation of Environmental Boundaries in Egocentric Coordinates.” Nature Communications, 2019. https://www.nature.com/articles/s41467-019-10722-y
