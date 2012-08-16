function outdata= applygate(data, gates, varargin)
%APPLYGATE 
% 
%   APPLYGATE(DATA, GATES) returns the subset of data contained in DATA that
%   lies inside the polygons defined by GATES. The output is a struct
%   array, whose elements correspond to the data inside each gate in GATES.
% 
%   APPLYGATE(DATA, GATES, PARAMSTOPLOT) returns a struct array of gated
%   data, and also generates a scatterplot along the provided dimensions
%   showing the gated data.
% 
%       For instance, the line
% 
%           applygate(data, gates, {'mch','bfp'})
% 
%       will create a scatterplot of BFP versus mCherry and show the
%       clusters in each gate in a different color.
% 
%   Created by JW, 20120703 
%   Modified by BH, 20120714, if gate is defined by one/two point, then
%   output data unchanged
%   Updated 20120813 JW: Added optional arguments MAKEPLOT and DRAWPLOT
p = inputParser;
addRequired(p,'data',@isstruct);
addRequired(p,'gates',@isstruct);
addParamValue(p,'makeplot',false,@islogical);
addParamValue(p,'drawgates',false,@islogical);

parse(p,data,gates,varargin{:});
makeplot = p.Results.makeplot;
drawgates = p.Results.drawgates;

if isempty(data)
    outdata = [];
    return;
end

if makeplot
    chan1 = gates(1).paramnames{1};
    chan2 = gates(1).paramnames{2};
    plot(log10(data.(chan1)), log10(data.(chan2)),'.')
    hold all;
end

for c=1:length(gates)
    gate = gates(c);
    x = gate.coords(:,1);
    y = gate.coords(:,2);
    
    chx = gate.paramnames{1};
    xdata = gate.scalex(data.(chx));
    chy = gate.paramnames{2};
    ydata = gate.scaley(data.(chy));
 
    if length(gate.coords(:,1))<=3 % one/two point gate
        outdata(c) = data;
    else
        idx = inpolygon(xdata,ydata,x,y);
        outdata(c) = fcsselect(data,idx);
    end

    if makeplot
        plot(gate.scalex(outdata(c).(chan1)), gate.scaley(outdata(c).(chan2)),'.');
    end
    
    if drawgates
        % draw polygon boundaries
        axis manual
        plot(x,y,'k','linewidth',2);
        
        % plot data within polygon in different color
        idx = inpolygon(scalex(xdata),scaley(ydata), x,y);
        plot(scalex(xdata(idx)),scaley(ydata(idx)),'.','markersize',1);
        
        % show count and percent
        xc = mean(x(1:end-1));
        yc = mean(y(1:end-1));
        count = sum(idx);
        percent = count./fcsnumel(data).*100;
        str = {num2str(count); sprintf('%4.2f%%',percent)};
        text(xc,yc,str,'horizontalalignment','center',...
            'verticalalignment','middle','fontweight','bold', 'Fontsize', Fontsize_cal(gca,20));
    end
end