function [subpops, idxarray] = fcssegment(data,chans,varargin)
%FCSSEGMENT segments flow cytometry data into 2 singlet populations, a
%doublet population, and a debris population. Uses a 4-cluster gaussian
%mixture model to fit the data.
% 
%The input DATA should contain flow cytometry data in the FCToolkit format
%and CHANS should be a 2-element cell array indicating which channels to
%segment on.
%
%The output SUBPOPS is a struct array containing flow cytometry data for
%the singlet populations, the doublet population, and the debris
%population.
% 
%The optional output IDXARRAY is a cell array containing arrays of the
%indexes of each sub-population.
% 
%   For example, the following code will load some data from a file,
%   segment it on mCherry and BFP, and plot a density heatmap of ONLY the
%   points in the mCherry singlet cluster.
%       
%       data = fcsparse('Sample_001_Tube_012.fcs','rename');
%       subpops = fcssegment(data, {'mch','bfp'});
%       figure, fcsdensity(log10(subpops(1).mch), log10(subpops(1).bfp));
%
%   Created 20120816 JW; minor change 20120817 BH, do not run currfig =
%       gcf; when make plot is false
%   Modified 20120820 BH; remove debug, add 'start' guess on gmdistribution.fit
%   Modified 20120823 JW: made default output subpopulation struct array,
%       idxarray as optional second output

p = inputParser;
addRequired(p,'data',@isstruct);
addRequired(p,'chans',@iscell);
addParamValue(p,'makeplot',false,@islogical);
addParamValue(p,'showlegend',false,@islogical);
addParamValue(p,'debug',false,@islogical);

parse(p,data,chans,varargin{:});
makeplot = p.Results.makeplot;
showlegend = p.Results.showlegend;
debug = p.Results.debug;

if length(chans)<3
    chans{3} = 'ssc';
end

% algorithm parameters
nrepeats = 10;

trueidx = {};
for c=1:2
    xdata = log10(data.(chans{c}));
    ydata = log10(data.(chans{3}));
    
    icv = [];
    allidx = {};
    
    %     % debug - remove when everything is perfect
    %     if debug
    %         % fig = figure('position',[100 100 1900 800]);
    %         fig = figure, maximize_window
    %         set(fig,'color','w')
    %         subplotsize = {2,5};
    %     end
    
    %     for k=1:nrepeats
    
    xdataNor = mat2gray(log2(xdata));
    xdataThre = graythresh(xdataNor);
    xdataBinary = im2bw(xdataNor, xdataThre);
    
    xdataSub{1} = xdata(xdataBinary==1);
    xdataSub{2} = xdata(xdataBinary==0);
    
    ydataSub{1} = ydata(xdataBinary==1);
    ydataSub{2} = ydata(xdataBinary==0);
    
%     gm = gmdistribution.fit([xdata ydata],2);
    gm = gmdistribution.fit([xdata ydata],2, 'Start', double(xdataBinary)+1);
    
    idx = cluster(gm,[xdata ydata]);
    idx1 = (idx == 1);
    idx2 = (idx == 2);
    m1 = mean(xdata(idx1));
    m2 = mean(xdata(idx2));
    
    % ensure that cluster 2 always has higher mean
    if m1 > m2
        tmp = idx1;
        idx1 = idx2;
        idx2 = tmp;
    end
    allidx{k,1} = idx1;
    allidx{k,2} = idx2;
    
    % intraclass variance - for rejecting bad clusterings
    icv(k) = (sum(idx1).*var(xdata(idx1)) + sum(idx2).*var(xdata(idx2)))...
        ./length(xdata);
    
    %         % debug - remove when everything is perfect
    %         if debug
    %             subplot(subplotsize{:},k)
    %             plot(xdata(idx1),ydata(idx1),'.')
    %             hold all
    %             plot(xdata(idx2),ydata(idx2),'.')
    %         end
    %     end
    
    % use clustering with lowest intraclass variance
    [~,minidx] = min(icv);
    
    trueidx{c,1} = allidx{minidx,1};
    trueidx{c,2} = allidx{minidx,2};
end

% intersect clusters
singlet1 = trueidx{1,2} & trueidx{2,1};
singlet2 = trueidx{1,1} & trueidx{2,2};
doublet = trueidx{1,2} & trueidx{2,2};
debris = trueidx{1,1} & trueidx{2,1};

% show segmentation
if makeplot
    currfig = gcf;
    figure(currfig);
    
    % hold all
    % fcsplot(fcsselect( data, ), {chans{1}, chans{2}, 'ssc'}, 'log10')
    
    xdata = log10(data.(chans{1}));
    ydata = log10(data.(chans{2}));
    plot(xdata(singlet1),ydata(singlet1),'.')
    hold all
    plot(xdata(singlet2),ydata(singlet2),'.')
    plot(xdata(doublet),ydata(doublet),'.')
    plot(xdata(debris),ydata(debris),'.')
    if showlegend
        legend('singlet1','singlet2','doublet','debris',...
            'orientation','horizontal')
    end
    xlabel(chans{1})
    ylabel(chans{2})
end

idxarray = [singlet1 singlet2 doublet debris];

subpops = fcsselect(data,idxarray);