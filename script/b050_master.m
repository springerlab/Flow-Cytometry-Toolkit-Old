%% b050 master

%% Clean Workspace
clc
clear
close all

%% Load data

foldername = '../data_b050';
% Read data, either way is fine,
% pstrat_common = pstrat({'t', 'ssc', 'fsc', 'bfp', 'cfp', 'yfp', 'mch'})
pstrat_common = pstrat({}); % default, four colors, fsc, ssc, t
[all_data, expr_meta] = fcsfolderread(foldername, pstrat_common);

% Report
disp(' ')
disp('Plate index:')
fprintf([strjoin(expr_meta.plate_name, '\n', 'index', 'on'),'\n']);

disp(' ')
disp('Parameter index:')
fprintf([strjoin(expr_meta.para, '\n','index', 'on'),'\n']);

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

%% Effects of Flow rate and cell density
%% Plate display

close all

cha1 = 'yfp';
cha2 = 'mch';
p = 5;

figure('name', ['p', num2str(p), '_', cha1, '_', cha2])


data_plate = all_data.data{p};

h = tight_subplot(8,12,[.02 .03],[.08 .03],[.05 .01]);
maximize_window

for r = 1:8
    for c = 1:12
        
        if ~isempty(data_plate{r,c})
            axes(h(12*r+c-12))
            
            data_well = fc_thin2( data_plate{r,c}, 1000);
            fcsplot(data_well, {cha1, cha2}, 'log2', 0)
        end
    end
end

unifyaxis(gcf, 'xlim', [0 15])
unifyaxis(gcf, 'ylim', [4 13])

%% pull down events for wells with changing flowrate

data_append_flowrate = fcsstruct(expr_meta.para)

p = 5;

for r = 1:8
    for c = 1:3
        data_append_flowrate = fcsappend(data_append_flowrate, fc_thin2( all_data.data{p}{r, c}, .01 ));
    end
end

% figure,
% fcsplot( data_append_flowrate )

[ ~, ~, ~, ratio, gate_cell, gate1, gate2 ] = uimanualseg( data_append_flowrate, {'yfp', 'mch'} )

%% Simple well display

close all

%
p = 3;
r = 1;
c = 1;

cha1 = 'yfp';
cha2 = 'mch';

%
data_well = all_data.data{p}{r,c};

