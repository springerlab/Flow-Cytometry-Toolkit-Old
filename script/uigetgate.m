function [gatearray, idx] = uigetgate(data, paramnames, scaling)
% Created 2012/07/02 JW
% Updated 2012/07/13 BH, updated fontsize of text display
if nargin<3
    scaling = 'lin';
end
[scalex scaley] = parsescaling(scaling);

cla

gatearray = struct;

% prompt for gates
% TODO: allow input of multiple gates

% plot all data
gateArray = {};
xdata = data.(paramnames{1});
ydata = data.(paramnames{2});
plot(scalex(xdata),scaley(ydata),'.','markersize',1);
hold all;

% user draws polygon
fprintf('Select gate.\n');  %TODO: display this text on plot
[x,y]=ginput();
x=[x; x(1)];
y=[y; y(1)];
gatearray(1).coords = [x y];
gatearray(1).paramnames = paramnames;
gatearray(1).scalex = scalex;
gatearray(1).scaley = scaley;

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
percent = count./fc_numel(data).*100;
str = {num2str(count); sprintf('%4.2f%%',percent)};
text(xc,yc,str,'horizontalalignment','center',...
    'verticalalignment','middle','fontweight','bold', 'Fontsize', Fontsize_cal(gca,10));


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