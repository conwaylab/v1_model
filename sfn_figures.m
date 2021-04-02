close all
clearvars

addpath(genpath([pwd '/lilac4_sim']))

[params,paths] = initializeParametersVariableDisplacement;
params.onSigmaFraction = 3;
params.dispNoiseCoeff = 0.3;
params.angleNoiseCoeff = 0;

modelName = 'dim400_pinwheel400_onSigmaFrac3_dispNoiseCoeff0.3_angleNoiseCoeff0_disp0';
load(fullfile(paths.modelDir,[modelName '.mat']))
% 
load('flatmapV1_highres.mat')
flatpatch = bflat.data;
flatpatchVec = reshape(flatpatch,[],1);

nanI = isnan(offField.orientation);

dims = params.dims +1;

savedir = 'C:/Users/singhsr/Documents/Documentation/MEG_Paper/Light Dark/sfn/Simulation/';

keyboard

%% 1: 
th = linspace(0,360,250);
b = 0.9;
a = 0.08;
spiral = logSpiral(th,b,a,[0,0]);

whiteColor = [0.9,0.9,0.9];
blackColor = [0,0,0];
bkdColor = [0.5,0.5,0.5];

%black spiral
figure
ax = axes;
scatter(spiral.coords(:,1),spiral.coords(:,2),'MarkerFaceColor',blackColor,...
    'MarkerEdgeColor',blackColor)
set(gca,'Color',bkdColor)
axis equal
axis tight
% ax.XTick = [];
% ax.YTick = [];
grid off
%white spiral
figure
ax = axes;
scatter(spiral.coords(:,1),spiral.coords(:,2),'MarkerFaceColor',whiteColor,...
    'MarkerEdgeColor',whiteColor)
set(gca,'Color',bkdColor)
axis equal
axis tight
% ax.XTick = [];
% ax.YTick = [];
grid off

cellResponsesOff= cellActivations(offField,spiral,params);
cellResponsesOff = reshape(cellResponsesOff,dims,dims);

cellResponsesOn = cellActivations(onField,spiral,params);
cellResponsesOn = reshape(cellResponsesOn,dims,dims);

%view OFF response
figure
ax1 = axes;
h = imagesc(ax1,cellResponsesOff);
ax1.XTick = [];
ax1.YTick = [];
title('OFF Response')
axis square
axis tight
% alpha = ones(size(offField.orientation));
% alpha(nanI) = 0;
% set(h, 'AlphaData', alpha);
% set(gca,'Color',bkdColor)

%view ON response
figure
ax2 = axes;
h = imagesc(ax2,cellResponsesOn);
ax2.XTick = [];
ax2.YTick = [];
title('ON Response')
axis square
axis tight
% alpha = ones(size(offField.orientation));
% alpha(nanI) = 0;
% set(h, 'AlphaData', alpha);
% set(gca,'Color','k')

%% show two eye movements

b = 0.9;
a = 0.08;

th = linspace(0,360,250);

center1 = [0,0];
spiral1 = logSpiral(th,b,a,center1);

center2 = [0.3,0.3];
spiral2 = logSpiral(th,b,a,center2);

% color = [0.9,0.9,0.9];
color = [0,0,0];
bkdColor = [0.5,0.5,0.5];

figure
ax = axes
scatter(spiral1.coords(:,1),spiral1.coords(:,2),'MarkerFaceColor',color,...
    'MarkerEdgeColor',color)
set(gca,'Color',bkdColor)
axis equal
axis tight
% ax.XTick = [];
% ax.YTick = [];
grid off

cellResponsesOff1= cellActivations(offField,spiral1,params);
cellResponsesOff1 = reshape(cellResponsesOff1,dims,dims);

cellResponsesOn1 = cellActivations(onField,spiral1,params);
cellResponsesOn1 = reshape(cellResponsesOn1,dims,dims);

cellResponsesOff2= cellActivations(offField,spiral2,params);
cellResponsesOff2 = reshape(cellResponsesOff2,dims,dims);

cellResponsesOn2 = cellActivations(onField,spiral2,params);
cellResponsesOn2 = reshape(cellResponsesOn2,dims,dims);

%% view it
regionY = 195:245;
regionX = 75:125;
% 
% regionY = 1:401;
% regionX = 1:401;
% 
% 
% regionY = 170:220;
% regionX = 100:140;

nanI = zeros(size(cellResponsesOff2(regionY,regionX)));
rOFF = corr2noNan(cellResponsesOff1(regionY,regionX),cellResponsesOff2(regionY,regionX),nanI)
rON = corr2noNan(cellResponsesOn1(regionY,regionX),cellResponsesOn2(regionY,regionX),nanI)

cellResponsesOffCheck = cellResponsesOff1;
cellResponsesOffCheck(regionY,regionX) = 0;

