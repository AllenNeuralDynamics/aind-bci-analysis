dat = new;
n = length(dat.roi);
dt_si = 1/dat.siHeader.SI.hRoiManager.scanVolumeRate;
t = 0:dt_si:dt_si*(size(S{1},1)-1);
tt = t;
stm = 8:13;
t(stm) = [];
ddd = DDD{1};
shuffle = 0;
if shuffle == 1
    for i = 1:100
        print('Shuffle')
    end
end
try
    cl = new.conditioned_coordinates';
    clear dist
    for i = 1:length(dat.roi);
        dist(i) = sqrt(sum((dat.roi(i).centroid - cl).^2));
    end
    cn = dat.conditioned_neuron;
catch
    dist = 1:n;
    cn = 1;
end
for i = 1:size(S,1);
    for j = 1:size(S,2);
        a = S{i,j};
        a(stm,:,:) = [];
        a = interp1(t,a,tt,'linear');
        S{i,j} = a;
    end
end
for ci = 1:n;
    for j = 1:size(S,1);
        if j == 1;
            total1{ci} = [];
            total2{ci} = [];
        end
        
        day1 = squeeze(S{j,1}(:,ci,:));
        day2 = squeeze(S{j,2}(:,ci,:));
        if shuffle == 1
            in = 1:size(day1,2);
            in1 = randsample(in,floor(length(in)/2));
            in2 = setdiff(in,in1);
            day2 = day1(:,in2);
            day1 = day1(:,in1);
        end
        
        
        bl = nanmean(nanmean(day2(1:7,:)));
        d2 = day2-bl;
        day2=(day2-bl)/bl;
        bl = nanmean(nanmean(day1(1:7,:)));
        d1 = day1-bl;
        day1=(day1-bl)/bl;
        [~,p1(ci,j)]= ttest(squeeze(mean(day1(15:end,:))));
        [~,p2(ci,j)]= ttest(squeeze(mean(day2(15:end,:))));
        mn1 = mean(mean(day2(15:end,:),2));
        mn2 = mean(mean(day1(15:end,:),2));
        mn = mn1-mn2;
        vr1 = var(mean(day2(15:end,:)));
        vr2 = var(mean(day1(15:end,:)));
        vr = sqrt(vr1/2+vr2/2);
        MN1(ci,j)=mn1;
        MN2(ci,j)=mn2;
        VR1(ci,j)=sqrt(vr1)/sqrt(size(day1,2));
        VR2(ci,j)=sqrt(vr2)/sqrt(size(day2,2));
        Z(ci,j)= mn;
        
        if ddd(ci,j) > 30 & size(day2,2)>5 & size(day1,2)>5;
            z(ci,j) = mn;
            er(ci,j) = vr;
            
            m1 = mean(mean(d2(15:end,:),2));
            m2 = mean(mean(d1(15:end,:),2));
            zz(ci,j) = mn/vr;
            
            total1{ci} = [total1{ci} day1];
            total2{ci} = [total2{ci} day2];
        else
            z(ci,j) = nan;
            zz(ci,j) = nan;
        end
    end
