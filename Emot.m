% Reading experiment with emotion target word manipulation

% Martin R. Vasilev, 2019

global const; 

%% settings:
clear all;
clear mex;
clear functions;

cd('C:\Users\EyeTracker\Desktop\Martin Vasilev\Emot_Julie');
addpath([cd '\functions'], [cd '\corpus'], [cd '\design']);

settings; % load settings
ExpSetup; % do window and tracker setup

%% Load stimuli and design:
importDesign;
load('sent.mat');
const.ntrials= height(design);

%% Run Experiment:
runTrials;

%% Save file & Exit:
status= Eyelink('ReceiveFile');
Eyelink('Shutdown');

Screen('CloseAll');