function outdata= applygate(data, gate)
% 20120703
chx = gate.paramnames{1};
xdata = gate.scalex(data.(chx));
chy = gate.paramnames{2};
ydata = gate.scaley(data.(chy));

idx = inpolygon(xdata,ydata,gate.coords(:,1),gate.coords(:,2));
outdata = fcsselect(data,idx);