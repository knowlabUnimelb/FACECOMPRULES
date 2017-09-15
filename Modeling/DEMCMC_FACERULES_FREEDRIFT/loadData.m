% Load separable data
function [data, cols] = loadData(subject)

load(fullfile('Data', sprintf('s%d_cedata.mat', subject))) % Load data
cols = {'sub', 'rot', 'ses', 'blk', 'tri', 'itm', 'top', 'bot', 'rsp', 'cat', 'acc', 'rt'}; % Data columns

%% MDS information
if subject > 100 && subject < 200
    stimloc = dlmread(fullfile('MDS', 'SatOri_mds_constrained.crd')); % Stimulus locations
elseif (subject > 200 && subject < 300)
    stimloc = dlmread(fullfile('MDS', 'SizeSat_constrained.dat')); % Stimulus locations
else
    stimloc = dlmread(fullfile('MDS', 'SizeOri_constrained.dat')); % Stimulus locations
end
stimloc = stimloc(:,[2 1]);
n.items = size(stimloc,1);

subdata = sortrows(cedata, find(strcmp(cols, 'itm')));
data.resp = cedata(:,strcmp(cols, 'rsp'));
data.rt   = cedata(:,strcmp(cols, 'rt'))/1000;
data.item = cedata(:,strcmp(cols, 'itm'));
data.stimloc = stimloc;
