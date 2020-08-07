function plotEBC(root,out,fign)

    %% occupancy circular
    figure(fign); subplot(1,4,1);
    % the +pi/2 brings "forwards" to "up"
    [t2, r2] = meshgrid(wrapTo2Pi(out.params.thetaBins+pi/2), out.params.distanceBins(1:end-1));
    [x, y] = pol2cart(t2,r2);
    surface(x,y, out.occ), shading interp
    hold on
    set(gca,'XTick',[],'YTick',[])
    
    colormap(parula)
    set(gca, 'YDir','Normal','CLim',[0 prctile(out.occ(:),99)])
    set(gca,'YDir','Normal')  
    title('occ')
%     colorbar
    axis off; axis square

    
    %% nspk circular
    figure(fign); subplot(1,4,2);
    % the +pi/2 brings "forwards" to "up"
    [t2, r2] = meshgrid(wrapTo2Pi(out.params.thetaBins+pi/2), out.params.distanceBins(1:end-1));
    [x, y] = pol2cart(t2,r2);
    surface(x,y, out.nspk), shading interp
    hold on
    set(gca,'XTick',[],'YTick',[])
    
    title([])
    colormap(parula)
    set(gca, 'YDir','Normal','CLim',[0 prctile(out.nspk(:),99)])
    set(gca,'YDir','Normal')  
    title('nspk')
%     colorbar
    axis off; axis square

    
    %% ratemap circular
    figure(fign); subplot(1,4,3);
    % the +pi/2 brings "forwards" to "up"
    [t2, r2] = meshgrid(wrapTo2Pi(out.params.thetaBins+pi/2), out.params.distanceBins(1:end-1));
    [x, y] = pol2cart(t2,r2);
    h=surface(x,y, out.rm); shading interp

    hold on
    set(gca,'XTick',[],'YTick',[])
    
    colormap(parula)
    set(gca, 'YDir','Normal','CLim',[0 prctile(out.rm(:), 99)])
    set(gca,'YDir','Normal')  
    title('rm')
    axis off
    title(prctile(out.rm(:), 99))
%     colorbar
    axis off; axis square
    
    %% scatter of spike directions
    figure(fign); ax = subplot(1,4,4); hold on;
    plot(root.x,root.y,'Color',[.7 .7 .7])
    colormap(ax,hsv)
    xlim([min(root.x) max(root.x)]); ylim([min(root.y) max(root.y)])
    cx = root.x(root.spike == 1);
    cy = root.y(root.spike == 1);
    ch = root.md(root.spike == 1);
    scatter(cx,cy,15,ch,'filled')
    scatter(out.QP(:,1),out.QP(:,2),30,'k','filled')
    set(gca,'YDir','Normal')
    title('Trajectory')
    axis off
    axis square
    
end
        