f = figure
ax1 = axes;
h = imagesc(ax1,cellResponsesOffCheck(regionY,regionX));
ax1.XTick = [];
ax1.YTick = [];
title('OFF Response')
axis square
axis tight
print(f,[savedir 'off_eyepos1.png'],'-dpng','-r300')

% print(f,[savedir 'offZoom1.png'],'-dpng','-r300')
% alpha = ones(size(offField.orientation));
% alpha(nanI) = 0;
% set(h, 'AlphaData', alpha);
% set(gca,'Color',bkdColor)

f = figure
ax3 = axes;
h = imagesc(ax3,cellResponsesOff2(regionY,regionX));
% ax3.XTick = [];
% ax3.YTick = [];
title('OFF Response')
axis square
axis tight
print(f,[savedir 'off_eyepos2.png'],'-dpng','-r300')

f = figure
ax2 = axes;
h = imagesc(ax2,cellResponsesOn1(regionY,regionX));
% ax2.XTick = [];
% ax2.YTick = [];
title('ON Response')
axis square
axis tight
print(f,[savedir 'onZoom1.png'],'-dpng','-r300')

f = figure
ax4 = axes;
h = imagesc(ax4,cellResponsesOn2(regionY,regionX));
% ax4.XTick = [];
% ax4.YTick = [];
title('ON Response')
axis square
axis tight
print(f,[savedir 'on_eyepos2.png'],'-dpng','-r300')

subplot(2,2,1,ax1)
subplot(2,2,2,ax3)
subplot(2,2,3,ax2)
subplot(2,2,4,ax4)

%%
figure
ax1 = axes;
imagesc(ax1,flatpatch)
colormap(ax1,'gray')
caxis(ax1,[0.1 0.9])
axis equal
axis tight
ax2 = axes;
h = imagesc(ax2,cellResponsesOff);
alpha = ones(size(offField.orientation))*0.9;
alpha(nanI) = 0;
set(h, 'AlphaData', alpha);
% colormap(ax2,'hsv')
cb1 = colorbar(ax2)
linkaxes([ax2,ax1])
ax2.Visible = 'off';
ax2.XTick = [];
ax2.YTick = [];
ax1.XTick = [];
ax1.YTick = [];
axis equal
axis tight
set([ax1,ax2],'Position',[.17 .11 .685 .815]);
title(ax1,'OFF Resposne')

%% off field flat maps
alphaAmount = 0.9;
nanI = isnan(offField.eccen);
figure
%orientation
ax1 = axes;
imagesc(ax1,flatpatch)
colormap(ax1,'gray')
caxis(ax1,[0.1 0.9])
axis equal
axis tight
ax2 = axes;
h = imagesc(ax2,offField.orientation);
alpha = ones(size(offField.orientation))*alphaAmount;
alpha(nanI) = 0;
set(h, 'AlphaData', alpha);
colormap(ax2,'hsv')
cb1 = colorbar(ax2)
linkaxes([ax2,ax1])
ax2.Visible = 'off';
ax2.XTick = [];
ax2.YTick = [];
ax1.XTick = [];
ax1.YTick = [];
axis equal
axis tight
set([ax1,ax2],'Position',[.17 .11 .685 .815]);
title(ax1,'Orientation')
subplot(1,4,1,ax1)
subplot(1,4,1,ax2)

%angle
ax5 = axes;
imagesc(ax5,flatpatch)
colormap(ax5,'gray')
caxis(ax5,[0.1 0.9])
axis equal
axis tight
ax6 = axes;
h = imagesc(ax6,offField.angle);
alpha = ones(size(offField.angle))*alphaAmount;
alpha(nanI) = 0;
set(h, 'AlphaData', alpha);
colormap(ax6,'hsv')
cb3 = colorbar(ax6)
linkaxes([ax6,ax5])
ax6.Visible = 'off';
ax6.XTick = [];
ax6.YTick = [];
ax5.XTick = [];
ax5.YTick = [];
axis equal
axis tight
set([ax5,ax6],'Position',[.17 .11 .685 .815]);
title(ax5,'Angle')
subplot(1,4,3,ax5)
subplot(1,4,3,ax6)

%eccentricity
ax3 = axes;
imagesc(ax3,flatpatch)
colormap(ax3,'gray')
caxis(ax3,[0.1 0.9])
axis equal
axis tight
ax4 = axes;
h = imagesc(ax4,offField.eccen);
alpha = ones(size(offField.eccen))*alphaAmount;
alpha(nanI) = 0;
set(h, 'AlphaData', alpha);
colormap(ax4,'hsv')
cb2 = colorbar(ax4)
linkaxes([ax4,ax3])
ax4.Visible = 'off';
ax4.XTick = [];
ax4.YTick = [];
ax3.XTick = [];
ax3.YTick = [];
axis equal
axis tight
set([ax3,ax4],'Position',[.17 .11 .685 .815]);
title(ax3,'Eccentricity')
subplot(1,4,2,ax3)
subplot(1,4,2,ax4)

