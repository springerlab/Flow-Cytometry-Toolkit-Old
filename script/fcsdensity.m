function out = fcsdensity(X,Y,varargin)
%FCSDENSITY makes a 2D heatmap of flow cytometry data.
%
%   Created 20120807 JW
p = inputParser;
addRequired(p,'X',@isnumeric);
addRequired(p,'Y',@isnumeric);
addParamValue(p,'nbins',[],@validate_nbins);
addParamValue(p,'plotstyle','density',@ischar);

parse(p,X,Y,varargin{:});
nbins = p.Results.nbins;
plotstyle = p.Results.plotstyle;

if isempty(nbins)
    % default: bin size adapted to plot pixel size
    set(gca,'Units','pixels')
    pos = get(gca,'position');
    set(gca,'Units','normalized')
    nx = floor(pos(3));
    ny = floor(pos(4));
    if strcmpi(plotstyle,'contour')
        nx = nx./2;
        ny = ny./2;
    end
elseif numel(nbins)==1   
    nx = nbins(1);
    ny=nx;
else  
    nx = nbins(1);
    ny = nbins(2);
end

xi = linspace(min(X),max(X),nx);
yi = linspace(min(Y),max(Y),ny);
density = hist3([X Y],{xi yi});
% h=surf(xi,yi,density')
% surf(xi,yi,density','linestyle','none')
if strcmpi(plotstyle,'density') 
    surf(xi,yi,density','edgecolor','none')
    view([0 90])
    cmap = colormap;
    set(gca,'color',cmap(1,:));
elseif strcmpi(plotstyle,'contour')
    contour(xi,yi,density')
end

function out = validate_nbins(nbins)
isnumeric(nbins) && any(numel(nbins)==[1 2]);
