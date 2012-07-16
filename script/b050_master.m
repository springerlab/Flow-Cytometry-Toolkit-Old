%% b050 master

%% Flow rate analysis I

%
p = 1;
r = 5;
c = 9;

%
figure, fcsplot(all_data.data{p}{r,c})

%
figure, 
[count_t, bin_t] = hist(all_data.data{p}{r,c}.fsc, 100);
loglog(bin_t, count_t)
xlabel('log fsc', 'fontsize', Fontsize_cal)
ylabel('log count', 'fontsize', Fontsize_cal)

%
figure, 
[count_t, bin_t] = hist(all_data.data{p}{r,c}.ssc, 100);
loglog(bin_t, count_t)
xlabel('log ssc', 'fontsize', Fontsize_cal)
ylabel('log count', 'fontsize', Fontsize_cal)

%% Flow rate analysis II
% overlay all the wells' hist

figure

% for r = 3:5
for r = 4
%     for c = 9:12
    for c = 12
        
        [count_t, bin_t] = hist(all_data.data{p}{r,c}.fsc, 100);
        loglog(bin_t, count_t)
        
        hold all
    end
end

xlabel('log fsc', 'fontsize', Fontsize_cal)
ylabel('log count', 'fontsize', Fontsize_cal)

%% How FSC/SSC Gating affect cell counting

close all

%
p = 1;
r = 5;
c = 9;

%
data_t = all_data.data{p}{r,c};
[gatearray, idx_cells] = uigetgate(data_t, {'fsc', 'ssc'}, 'log');
xlabel('log fsc', 'fontsize', Fontsize_cal)
ylabel('log ssc', 'fontsize', Fontsize_cal)
idx_debris = ones(length(idx_cells), 1) - idx_cells;

data_cells = fcsselect(data_t, find(idx_cells));
data_debris = fcsselect(data_t, find(idx_debris));

figure, fcsplot(data_cells, {'fsc', 'ssc'}, 'log')
figure, fcsplot(data_debris, {'fsc', 'ssc'}, 'log')

%% FSC/SSC distribution

close all

% FSC
figure
maximize_window

subplot(2,1,1)
[count_t, bin_t] = hist(log10(data_cells.fsc), 100);
semilogy(bin_t, count_t)
title('cells')
xlabel('log FSC', 'fontsize', Fontsize_cal)
ylabel('log count', 'fontsize', Fontsize_cal)

subplot(2,1,2)
[count_t, bin_t] = hist(log10(data_debris.fsc), 100);
semilogy(bin_t, count_t)
title('debris')
xlabel('log FSC', 'fontsize', Fontsize_cal)
ylabel('log count', 'fontsize', Fontsize_cal)
unifyaxis(gcf, 'xlim')

% SSC
figure
maximize_window

subplot(2,1,2)
[count_t, bin_t] = hist(log10(data_debris.ssc(find(data_debris.ssc>0))), 100)
% [count_t, bin_t] = hist(log10(data_debris.ssc), 100);
semilogy(bin_t, count_t)
title('debris')
xlabel('log SSC', 'fontsize', Fontsize_cal)
ylabel('log count', 'fontsize', Fontsize_cal)

%
subplot(2,1,1)
[count_t, bin_t] = hist(log10(data_cells.ssc), 100);
semilogy(bin_t, count_t)
title('cells')
xlabel('log SSC', 'fontsize', Fontsize_cal)
ylabel('log count', 'fontsize', Fontsize_cal)

unifyaxis(gcf, 'xlim')

%
figure,
count_t_cumsum = cumsum(count_t);
loglog(10.^bin_t, count_t_cumsum./length(data_cells.ssc), '+-')
xlabel('SSC', 'fontsize', Fontsize_cal)
ylabel('Cum Counts', 'fontsize', Fontsize_cal)
grid on

%% Effects of Recovery

close all

cha1 = 'cfp';
cha2 = 'mch';

figure('name', ['p', num2str(p), '_', cha1, '_', cha2])
p = 3;

data_plate = all_data.data{p};

h = tight_subplot(8,12,[.02 .03],[.08 .03],[.05 .01]);
maximize_window

for r = 1:8
    for c = 1:12
        
        if ~isempty(data_plate{r,c})
            axes(h(12*r+c-12))
            
            data_well = fc_thin2( data_plate{r,c}, 1000);
            fcsplot(data_well, {cha1, cha2}, 'log2')
        end
    end
end

unifyaxis(gcf, 'xlim', [3 13])
unifyaxis(gcf, 'ylim', [3 13])

%% Simple well display

close all

%
p = 3;
r = 1;
c = 1;

cha1 = 'cfp';
cha2 = 'mch';

%
data_well = all_data.data{p}{r,c};

%
figure('name', ['p', num2str(p),'r',num2str(r),'c',num2str(c), '_', cha1, '_', cha2,'_hist'])
[N,C] = hist3(log2([data_well.(cha1), data_well.(cha2)]), [100,100]);
imagesc(C{1}, C{2}, (N))
set(gca, 'ydir', 'normal')
colormap(flipud(gray));
xlim([1 12]), xlabel(cha1, 'fontsize', Fontsize_cal)
ylim([2 13]), ylabel(cha2, 'fontsize', Fontsize_cal)

%
figure('name', ['p', num2str(p),'r',num2str(r),'c',num2str(c), '_', cha1, '_', cha2,'_scatter'])
fcsplot(data_well, {cha1,cha2,'ssc'}, 'log2');
xlim([1 12]), xlabel(cha1, 'fontsize', Fontsize_cal)
ylim([2 13]), ylabel(cha2, 'fontsize', Fontsize_cal)

%%

[az, el] = view();

%%
% close all

pc1 = [cosd(el)*sind(az), -cosd(el)*cosd(az), sind(el)];
pc2 = [-sind(el)*sind(az), sind(el)*cosd(az), cosd(el)];
pc3 = [-cosd(az), -sind(az), 0];

pc = [pc2', pc3', pc1'];

data_well_mat = log2([data_well.(cha1), data_well.(cha2), data_well.ssc]);
score = data_well_mat*pc;

figure,
plot3(score(:,1), score(:,2), score(:,3), '.');
box on
grid on
view(2)

% 

[x,y]=ginput();
x=[x; x(1)];
y=[y; y(1)];
hold all

plot(x,y,'k','linewidth',2);

idx = inpolygon(score(:,1),score(:,2), x,y);

% plot3(score(idx ,1), score(idx ,2), score(idx ,3), '.');

xc = mean(x(1:end-1));
yc = mean(y(1:end-1));
count = sum(idx);
percent = count./fc_numel(data_well).*100;
str = {num2str(count); sprintf('%4.2f%%',percent)};
text(xc,yc,str,'horizontalalignment','center',...
    'verticalalignment','middle','fontweight','bold', 'Fontsize', Fontsize_cal(gca,10));