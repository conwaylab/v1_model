% should note down how I produced the surfRelax dir
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
cbiWriteNifti([pwd '/Raw/TSeries/randData.hdr',dd,h]);

%% start GUI

keyboard
mrLoadRet()
%to import surface in the GUI: (file -> base anatomy -> import surface)

% keyboard
%import the random data (file -> import -> Time Series)

% Make Flatmap of V1:
%hit plots -> interrogate overlay , on bottom dropdown change interrogator
%to makeFlat, then click on any place near the back of the brain
%use x=78,y=56,z=139, and rad=50 to define area (numbers will be finicky,
%keep changing each of them until they stay at what is needed)
%click ok
%when asked for the res, choose 1
bflat = viewGet(getMLRView,'base');
bhdr = viewGet(getMLRView,'basehdr');
save('flatmapV1.mat','bflat','bhdr')

%repeat the above and then choose res = 4 for a high resolution flatmap
%that is good for making figures with:
save('flatmapV1_highres.mat','bflat','bhdr')

%% load the benson atlas mat file

% run this command
[lh rh] = mlrImportNeuropythy('lh_retino','rh_retino','doTestInMLR=1');
% a file explorer opens, navigate to T:\users\singhsr\MEG_Project2018\MRI\my_recons\lilac4\surfRelax
% then select lilac4_left_GM.off
% hit okay at the next window with a brain that opens
% another file explorer opens, this time select lilac4_right_GM.off
% hit okay at the next window with a brain that opens

% a new window with a brain will open

% select lilac4_left_GM.off on the Bas dropdown, then run the following
% command:
b_lh = viewGet(getMLRView,'base');
%select the right GM, then the following command
b_rh = viewGet(getMLRView,'base');

% run these next two commands
simDir = 'T:/users/singhsr/MEG_Project2018/Light_Dark/simulation/cortical_model/lilac4_sim/';
save([simDir 'allVertexCoords.mat'],'b_lh','b_rh');

%exit the viewer
dbcont