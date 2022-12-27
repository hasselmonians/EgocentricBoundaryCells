%% Whitlock style self-motion ratemaps; Computed with heading differnce.
function [ratMoveAngDist] = ...
    ratDisplacement(posGood, allEvents, moveDir, sampFreq, scale)

%2D ratemap smoothing function 
[sg] = smoothFunction(3,1.25);
% pxPerCm = (125/scale)/scale/4;

%% First, isolate position data during runs. Yields n x 8 matrix where n is
% the total number of positions across all runs. Column 1 is the index of 
% the position (from 'posGood', position data matrix with tracking fixed),
% column 2 is time, and the columns 3-8 contain x and y values in allocentric 
% space as follows: 3-4 = red light; 5-6 = green light (laser); 7-8=blue light.

clear ratPos laserRatPos

% [scale] = spatialScaleFinder([posGood(:,1) posGood(:,2)], 125);

ratPosMu(:,1) = posGood(:,1).*(scale);
ratPosMu(:,2) = posGood(:,2).*(scale);

oneHund = sampFreq/10;

% %% Calculate rat heading direction    
% clear ratHD
% [ratHD] = moveHD(ratPosMu(:,1),ratPosMu(:,2));
% 
% %% Compute heading difference between current position and postion 100ms in future
% rH = (wrapTo2Pi(ratHD(1:length(ratHD)-(oneHund-1),1))); 
% rHF = (wrapTo2Pi(ratHD(oneHund:length(ratHD),1)));
% headDiff = circ_dist(rHF,rH); 
% headDiff = headDiff.*-1; % Flip heading diffs 

%% Calculate heading difference between current position and position 100ms in future
rH = (wrapTo2Pi(moveDir(1:length(moveDir)-(oneHund),1))); 
rHF = (wrapTo2Pi(moveDir(oneHund+1:length(moveDir),1)));
headDiff = (circ_dist(rHF,rH));
headDiff = headDiff.*-1;

%% Compute dist between current position and position 100ms in future
xDiff = (ratPosMu(oneHund+1:end,1)-ratPosMu(1:length(ratPosMu)-(oneHund),1));
yDiff = (ratPosMu(oneHund+1:end,2)-ratPosMu(1:length(ratPosMu)-(oneHund),2));
rhoDist = sqrt(xDiff.^2+yDiff.^2);

ratMoveAngDist = [headDiff, rhoDist];


end




