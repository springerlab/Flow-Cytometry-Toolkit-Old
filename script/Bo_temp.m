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