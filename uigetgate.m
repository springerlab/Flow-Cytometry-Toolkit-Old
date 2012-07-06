function gatearray = uigetgate(data, chanidx, scaling)
% Created 20120702 JW
if nargin<3
    scaling = 'lin';
end
[scalex scaley] = parsescaling(scaling);

cla

gatearray = struct;

% if isempty(gatearray)
    % prompt for gatearray
    gateArray = {};
    plot(scalex(data(:,chanidx(1))),scaley(data(:,chanidx(2))),'.','markersize',1);
    hold all;
    
    fprintf('Select gate.\n');  %TODO: display this text on plot
    [x,y]=ginput();
    x=[x; x(1)];
    y=[y; y(1)];
    gatearray(1).coords = [x y];
    gatearray(1).chanidx = chanidx;
    gatearray(1).scalex = scalex;
    gatearray(1).scaley = scaley;
    
    axis manual
    plot(x,y,'k','linewidth',2);
    
    idx = inpolygon(scalex(data(:,chanidx(1))),scaley(data(:,chanidx(2))), x,y);
    ingate = data(idx,:);
    xdata = scalex(ingate(:,chanidx(1)));
    ydata = scaley(ingate(:,chanidx(2)));
    plot(xdata,ydata,'.','markersize',1);
    
    % show count and percent
    xc = mean(x(1:end-1));
    yc = mean(y(1:end-1));
    percent = size(ingate,1)./size(data,1).*100;
    str = {num2str(size(ingate,1)); sprintf('%4.2f%%',percent)};
    text(xc,yc,str,'horizontalalignment','center',...
                   'verticalalignment','middle','fontweight','bold');
% else
    % plot all the gated data
% end

% optional: provide names
% xlabel('FSC LinH');
% ylabel('SSC LinH');

function [scalex scaley] = parsescaling(scaling)
% 20120703
if strcmp(scaling,'lin')
    scalex = @(x) x;    % identity function
    scaley = @(x) x;
elseif strcmp(scaling,'log')
    scalex = @log10;
    scaley = @log10;
elseif strcmp(scaling,'semilogx')
    scalex = @log10;
    scaley = @(x) x;
elseif strcmp(scaling,'semilogy')
    scalex = @(x) x;
    scaley = @log10;
end