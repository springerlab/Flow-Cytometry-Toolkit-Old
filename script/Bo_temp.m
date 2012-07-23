clear ratio_all
close all

p = 6;

for r = 8
    for c = 3
        data_well_cells= applygate(all_data.data{p}{r, c}, gate_cell);
        data_well_cells_1 = applygate(data_well_cells, gate1);
        data_well_cells_2 = applygate(data_well_cells, gate2);
        
        ratio_all(r, c) = fc_numel(data_well_cells_1)/(fc_numel(data_well_cells_1)+fc_numel(data_well_cells_2));
    end
end