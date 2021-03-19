
clearvars
close all
%% setup
addpath(genpath('T:/users/singhsr/toolbox/mrTools'))
addpath(genpath([pwd '/../pinwheels']))
modelDir = [pwd '/../'];
currDir = pwd;

%% create an empty MLR dir (only has to be run once)
% Creates Anatomy, Etc, and Raw dirs
if ~exist('Anatomy','dir') && ~exist('Etc','dir') && ~exist('Raw','dir')
    makeEmptyMLRDir([pwd '/../lilac4_sim'])
end

%% make a random time series (mrTools just wants something)
subjDir = 'T:/users/singhsr/MEG_Project2018/MRI/my_recons/lilac4/';

[d,h] = cbiReadNifti([subjDir 'surfRelax/lilac4_mprage_pp.img']);
dd = rand([size(d),10]); %the time series
cbiWriteNifti('randData.hdr',dd,h);
cbiWriteNifti([pwd '/Raw/TSeries/randData.hdr',dd,h);

%% start GUI

keyboard
mrLoadRet()
%to import surface in the GUI: (file -> base anatomy -> import surface)

%import the random data (file -> import -> Time Series)
%use interrogate overlay to make a flat map of V1
bflat = viewGet(getMLRView,'base');
save('flatmapV1_highres.mat','bflat')

%% load the benson atlas mat file

[lh rh] = mlrImportNeuropythy('lh_retino','rh_retino','doTestInMLR=1');

%select the left GM, then
b_lh = viewGet(getMLRView,'base');
%select the right GM, then
b_rh = viewGet(getMLRView,'base');

%save them
simDir = 'T:/users/singhsr/MEG_Project2018/Light_Dark/simulation/cortical_model/lilac4_sim/';
save([simDir 'allVertexCoords.mat'],'b_lh','b_rh');

%exit the viewer
dbcont