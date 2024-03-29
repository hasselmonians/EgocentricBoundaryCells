function [out] = EgocentricRatemap(root, varargin)

    % calculates the egocentric ratemap and returns structure containing all of
    % the relevant information for plotting or statistical testing. 
    %
    % Note: In order to simplify distribution we assume that the "root" object
    % contains cleaned and epoched data only. 

    %% Setup and parse:
    p = inputParser;
    p.addParameter('videoSamp', 1);                    % calculate every X frames of video
    p.addParameter('degSamp', 1);                      % Degree bins
    p.addParameter('distanceBins', 0:1:50);            % How far to look (cm)
    p.addParameter('boundaryMode', 0);                 % 0-> autolines, 1-> click, mat->useit
    p.addParameter('smoothKernel', [5 5 5])
%     p.addParameter('sampRate', 30)                     % Samples per second
    p.parse(varargin{:});

    fn = fieldnames(p.Results);
    for i = 1:length(fn)
        eval([fn{i} '=' mat2str(p.Results.(fn{i})) ';']);
    end  

    %% Unpack behavioral information
    if strcmp(class(root), 'CMBHOME.Session')
        rx = CMBHOME.Utils.ContinuizeEpochs(root.x);% * root.spatial_scale;
        ry = CMBHOME.Utils.ContinuizeEpochs(root.y);% * root.spatial_scale;
        md = CMBHOME.Utils.ContinuizeEpochs(root.headdir);
        if max(md) > 2*pi
            md = deg2rad(md);
        end
        ts = CMBHOME.Utils.ContinuizeEpochs(root.ts);
        sts = CMBHOME.Utils.ContinuizeEpochs(root.cel_ts);
        spk = histc(sts, ts);
        distanceBins = distanceBins/root.spatial_scale;
    else
        rx = root.x;      % x position in cm or pixels
        ry = root.y;      % y position in cm or pixels
        md = root.md;     % movement (or head) direction, in radians
        ts = root.ts;     % time stamps (seconds)
        spk = root.spike; % binary spike train
    end

    %% Get structure of the environnment
    if numel(boundaryMode)==1
        if boundaryMode == 0 
            % Headless / auto. Automatically detect the edges. 
            % Only works for a rectangular box with no insertions.

            p = [-1000 -1000];
            d = (rx-p(1)).^2 + (ry-p(2)).^2;
            [~,ind] = min(d);
            ll = [rx(ind) ry(ind)];

            p = [1000 -1000];
            d = (rx-p(1)).^2 + (ry-p(2)).^2;
            [~,ind] = min(d);
            lr = [rx(ind) ry(ind)];

            p = [1000 1000];
            d = (rx-p(1)).^2 + (ry-p(2)).^2;
            [~,ind] = min(d);
            ur = [rx(ind) ry(ind)];

            p = [-1000 1000];
            d = (rx-p(1)).^2 + (ry-p(2)).^2;
            [~,ind] = min(d);
            ul = [rx(ind) ry(ind)];


            QP = [ll;lr;ur;ul];
        elseif boundaryMode == 1
            % Finds edges by selecting corners of the environment
            QP = findEdges(root);
        end
    else
        % was fed in manually
        QP = boundaryMode;
    end

    %% Calculate distances
    [dis, ex, ey] = calcDistance(rx,ry,md, QP, degSamp);

     %% Calculate raw maps:
    thetaBins = deg2rad(linspace(-180,180,size(dis,2)));
    occ = NaN(length(thetaBins), length(distanceBins));
    nspk = occ;
    distanceBins(end+1) = Inf;
    
    ci = find(spk);

    for i = 1:length(thetaBins)
        t = dis(:,i);
        for k = 1:length(distanceBins)-1
            inds = t>=distanceBins(k) & t<distanceBins(k+1);
            occ(i,k) = sum (inds);
            inds = find(inds);
            nspk(i,k) = length(intersect(inds,ci));
        end
    end
    distanceBins = distanceBins(1:end-1);

    % bring back to original dims
    occ = occ(:,1:end-1); occ=occ';
    nspk = nspk(:,1:end-1); nspk=nspk';
    
    occ_ns = occ;
    nspk_ns = nspk;

    rm_ns = (nspk./occ); % non-smoothed ratemap

    %% Smoothing
    occ = [occ occ occ];
    nd = numel(thetaBins);
    occ = SmoothMat(occ, smoothKernel(1:2), smoothKernel(3));
    occ = occ(:, nd+1:2*nd);

    nspk = [nspk nspk nspk];
    nspk = SmoothMat(nspk,smoothKernel(1:2),smoothKernel(3));   % Smooth it
    nspk = nspk(:,nd+1:2*nd);                       % bring it back

    rm = (nspk./occ);

    %% package the output
    out.rm_ns = rm_ns;
    out.occ_ns = occ_ns;
    out.nspk_ns = nspk_ns;
    out.occ = occ;
    out.nspk = nspk;
    out.rm = rm;
    out.QP = QP;
    
    out.params.videoSamp = videoSamp;
    out.params.degSamp = degSamp;
    out.params.distanceBins = distanceBins;
    out.params.smoothKernel = smoothKernel;
    out.params.thetaBins = thetaBins;
    
end

