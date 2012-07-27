function outdata= applygate(data, gates)
%APPLYGATE
% 
%   APPLYGATE(DATA, GATES) returns the subset of data contained in DATA that
%   lies inside the polygons defined by GATES. The output is a struct
%   array, whose elements correspond to the data inside each gate in GATES.
% 
%   Created by JW, 20120703 
%   Modified by BH, 20120714, if gate is defined by one/two point, then
%   output data unchanged

for c=1:length(gates)
    gate = gates(c);
    
    chx = gate.paramnames{1};
    xdata = gate.scalex(data.(chx));
    chy = gate.paramnames{2};
    ydata = gate.scaley(data.(chy));

    if length(gate.coords(:,1))<=3 % one/two point gate
        outdata(c) = data;
    else
        idx = inpolygon(xdata,ydata,gate.coords(:,1),gate.coords(:,2));
        outdata(c) = fcsselect(data,idx);
    end
end