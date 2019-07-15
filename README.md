# EgocentricBoundaryCells
Matlab code for egocentric boundary cell identification in freely behaving animals.
If you use this code, please reference the originating article:

To run, add these files to your Matlab directory. Then, create an struct with the following fields:

x - The animal's x position over time

y - Animals' y position over time

md - Movement direction (or head direction) in radians

spike - Binarized spike train 

ts - time stamp

All fields should be the same length (eg: Nx1 where N is the number of samples in the session)


Then, run:
```matlab
out = EgocentricRatemap(r); % where r is your behavioral/ephys struct
plotEBC(r, out)
```

Hinman, Chapman, and Hasselmo, “Neuronal Representation of Environmental Boundaries in Egocentric Coordinates.” Nature Communications, 2019. https://www.nature.com/articles/s41467-019-10722-y