%%
function QP = findEdges(root)
    ifEscape = 0;
    h=figure();

    while ~ifEscape  
        figure(h); 
        clf
        
        set(gca,'YDir','Normal'); %colormap(jet);
        clim=get(gca,'clim');set(gca,'clim',clim/50);
        hold on
        plot(root.x, root.y,'k');
        QP = [];
        
        set(h,'Name','Select Corners of Walls. Esc--> done. **Do not complete!**')

        button = 1;

        while button~=27
            [x,y,button] = ginput(1);

            clf
            
            set(gca,'YDir','Normal'); %colormap(jet);
            clim=get(gca,'clim');set(gca,'clim',clim/50);
            hold on
            plot(root.x, root.y,'k');
            
            if ~isempty(QP)
                plot(QP(:,1),QP(:,2),'r')
                plot(QP(:,1),QP(:,2),'ro','MarkerFaceColor','r')
            end

            if button == 32 %space bar
                QP = [QP; NaN NaN];
            elseif button~=27
                QP = [QP; x y];
            end

            plot(QP(:,1),QP(:,2),'r')
            plot(QP(:,1),QP(:,2),'ro','MarkerFaceColor','r')

        end

        %Ask for verification
        edg = splitter(QP);
        clf;
        set(h,'Name','Verify. 0--> Try again; 1--> Confirm')
        plot(root.x, root.y,'k');
        hold on
        
        for m = 1:numel(edg)
            for n = 1:size(edg{m},1)
                sp = squeeze(edg{m}(n,:,1));
                ep = squeeze(edg{m}(n,:,2));
                plot([sp(1) ep(1)],[sp(2) ep(2)],'ro','MarkerFaceColor','r')
                plot([sp(1) ep(1)],[sp(2) ep(2)],'r')
            end
        end

        % set or repeat
        while button ~=48 && button~=49
            [~,~,button]=ginput(1);
        end
        ifEscape = button==49;

    end

    close(h);
    drawnow();
end

%%
function edg = splitter(QP)
    
    inds = find(isnan(QP(:,1)));
    xs=SplitVec(QP(:,1), @(x) isnan(x));
    ys=SplitVec(QP(:,2), @(x) isnan(x));
    
    % split corners
    for m = 1:size(xs,1)
        QP2{m} = [xs{m} ys{m}];
        QP2{m}(find(isnan(QP2{m}(:,1))),:) = [];
    end
    
    for m = 1:numel(QP2)
        for n = 1:size(QP2{m},1)
            sp = n;ep=n+1;
            if ep>size(QP2{m},1), ep=1;end
            edg{m}(n,:,1) = [QP2{m}(sp,1) QP2{m}(sp,2)];
            edg{m}(n,:,2) = [QP2{m}(ep,1) QP2{m}(ep,2)];
        end
    end

end

%% 
function [dis, ex, ey] = calcDistance(rx,ry,md, QP, degSamp)
    
    mxd = sqrt((max(rx)-min(rx))^2 + (max(ry)-min(ry))^2);
    degs = deg2rad(-180:degSamp:180);
        
    edg = splitter(QP);
    edg = cell2mat(edg(:));
    dis = NaN(numel(rx),size(edg,1), numel(degs));
    dir = dis;
    
    for i = 1:size(edg,1)
        x1=edg(i,1,1);x2=edg(i,1,2);
        y1=edg(i,2,1);y2=edg(i,2,2);
        for h = 1:numel(degs)
            mdof=degs(h);
            y3=ry;x3=rx;
            y4=ry+mxd*sin(md+mdof);
            x4=rx+mxd*cos(md+mdof);
            
            % find the intersection analytically
            px1 = (x1.*y2-y1.*x2).*(x3-x4) - (x1-x2).*(x3.*y4-y3.*x4);
            px2 = (x1-x2).*(y3-y4) - (y1-y2).*(x3-x4);
            px  = px1./px2;
            
            py1 = (x1.*y2-y1.*x2).*(y3-y4) - (y1-y2).*(x3.*y4-y3.*x4);
            py2 = (x1-x2).*(y3-y4) - (y1-y2).*(x3-x4);
            py = py1./py2;

            d = sqrt((ry-py).^2 + (rx-px).^2);
            dis(:,i,h) = d;
            
            % need to filter down to the right direction ...
            dir(:,i,h) = wrapToPi(atan2(py-ry,px-rx)-(md+mdof));
            
            % filter by bounding box
            bb = [min([x1 x2]) max([x1 x2]); min([y1 y2]) max([y1 y2])];  
            % |xmin, xmax|
            % |ymin, ymax|
            indexes = ~(px>=bb(1,1) & px<=bb(1,2) & py>=bb(2,1) & py<=bb(2,2));
            dis(indexes,i,h) = NaN;
        end
        
    end
    
    
    dis(dis>mxd) = NaN;
    dis(abs(dir)>pi/4) = NaN;
    
    %output
    dis=squeeze(nanmin(dis,[],2));
    dd=repmat(degs,size(rx,1),1) + repmat(md,1,numel(degs));
    dx=dis.*cos(dd); dy=dis.*sin(dd);
    ey=dy+repmat(ry,1,numel(degs));
    ex=dx+repmat(rx,1,numel(degs));
    
end

%%
function mat = SmoothMat(mat, kernel_size, std)
    %
    % Smooths matrix by convolving with 2d gaussian of size
    % kernel_size=[bins_x bins_y] and standard deviation 'std'
    %
    % if std==0, just returns mat


    if nargin<3
        std=1;
    end

    if std == 0, return; end

    [Xgrid,Ygrid]=meshgrid(-kernel_size(1)/2: kernel_size(1)/2, -kernel_size(2)/2:kernel_size(2)/2);
    Rgrid=sqrt((Xgrid.^2+Ygrid.^2));

    kernel = pdf('Normal', Rgrid, 0, std);
    kernel = kernel./sum(sum(kernel));
    mat = conv2(mat, kernel, 'same');

end
