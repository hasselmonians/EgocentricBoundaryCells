function [model, glmSummary, model_noConj, model_simp] = ebcTest(root, res, QP)

s = warning('OFF', 'stats:glmfit:IllConditioned'); % for .o sanity

if exist('res','var')
    if ~isempty(res)
        cel = root.cel;
        root = Resample(root, res);
        root.cel = cel;
    end
end

clear xvec yvec p md
ep = root.epoch;
root.epoch = [-inf inf];
xvec = CMBHOME.Utils.nanInterp(root.b_x,'spline');
yvec = CMBHOME.Utils.nanInterp(root.b_y,'spline');

p = CMBHOME.Utils.speed_kalman(xvec, yvec, root.fs_video);
md = p.vd;

root.epoch = ep;

%%
if ~exist('QP','var')
    brx = root.b_x; bry = root.b_y;
    
    p = [-1000 -1000];
    d = (brx-p(1)).^2 + (bry-p(2)).^2;
    [~,ind] = min(d);
    ll = [brx(ind) bry(ind)];

    p = [1000 -1000];
    d = (brx-p(1)).^2 + (bry-p(2)).^2;
    [~,ind] = min(d);
    lr = [brx(ind) bry(ind)];

    p = [1000 1000];
    d = (brx-p(1)).^2 + (bry-p(2)).^2;
    [~,ind] = min(d);
    ur = [brx(ind) bry(ind)];

    p = [-1000 1000];
    d = (brx-p(1)).^2 + (bry-p(2)).^2;
    [~,ind] = min(d);
    ul = [brx(ind) bry(ind)];


    QP = [ll;lr;ur;ul];
end

%% get self-motion predictors
[tempDisp] = ...
ratDisplacement([root.x,root.y],[1 size(root.ind,1)], md(root.ind), root.fs_video, root.spatial_scale);
tempDisp(:,1) = CMBHOME.Utils.nanInterp(tempDisp(:,1));
tempDisp(:,2) = CMBHOME.Utils.nanInterp(tempDisp(:,2));
ratMoveAngDist = nan(length(root.ind),2);
ratMoveAngDist(1:size(tempDisp),:) = tempDisp;
%ratMoveAngDist(1:5,:) = repmat(ratMoveAngDist(6,:),5,1);
%ratMoveAngDist(end-4:end,:) = repmat(ratMoveAngDist(end-5,:),5,1);

%% bearing and distance to center of the environent

xloc = ((max(QP(:,1)) - min(QP(:,1)))/2) + min(QP(:,1));
yloc = ((max(QP(:,2)) - min(QP(:,2)))/2) + min(QP(:,2));

centerDis = sqrt((xvec - xloc).^2 + (yvec - yloc).^2);
centerDis = centerDis(root.ind);
%centerDis = normalize(centerDis);

hd = [0; atan2(diff(yvec),diff(xvec))];   % use this for heading
hd = wrapTo2Pi(hd);
hd = hd(root.ind);

centerAng = wrapToPi(atan2(yloc-yvec(root.ind), xloc-xvec(root.ind)) - hd);


%% build up model
clear model
model = Pippin.Model(root);
model = Pippin.Predictors.Other(model,'Movementdirection',[cos(md(root.ind)) sin(md(root.ind))]);
model = Pippin.Predictors.Place(model);
model = Pippin.Predictors.Speed(model);
model = Pippin.Predictors.Other(model,'angularDisplacement',ratMoveAngDist(:,1));
model = Pippin.Predictors.Other(model, 'centerDis', [centerDis centerDis.^2]);
model = Pippin.Predictors.Other(model, 'centerAng', [sin(centerAng) cos(centerAng)]);
model = Pippin.Predictors.Other(model, 'centerConj', [sin(centerAng).*centerDis cos(centerAng).*centerDis]);

model = model.genModels();
glmSummary = model.Summary;

% No Conjunctive
model_noConj = Pippin.Model(root);
model_noConj = Pippin.Predictors.Other(model_noConj,'Movementdirection',[cos(md(root.ind)) sin(md(root.ind))]);
model_noConj = Pippin.Predictors.Place(model_noConj);
model_noConj = Pippin.Predictors.Speed(model_noConj);
model_noConj = Pippin.Predictors.Other(model_noConj,'angularDisplacement',ratMoveAngDist(:,1));
model_noConj = Pippin.Predictors.Other(model_noConj, 'centerDis', [centerDis centerDis.^2]);
model_noConj = Pippin.Predictors.Other(model_noConj, 'centerAng', [sin(centerAng) cos(centerAng)]);

model_noConj = model_noConj.genModels();

% Simplified Model Comparison
allo = [model.predictors(2).data model.predictors(3).data];
move = [model.predictors(4).data model.predictors(5).data];
ego = [model.predictors(6).data model.predictors(7).data model.predictors(8).data];

model_simp = Pippin.Model(root);
model_simp = Pippin.Predictors.Other(model_simp,'allo',allo);
model_simp = Pippin.Predictors.Other(model_simp,'move',move);
model_simp = Pippin.Predictors.Other(model_simp, 'ego',ego);

model_simp = model_simp.genModels();


end