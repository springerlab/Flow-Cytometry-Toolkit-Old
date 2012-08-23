function idxarray = fcssegment(data,chans,varargin)
%FCSSEGMENT segments flow cytometry data into 2 singlet populations, a
%doublet population, and a debris population. The output IDXARRAY is a cell
%array containing arrays of the indexes of each sub-population. The input
%DATA should contain flow cytometry data in the FCToolkit format and CHANS
%should be a 2-element cell array indicating which channels to segment on.
%Uses a 4-cluster gaussian mixture model to fit the data.
% 
%   Created 20120816 JW
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

currfig = gcf;

% algorithm parameters
nrepeats = 10;

trueidx = {};
for c=1:2
    xdata = log10(data.(chans{c}));
    ydata = log10(data.(chans{3}));

    icv = [];
    allidx = {};
    
    % debug - remove when everything is perfect
    if debug
        fig = figure('position',[100 100 1900 800]);
        set(fig,'color','w')
        subplotsize = {2,5};
    end

    for k=1:nrepeats
        err = 1;
        while ~isempty(err)
            if err ~= 1
                % not the first loop, an error happened
                disp(err.message)
                disp('Retrying fit')
            end
            
            try
                err = [];
                gm = gmdistribution.fit([xdata ydata],2);
            catch err
            end
        end
        
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
               
        % debug - remove when everything is perfect
        if debug
            subplot(subplotsize{:},k)
            plot(xdata(idx1),ydata(idx1),'.')
            hold all
            plot(xdata(idx2),ydata(idx2),'.')
        end
    end

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
    figure(currfig);
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