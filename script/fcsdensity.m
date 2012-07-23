function out = fcsdensity(X,Y,varargin)
p = inputParser;
addRequired(p,'X',@isnumeric);
addRequired(p,'Y',@isnumeric);
addParamValue(p,'nbins',-1,@validate_nbins);
parse(p,X,Y,varargin{:});

nbins = p.Results.nbins;
if nbins == -1;
    % default: bin size adapted to plot pixel size
    set(gca,'Units','pixels')
    pos = get(gca,'position');
    set(gca,'Units','normalized')
    nx = floor(pos(3));
    ny = floor(pos(4));
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
surf(xi,yi,density','edgecolor','none')
view([0 90])
cmap = colormap;
set(gca,'color',cmap(1,:));

function out = validate_nbins(nbins)
isnumeric(nbins) && any(numel(nbins)==[1 2]);
