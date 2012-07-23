function [ idx_cells, idx_1, idx_2, ratio, gate_cell, gate1, gate2 ] = uimanualseg( data_well, channels, save_folder)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

cha1 = channels{1};
cha2 = channels{2};

if nargin < 3
    save_folder = 'temp';
end

if ~isempty(data_well)
    
    % define first gate
    %     figure('name', [num2str(plate), num2str(row), num2str(col)])
    figure
    maximize_window
    subplot(1,2,1)
    
    
    % Prompt user to draw a gate on a scatterplot of FSC versus SSC
    gate_cell = uigetgate(data_well,{'fsc','ssc'}, 'log');
    xlabel('FSC')
    ylabel('SSC')
    idx_cells = gate_cell.coords;
    %         xlim([0 5])
    %         ylim([0 5])
    
    % gating
    data_well_sel = applygate(data_well, gate_cell);
    
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
    
    gate1(1).coords = [x y];
    gate1(1).paramnames = {cha1, cha2};
    gate1(1).scalex = @(x) log2(x);
    gate1(1).scaley = @(x) log2(x);
    hold all
    
    plot(x,y,'k','linewidth',2);
    idx_cha1 = inpolygon(log2(data_well_sel.(cha1)),log2(data_well_sel.(cha2)), x,y);
    
    idx_1 = idx_cha1;
    
    % cha2 segmentation
    [x,y]=ginput();
    x=[x; x(1)];
    y=[y; y(1)];
    gate2(1).coords = [x y];
    gate2(1).paramnames = {cha1, cha2};
    gate2(1).scalex = @(x) log2(x);
    gate2(1).scaley = @(x) log2(x);
    
    hold all
    
    plot(x,y,'k','linewidth',2);
    idx_cha2 = inpolygon(log2(data_well_sel.(cha1)),log2(data_well_sel.(cha2)), x,y);
    
    idx_2 = idx_cha2;
    
    ratio = sum(idx_1)/(sum(idx_1)+sum(idx_2));
    text(0.7,0.9, num2str(ratio), 'unit', 'normalized', 'fontsize', Fontsize_cal(gca, 20))
    
    save_all_figure(save_folder)
end

end

