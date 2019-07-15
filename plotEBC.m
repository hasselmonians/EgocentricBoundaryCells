function plotEBC(root,out)

    %% occupancy circular
    figure
    % the +pi/2 brings "forwards" to "up"
    [t2, r2] = meshgrid(wrapTo2Pi(out.params.thetaBins+pi/2), out.params.distanceBins(1:end-1));
    [x, y] = pol2cart(t2,r2);
    surface(x,y, out.occ), shading interp
    hold on
    set(gca,'XTick',[],'YTick',[])
    axis square
    colormap(jet)
    set(gca, 'YDir','Normal','CLim',[0 prctile(out.occ(:),99)])
    set(gca,'YDir','Normal')  
    title('occ')

    
    %% nspk circular
    figure
    % the +pi/2 brings "forwards" to "up"
    [t2, r2] = meshgrid(wrapTo2Pi(out.params.thetaBins+pi/2), out.params.distanceBins(1:end-1));
    [x, y] = pol2cart(t2,r2);
    surface(x,y, out.nspk), shading interp
    hold on
    set(gca,'XTick',[],'YTick',[])
    axis square
    title([])
    colormap(jet)
    set(gca, 'YDir','Normal','CLim',[0 prctile(out.nspk(:),99)])
    set(gca,'YDir','Normal')  
    title('nspk')

    
    %% ratemap circular
    figure
    % the +pi/2 brings "forwards" to "up"
    [t2, r2] = meshgrid(wrapTo2Pi(out.params.thetaBins+pi/2), out.params.distanceBins(1:end-1));
    [x, y] = pol2cart(t2,r2);
    h=surface(x,y, out.rm); shading interp

    hold on
    set(gca,'XTick',[],'YTick',[])
    axis square
    colormap(jet)
    set(gca, 'YDir','Normal','CLim',[0 prctile(out.rm(:), 99)])
    set(gca,'YDir','Normal')  
    title('rm')
    axis off
    
    %% scatter of spike directions
    figure; hold on
    plot(root.x,root.y,'Color',[.7 .7 .7])
    colormap(hsv)
    xlim([min(root.x) max(root.x)]); ylim([min(root.y) max(root.y)])
    cx = root.x(root.spike == 1);
    cy = root.y(root.spike == 1);
    ch = root.md(root.spike == 1);
    scatter(cx,cy,50,ch,'filled')
    set(gca,'YDir','Normal')
    title('Trajectory')
    axis off
    axis square
    
end
        