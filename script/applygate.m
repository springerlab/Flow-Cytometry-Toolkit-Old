function outdata= applygate(data, gate)
% Created by JW, 20120703 
% Modified by BH, 20120714, if gate is defined by
% one/two point, then output data

chx = gate.paramnames{1};
xdata = gate.scalex(data.(chx));
chy = gate.paramnames{2};
ydata = gate.scaley(data.(chy));

if length(gate.coords(:,1))<=3 % one/two point gate
    outdata = data;
else
    idx = inpolygon(xdata,ydata,gate.coords(:,1),gate.coords(:,2));
    outdata = fcsselect(data,idx);
end