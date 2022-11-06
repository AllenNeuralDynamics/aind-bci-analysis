% data = readtable('C:\Users\bpod\Documents\Pybpod\BCI\experiments\BCI\setups\KayvonScope\sessions\20201214-093955\20201214-093955.csv');
data = readtable('C:\Users\bpod\Documents\Pybpod\BCI\experiments\BCI\setups\KayvonScope\sessions\20210426-102809\20210426-102809.csv');
%%
a = data.MSG;
rew = arrayfun(@(x) strcmp(x,'ResponseInRewardZone'),a);
rew = arrayfun(@(x) strcmp(x,'ResponseInRewardZone'),a);
strt = arrayfun(@(x) strcmp(x,'New trial'),a);
%%
% figure
clf
ind = find(strt == 1);
ind = [ind; length(strt)];
for i = 1:length(ind)-1;
    in = ind(i):ind(i+1);
    rr(i) = sum(rew(in));
    a = find(rew(in)==1);
    if ~isempty(a)
    rt(i) = in(a(end));
    rrt(i) = a(1);
    else
        rt(i) = nan;
        rrt(i) = nan;
    end
end
rr = rr(17:end);
rt = rt(17:end);
rt(isnan(rt))=[];
len = 20;
subplot(211);
plot(conv(double(rr==2),ones(len,1))/len)
xlim([len length(rr)]);box off
% ylim([.35 .85]);
% str = char(data(10,end));
% title([str(2:8),data(13,end)])

subplot(212);
rt = rt/(60*24);
len = 10;
plot(conv(1./diff(rt),ones(len,1))/len)
xlim([len length(rr)]);box off
% ylim([2.5 3])

