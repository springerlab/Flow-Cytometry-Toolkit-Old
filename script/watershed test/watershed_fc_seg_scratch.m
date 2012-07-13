%% 20120627
% prototype of watershed FC segmentation

% unfiltered data

datadir = 'data/';
return
%%
filename = [datadir 'Sample 001_Tube 15_001.fcs'];
[data,paramVals,textHeader] = fcsread(filename);

fsc = data(:,2);
ssc = data(:,4);
mch = log10(data(:,15));
bfp = log10(data(:,29));

%%
load filtered_data


fsc = fdata(:,2);
ssc = fdata(:,4);
mch = log10(fdata(:,15));
bfp = log10(fdata(:,29));

%% scatterplot

figure

subplot(1,2,1)
plot(mch,bfp,'.','markersize',1)
xlabel('log_{10} mCherry')
ylabel('log_{10} BFP')
grid on

subplot(1,2,2)
% figure
colormap(flipud(gray))
% colormap(gray)
fc_scatter(mch(1:20:end), bfp(1:20:end),'nbins',100)
xlabel('log_{10} mCherry')
ylabel('log_{10} BFP')
grid on
box on


%% generate watershed label matrix
figure,imagesc(density')

%%
img = -density;
markerval = min(img(:))-10;

% smooth image
f = fspecial('gaussian',5,2);
img = imfilter(img,f);

figure,imagesc(img)
% figure,imshow(img,[],'InitialMagnification','fit')

% mark background
img(img==0) = markerval;

% mark extrema
img(img<-1000) = markerval;

figure,imshow(img,[],'InitialMagnification','fit')

L = watershed(img);
rgb = label2rgb(L,'jet',[.5 .5 .5]);
figure, imshow(rgb,'InitialMagnification','fit')
title('Watershed transform of D')


%%
    fsc = data(:,2);
    ssc = data(:,4);
    

    figure
    plot(fsc(1:nskip:end),ssc(1:nskip:end),'.','markersize',1);
    
%%
fsc = fdata(:,2);
ssc = fdata(:,4);
    
mch = log10(fdata(:,15));
bfp = log10(fdata(:,29));

n = 1;
figure, plot3(bfp(1:n:end),mch(1:n:end),log10(ssc(1:n:end)),'.','markersize',1);
grid on
xlabel('BFP')
ylabel('mCherry')
zlabel('FSC')

%%
    ffsc = fdata(:,2);
    fssc = fdata(:,4);
    nskip = 10;
    h=figure;
    plot(fsc(1:nskip:end),ssc(1:nskip:end),'.','markersize',1);
    hold all;
    plot(ffsc(1:nskip:end),fssc(1:nskip:end),'.','markersize',1);
    yl = ylim;
    x = xlim;
    plot(x,y(x),'linewidth',2);
    ylim(yl);
    title(strrep(f,'_',' '));
    xlabel('FSC');
    ylabel('SSC');
    


%%
imcontour(density,0:10:100)


%%
fsc = fdata(:,2);
ssc = fdata(:,4);
mch = log10(fdata(:,15));
bfp = log10(fdata(:,29));

density=hist3([mch bfp],[100 100]);
figure
surf(density)
% surf(log10(density))
%%