%sigma
ax7 = axes;
imagesc(ax7,flatpatch)
colormap(ax7,'gray')
caxis(ax7,[0.1 0.9])
axis equal
axis tight
ax8 = axes;
h = imagesc(ax8,offField.sigma);
alpha = ones(size(offField.sigma))*alphaAmount;
alpha(nanI) = 0;
set(h, 'AlphaData', alpha);
colormap(ax8,'hsv')
cb4 = colorbar(ax8)
linkaxes([ax8,ax7])
ax8.Visible = 'off';
ax8.XTick = [];
ax8.YTick = [];
ax7.XTick = [];
ax7.YTick = [];
axis equal
axis tight
set([ax7,ax8],'Position',[.17 .11 .685 .815]);
title(ax7,'pRF Sigma')
subplot(1,4,4,ax7)
subplot(1,4,4,ax8)

% print([savedir 'offMaps_alpha' num2str(alphaAmount) '.png'],'-dpng','-r300')

%% on field flat maps
alphaAmount = 0.9;

figure
%orientation
ax1 = axes;
imagesc(ax1,flatpatch)
colormap(ax1,'gray')
caxis(ax1,[0.1 0.9])
axis equal
axis tight
ax2 = axes;
h = imagesc(ax2,onField.orientation);
alpha = ones(size(onField.orientation))*alphaAmount;
alpha(nanI) = 0;
set(h, 'AlphaData', alpha);
colormap(ax2,'hsv')
% cb1 = colorbar(ax2)
linkaxes([ax2,ax1])
ax2.Visible = 'off';
ax2.XTick = [];
ax2.YTick = [];
ax1.XTick = [];
ax1.YTick = [];
axis equal
axis tight
set([ax1,ax2],'Position',[.17 .11 .685 .815]);
title(ax1,'Orientation')
subplot(1,4,1,ax1)
subplot(1,4,1,ax2)

%angle
ax5 = axes;
imagesc(ax5,flatpatch)
colormap(ax5,'gray')
caxis(ax5,[0.1 0.9])
axis equal
axis tight
ax6 = axes;
h = imagesc(ax6,onField.angle);
alpha = ones(size(onField.angle))*alphaAmount;
alpha(nanI) = 0;
set(h, 'AlphaData', alpha);
colormap(ax6,'hsv')
cb3 = colorbar(ax6)
linkaxes([ax6,ax5])
ax6.Visible = 'off';
ax6.XTick = [];
ax6.YTick = [];
ax5.XTick = [];
ax5.YTick = [];
axis equal
axis tight
set([ax5,ax6],'Position',[.17 .11 .685 .815]);
title(ax5,'Angle')
subplot(1,4,2,ax5)
subplot(1,4,2,ax6)

%eccentricity
ax3 = axes;
imagesc(ax3,flatpatch)
colormap(ax3,'gray')
caxis(ax3,[0.1 0.9])
axis equal
axis tight
ax4 = axes;
h = imagesc(ax4,onField.eccen);
alpha = ones(size(onField.eccen))*alphaAmount;
alpha(nanI) = 0;
set(h, 'AlphaData', alpha);
colormap(ax4,'hsv')
cb2 = colorbar(ax4)
linkaxes([ax4,ax3])
ax4.Visible = 'off';
ax4.XTick = [];
ax4.YTick = [];
ax3.XTick = [];
ax3.YTick = [];
axis equal
axis tight
set([ax3,ax4],'Position',[.17 .11 .685 .815]);
title(ax3,'Eccentricity')
subplot(1,4,3,ax3)
subplot(1,4,3,ax4)

%sigma
ax7 = axes;
imagesc(ax7,flatpatch)
colormap(ax7,'gray')
caxis(ax7,[0.1 0.9])
axis equal
axis tight
ax8 = axes;
h = imagesc(ax8,onField.sigma);
alpha = ones(size(onField.sigma))*alphaAmount;
alpha(nanI) = 0;
set(h, 'AlphaData', alpha);
colormap(ax8,'hsv')
% cb4 = colorbar(ax8)
linkaxes([ax8,ax7])
ax8.Visible = 'off';
ax8.XTick = [];
ax8.YTick = [];
ax7.XTick = [];
ax7.YTick = [];
axis equal
axis tight
set([ax7,ax8],'Position',[.17 .11 .685 .815]);
title(ax7,'pRF Sigma')
subplot(1,4,4,ax7)
subplot(1,4,4,ax8)

% print([savedir 'onMaps_alpha' num2str(alphaAmount) '2.png'],'-dpng','-r300')