end
%%
clf
% errorbar(dist,nanmean(z'),sqrt(nanmean(er'.^2)),'color',[.8 .8 .8]);hold on;
plot(dist,nanmean((z')),'o','color',[0 0 0]+.5);hold on;
plot(dist(cn),nanmean((z(cn,:)')),'o','color',[.7 .7 .7],...
    'Markerfacecolor','r');hold on;

fixed_bin_plots(dist,nanmean((z')),[0 50 100:75:500 1000],1,'k');hold on;
xlim([-50 800])
plot(xlim,xlim*0,'k:')
figure_finalize
%%
clf
bins = [0 30 100 200 1000];
clear cc
for i = 1:length(bins)-1;
    ind = find(ddd>bins(i) & ddd<bins(i+1));
    %     ind = find(ddd>bins(i) & ddd<bins(i+1) & abs(MN2)>.08);
    % ind = find(ddd<30);
    if i < 5
        subplot(3,2,i);
        %         errorbar(MN1(ind),MN2(ind),VR1(ind),'k.','horizontal');hold on;
        %         errorbar(MN1(ind),MN2(ind),VR2(ind),'k.');hold on;
%         plot(MN1(ind)./VR1(ind),MN2(ind)./VR2(ind),'ko','MarkerFaceColor','w','markersize',3);hold on;
        plot(MN1(ind),MN2(ind),'ko','MarkerFaceColor','w','markersize',3);hold on;
        
        plot(xlim,xlim,'k:')
        xlabel('Day 1 (z-score response)');
        ylabel('Day 2 (z-score response)');
        title(['Dist = ',num2str(bins(i)),'--',num2str(bins(i+1))])
    end
    for iter = 1:200;
        a = MN1(ind)./VR1(ind);
        b = MN2(ind)./VR1(ind);k=find(isnan(b+a)==0);
        a=a(k);b=b(k);
        rind = randsample(1:length(a),length(a),1);
        a=a(rind);
        b=b(rind);
        [cc(i,iter),p(i)] = corr(a,b);
        [h,pp(i)] = ttest(a-b);
    end
end
subplot(3,1,3);
confidence_bounds_percentile(bins(1:end-1),cc,95,'k','k',.2)
hold on;
plot(bins(1:end-1),mean(cc'),'ko');
plot(xlim,xlim*0,'k:')
title('Corr(day1,day2)');
ylabel('Corr coeff');
xlabel(['Distance from nearest target (\mum)',char(10),dat.folder]);
figure_finalize

%%
clear far

bins = [0 30 80 120 150 200 300   1000];
for j = 1:size(S,1);
    for bi = 1:length(bins)-1
        for iter = 1:20
            iter
            % j = 7;
            day1 = squeeze(S{j,1});
            day2 = squeeze(S{j,2});
            
            in = 1:size(day1,3);
            in1 = randsample(in,floor(length(in)/2));
            in2 = setdiff(in,in1);
            day1_1 = day1(:,:,in2);
            day1_2 =day1(:,:,in1);
            day1_1 = day2(:,:,randsample(1:size(day2,3),size(day2,3),1));
            day1_2 = day1(:,:,randsample(1:size(day1,3),size(day1,3),1));
            near = find(ddd(:,j)<30);
            far = find(ddd(:,j)>bins(bi) & ddd(:,j)<bins(bi+1));
            a = nanmean(day1_1(:,far,:),3);a=a-repmat(mean(a(1:7,:)),size(a,1),1);
            b = nanmean(day1_2(:,far,:),3);b=b-repmat(mean(b(1:7,:)),size(b,1),1);
            [u,s,v]=svd(a(15:20,:));
            v(:,1) = v(:,1)*sign(sum(a*v(:,1)));
            % clf
            % plot(a*v(:,1))
            % hold on;
            % plot(b*v(:,1))
            f_far2(:,j,bi,iter) = b*v(:,1);
        end
    end
end
plot(squeeze(mean(mean(f_far2(:,:,1,:),2),4)))
%%
ind =cell2mat(cellfun(@(x) ~isempty(strfind(x,'neuron')),old.bases,'uni',0))
len=cell2mat(cellfun(@(x) length(x),old.siFiles,'uni',0))
ind = find(ind.*len==max(ind.*len))
[dfo,disto,Fo,epoch,tsta,raw0,df_all0] = BCI_dat_extract2(old,old.bases{ind});

ind =cell2mat(cellfun(@(x) ~isempty(strfind(x,'neuron')),new.bases,'uni',0))
len=cell2mat(cellfun(@(x) length(x),new.siFiles,'uni',0))
ind = find(ind.*len==max(ind.*len))
[df,dist,F,epoch,tsta,rawn,df_all] = BCI_dat_extract2(new,new.bases{ind});
%%
clf
dt_si = 1/dat.siHeader.SI.hRoiManager.scanVolumeRate
t = 0:dt_si:(size(F,1)-1)*dt_si;
t = t - t(40);
cn = new.conditioned_neuron;
fnew = nanmean(F,3);%fnew = fnew-repmat(mean(fnew(1:30,:)),size(fnew,1),1);
fold = nanmean(Fo,3);%fold = fold - repmat(mean(fold(1:30,:)),size(fold,1),1);
clf
[u,s,v] = svd(fold(40:end,:));
vcd = v(:,1);
vold = vcd*(sign(sum(fnew*vcd)));
[u,s,v] = svd(fnew(40:end,:));
vcd = v(:,1);
vcd = vcd*(sign(sum(fnew*vcd)));
% vcd = vold;
% vcd = mean(fnew(100:end,:))';
vlearn = vcd - vold;
vcn = zeros(n,1);vcn(cn) = 1;
% vcd = vlearn;
% vcd = mean(fold(end-20:end,:))';
x = squeeze(nanmean(F(1:40,:,:)));
y = squeeze(nanmean(F(100:200,cn,:)));
x(isnan(x))=0;
beta = pinv(x')*y;
lag = 5;
% vcd = corr(df_all{2}(1+lag:end,:),df_all{2}(1:end-lag,cn));
% vcn = vcd;
% vcn= corr(df_alln{2}(1+lag:end,cn),df_alln{2}(1:end-lag,:))';
clear pp pppp
for si = 1:2;
    for i = 1:size(ddd,2);
        
        vstim = MN2(:,i);
        if si == 1;
            vstim= MN1(:,i);
        end
        ind=find(ddd(:,i)<30);
        stmCD(i) = vstim(ind)'*vcd(ind);
        
        ind=find(ddd(:,i)>30 & ddd(:,i)<1000020);
        coupleCD(i) = vstim(ind)'*vcd(ind);
        coupleCN(i) = vstim(ind)'*vcn(ind);
        
    end
    % stmCN = abs(stmCN);
    % subplot(122);
    % plot(fold*vcd);hold on;
    % plot(fnew*vcd);hold on;
    figure(1);
    subplot(1,2,si)
    scatter(stmCD,coupleCD,'k');hold on;
    [ccc(si),pp(si)]=corr(stmCD',coupleCD');
    plot(xlim,xlim*0,'k:');
    plot(xlim*0,ylim,'k:');
    %     mean_bin_plot(stmCD,coupleCD,3);
    xlabel('Stim vector * BCI vector');
    ylabel(['Effective connection BCI vector',char(10),' (non. stim neurons)'])
    
    figure(2)
    subplot(1,2,si)
    scatter(stmCD,coupleCN,'k');hold on;
    [cccc(si),pppp(si)]=corr(stmCD',coupleCN');
    ylim([-.2 .2])
    plot(xlim,xlim*0,'k:');
    plot(xlim*0,ylim,'k:');
    %     mean_bin_plot(stmCD,coupleCD,3);
    xlabel('Stim vector * BCI vector');
    ylabel(['Effective connection to CN',char(10),' (non. stim neurons)'])
    a = cccc(si);a=round(a*100)/100;
    text(max(xlim)-max(xlim)*.5,min(ylim)+max(ylim)*.2,['corr. = ',num2str(a)]);
    coupleCDs(:,si) = coupleCD;
    stmCDs(:,si) = stmCD;
    %     ylim([-.1 .1]);
end
pppp
% subplot(133);
% [a,b,c,d,e] = mean_bin_plot(mean(stmCDs'),diff(coupleCDs'),3);
% ccc

%%
clear cccc
for cni = 1:n
    vcn = zeros(n,1);vcn(cni) = 1;
    clear pp
    for si = 1:2;
        for i = 1:size(ddd,2);
            
            vstim = MN2(:,i);
            if si == 1;
                vstim= MN1(:,i);
            end
            ind=find(ddd(:,i)<30);
            stmCD(i) = vstim(ind)'*vcd(ind);
            
            ind=find(ddd(:,i)>30 & ddd(:,i)<1000020);
            coupleCD(i) = vstim(ind)'*vcd(ind);
            coupleCN(i) = vstim(ind)'*vcn(ind);
            
        end
        [cccc(cni,si),pppp(cni,si)]=corr(stmCD',coupleCN');
        
    end
end
%%
for i = 1:size(S,1);
    for j = 1:size(S,2);
        a = S{i,j};
        a(stm,:,:) = [];
        a = interp1(t,a,tt,'linear');
        S{i,j} = a;
    end
end
for ci = 1:n;
    fun = @(x) cell2mat(cellfun(@(x) x' ,x,'uni',0));
    int = fun(dat.roi(ci).intensity);
    int = int(1:15000);    
    for j = 1:size(S,1);
        if j == 1;
            total1{ci} = [];
            total2{ci} = [];
        end
        
        day1 = squeeze(S{j,1}(:,ci,:));
        day2 = squeeze(S{j,2}(:,ci,:));
        if shuffle == 1
            in = 1:size(day1,2);
            in1 = randsample(in,floor(length(in)/2));
            in2 = setdiff(in,in1);
            day2 = day1(:,in2);
            day1 = day1(:,in1);
        end
        
        bl = nanmean(nanmean(day2(1:7,:)));
        d2 = day2-bl;
        day2=(day2-bl)/bl;
        bl = nanmean(nanmean(day1(1:7,:)));
        d1 = day1-bl;
        day1=(day1-bl)/bl;
        [~,p1(ci,j)]= ttest(squeeze(mean(day1(15:end,:))));
        [~,p2(ci,j)]= ttest(squeeze(mean(day2(15:end,:))));
        
        strts = round(rand(1,size(day1,2))*(length(int)-239))+8;
        strts = repmat(strts,31,1) + repmat((-7:23)',1,size(day1,2));
        day1 = int(strts);
        bl = nanmean(nanmean(day1(1:7,:)));
        day1=(day1-bl)/bl;
        [~,pfalse(ci,j)]= ttest(squeeze(mean(day1(15:end,:))));
    end
end
%%
clf
thr = 0.05;
bb = bar(2,mean(sum((p1<thr).*(ddd>45))));bb.FaceColor = 'none';hold on;
plot(2+randn(1,20)/10,sum((p1<thr).*(ddd>45)),'ko');hold on;
bb = bar(3,mean(sum((p2<thr).*(ddd>45))));bb.FaceColor = 'none';hold on;
plot(3+randn(1,20)/10,sum((p2<thr).*(ddd>45)),'ko')
bb = bar(1,mean(sum((pfalse<thr).*(ddd>45))));bb.FaceColor = 'none';bb.EdgeColor = [.7 .7 .7];
plot(1+randn(1,20)/10,sum((pfalse<thr).*(ddd>45)),'ko','color',[.7 .7 .7])
set(gca,'xtick',[1 2 3],'xticklabel',{'false','day 1','day 2'})
box off
ylabel('Number of effective connections')
figure_finalize
