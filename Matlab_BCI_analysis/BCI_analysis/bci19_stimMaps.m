% dat = load('F:\BCI\BCI19\102521\session_102521_analyzed_dat_small_neuron1102521.mat');
dat = load('F:\BCI\BCI19\102221\session_102221_analyzed_dat_small_slm22102521.mat');

dat.currentPlane = 4;
file = [dat.folder,char(dat.siFiles{dat.currentPlane}{1})];
[hMroiRoiGroup hStimRoiGroups] = scanimage.util.readTiffRoiData(file);
header = scanimage.util.opentif(file);
seq = header.SI.hPhotostim.sequenceSelectedStimuli;
seq = repmat(seq,1,10);
seq = seq(header.SI.hPhotostim.sequencePosition:end);
seq = seq(1:length(dat.siFiles{dat.currentPlane})-1);
dat.stimGroup = hStimRoiGroups;
%%
clear D
figure(826);
figure_initialize
for si = 1:max(seq);
    clf
    set(gcf,'position',[3 3 3 3])
    ind = find(seq==si);
    files = dat.siFiles{dat.currentPlane}(1:end);
    clear pre post
    for i = 2:length(ind);
        file = [dat.folder,char(files{ind(i)})];
        [~,a] = scanimage.util.opentif(file);
        a = squeeze(a);
        post(:,:,:,i-1) = a(:,:,3:10);
        file = [dat.folder,char(files{ind(i)-1})];
        [~,a] = scanimage.util.opentif(file);
        a = squeeze(a);
        pre(:,:,i-1) = mean(a(:,:,4:end-2),3);
    end
    d = medfilt2(mean(mean(post(:,:,:,:),3),4)-mean(pre,3),[7 7]);
    d = sign(median(d(:)))*d/median(d(:));
    imagesc(d,[-1 1]*prctile(d(:),100));
    if si ~=9 & si ~=19
        imagesc(d,[-150 150]);
    else
        imagesc(d,[-1050 1050]);
    end
    cm = bluewhitered;
    colormap(cm);
    %     colorbar
    slm = hStimRoiGroups(si).rois(2).scanfields.slmPattern;
    sg = units_to_pixels(hStimRoiGroups(si).rois(2).scanfields,dat.siHeader,dat.dim);
    pix = sg.SLM_pix;
    hold on;
    scl = 2;
    for i = 1:size(pix,2);
        plot(pix(1,i),pix(2,i),'o','markersize',10,'color',[0 0 0]+0);
%         p1 = [pix(1,i)-65;pix(2,i)];
%         p2 = [pix(1,i)-90;pix(2,i)];
%         dp = p1 - p2;                         % Difference
%         qq = quiver(p1(1),p1(2),dp(1)*scl,dp(2)*1,0,'MaxHeadSize',10)
%         qq.LineWidth = 1;
%         qq.Color = 'k';
        %         set(qq,'AutoScale','on', 'AutoScaleFactor', 2)
    end
    
    set(gca,'xtick',[],'ytick',[])
    set(gca,'units','normalized','visible','off','position',[0 0 1 1]);
    D(:,:,si) = d;
    str = ['map',num2str(si)];
    axis square
    title([dat.folder,'\figures\_',str])
    drawnow
    print(gcf,'-dpng',[dat.folder,'\figures\_',str,'_3.png'])
end
% close all