%
figure('name', ['p', num2str(p),'r',num2str(r),'c',num2str(c), '_', cha1, '_', cha2,'_hist'])
[N,C] = hist3(log2([data_well.(cha1), data_well.(cha2)]), [100,100]);
imagesc(C{1}, C{2}, (N'))
set(gca, 'ydir', 'normal')
colormap(flipud(gray));
xlim([0 12]), xlabel(cha1, 'fontsize', Fontsize_cal)
ylim([2 13]), ylabel(cha2, 'fontsize', Fontsize_cal)

%
figure('name', ['p', num2str(p),'r',num2str(r),'c',num2str(c), '_', cha1, '_', cha2,'_scatter'])
fcsplot(data_well, {cha1,cha2,'ssc'}, 'log2');
xlim([-1 12]), xlabel(cha1, 'fontsize', Fontsize_cal)
ylim([-1 13]), ylabel(cha2, 'fontsize', Fontsize_cal)

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

%% manual segamentation of plate 3

close all

save_folder = 'manual segmentation';

% specify all the parameters here
%
plate = 4;

cha1 = 'cfp';
cha2 = 'mch';

for row = 8
    for col = 1:12
        
        row
        col
        
        close all
        
        % data extraction
        data_well = all_data.data{plate}{row, col};
        
        if ~isempty(data_well)
            
            % define first gate
            figure('name', [num2str(plate), num2str(row), num2str(col)])
            maximize_window
            subplot(1,2,1)
            
            
            % Prompt user to draw a gate on a scatterplot of FSC versus SSC
            gate1 = uigetgate(data_well,{'fsc','ssc'}, 'log');
            xlabel('FSC')
            ylabel('SSC')
            idx_all{row, col}.fsgate = gate1.coords;
            %         xlim([0 5])
            %         ylim([0 5])
            
            % gating
            data_well_sel = applygate(data_well, gate1);
            
            % second plot
            subplot(1,2,2)
            fcsplot(fc_thin2( data_well_sel, 1), {cha1, cha2, 'ssc'}, 'log2')
            xlabel(cha1)
            ylabel(cha2)
            xlim([0 15])
            
            % cha1 segmentation
            [x,y]=ginput();
            x=[x; x(1)];
            y=[y; y(1)];
            hold all
            
            plot(x,y,'k','linewidth',2);
            idx_cha1 = inpolygon(log2(data_well_sel.(cha1)),log2(data_well_sel.(cha2)), x,y);
            
            idx_all{row, col}.cha1idx = idx_cha1;
            
            % cha2 segmentation
            [x,y]=ginput();
            x=[x; x(1)];
            y=[y; y(1)];
            hold all
            
            plot(x,y,'k','linewidth',2);
            idx_cha2 = inpolygon(log2(data_well_sel.(cha1)),log2(data_well_sel.(cha2)), x,y);
            
            idx_all{row, col}.cha2idx = idx_cha2;
            
            ratio = sum(idx_all{row, col}.cha1idx)/(sum(idx_all{row, col}.cha1idx)+sum(idx_all{row, col}.cha2idx))
            text(0.7,0.9, num2str(ratio), 'unit', 'normalized', 'fontsize', Fontsize_cal(gca, 20))
            
            ratio_all(row, col) = ratio;
            
            save_all_figure(save_folder)
        end
    end
end

close all

%% append all data in b050
close all

data_append = fcsstruct(expr_meta.para)

p = 4;

for r = 5:8
    for c = 3:10
        data_append = fcsappend(data_append, fc_thin2( all_data.data{p}{r, c}, .1 ));
    end
end

data_append

[ ~, ~, ~, ratio, gate_cell, gate1, gate2 ] = uimanualseg( data_append, {'cfp', 'mch'} )


%%
clear ratio_all
close all

for r = 5:8
    for c = 3:10
        data_well_cells= applygate(all_data.data{p}{r, c}, gate_cell);
        data_well_cells_1 = applygate(data_well_cells, gate1)
        data_well_cells_2 = applygate(data_well_cells, gate2)
        
        ratio_all(r, c) = fc_numel(data_well_cells_1)/(fc_numel(data_well_cells_1)+fc_numel(data_well_cells_2));
    end
end

figure,
maximize_window
for r = 5:8
    hold all
    plot(repmat(r, 1, 8), ratio_all(r, 3:10), '+k', 'markersize', 20)
    plot(repmat(r, 1, 8), ratio_all(r, 3:10), '.k', 'markersize', 10)
end

grid on, box on
ylim([0.4 0.5])

%% append all data in b050

cha1 = 'cfp';
cha2 = 'mch';

close all

data_append = fcsstruct(expr_meta.para)

p = 6;

for r = 5:8
    for c = 3:10
        data_append = fcsappend(data_append, fc_thin2( all_data.data{p}{r, c}, .1 ));
    end
end

data_append

[ ~, ~, ~, ratio, gate_cell, gate1, gate2 ] = uimanualseg( data_append, {cha1, cha2} )


%%
clear ratio_all
close all

p = 6;

for r = 5:8
    for c = 3:10
        data_well_cells= applygate(all_data.data{p}{r, c}, gate_cell);
        data_well_cells_1 = applygate(data_well_cells, gate1);
        data_well_cells_2 = applygate(data_well_cells, gate2);
        
        ratio_all(r, c) = fc_numel(data_well_cells_1)/(fc_numel(data_well_cells_1)+fc_numel(data_well_cells_2));
    end
end

%%
close all
figure,
maximize_window
for r = 5:8
    hold all
    plot(r+[-0.03:0.01:0.04], ratio_all(r,3:10), '+k', 'markersize', 20)
%     plot(repmat(r, 1, 3), ratio_all(r, 3:2:8), '+k', 'markersize', 20)
% plot( reshape(ratio_all(:, 3:2:8),1,[]), '.k', 'markersize', 10)
end

grid on, box on
xlim([4.5 8.5])
ylim([0.4 0.5])

xlabel('replicates', 'fontsize', Fontsize_cal)
ylabel('ratio', 'fontsize', Fontsize_cal)

%% append all data in b050

cha1 = 'yfp';
cha2 = 'mch';

close all

data_append = fcsstruct(expr_meta.para)

p = 1;

for r = 1:8
    for c = 3:8
        data_append = fcsappend(data_append, fc_thin2( all_data.data{p}{r, c}, .1 ));
    end
end

data_append

[ ~, ~, ~, ratio, gate_cell, gate1, gate2 ] = uimanualseg( data_append, {cha1, cha2} )


%%
clear ratio_all
close all

p = 1;

for r = 1:8
    for c = 3:8
        data_well_cells= applygate(all_data.data{p}{r, c}, gate_cell);
        data_well_cells_1 = applygate(data_well_cells, gate1);
        data_well_cells_2 = applygate(data_well_cells, gate2);
        
        num_1 = fc_numel(data_well_cells_1);
        num_2 = fc_numel(data_well_cells_2);
        num_double = fc_numel(data_well_cells);
        ratio_t = (num_1+num_double/2)/(num_2+num_double/2);
        % fraction
%         ratio_all(r, c) = ratio_t/(ratio_t+1);
        ratio_all(r, c) = num_1/(num_1+num_2);
    end
end

%%
close all
figure,
maximize_window

plot(repmat(1,1,24), reshape(ratio_all(1:8, [3 5 7]), 1, []), '+')
hold all
plot(repmat(2,1,24), reshape(ratio_all(1:8, [4 6 8]), 1, []), '+')
% for r = 1:8
%     hold all
%     plot(r+[-0.03:0.01:0.04], ratio_all(r,3:10), '+k', 'markersize', 20)
%     plot(repmat(r, 1, 3), ratio_all(r, 3:2:8), '+k', 'markersize', 20)
% plot( reshape(ratio_all(:, 3:2:8),1,[]), '.k', 'markersize', 10)
% end

grid on, box on
xlim([0.5 2.5])
ylim([0.215 0.245])

xlabel('replicates', 'fontsize', Fontsize_cal)
ylabel('ratio', 'fontsize', Fontsize_cal)
