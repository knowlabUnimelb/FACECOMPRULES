% Load separable data
function [data, cols] = loadData(subject)

load(fullfile('Data', 'FacecompRules', sprintf('s%d_cedata.mat', subject))) % Load data
cols = {'sub', 'con', 'rot', 'ses', 'blk', 'tri', 'itm', 'top', 'bot', 'rsp', 'cat', 'acc', 'rt'}; % Data columns

%% MDS information
if subject > 100 && subject < 200
    stimloc = dlmread(fullfile('MDS', 'CompFaceRules_1_constrained.crd')); % Stimulus locations
elseif subject > 200 && subject < 300
    stimloc = dlmread(fullfile('MDS', 'CompFaceRules_2_constrained.crd')); % Stimulus locations
elseif subject > 300 && subject < 400
    stimloc = dlmread(fullfile('MDS', 'CompFaceRules_3_constrained.crd')); % Stimulus locations
else
    stimloc = dlmread(fullfile('MDS', 'CompFaceRules_4_constrained.crd')); % Stimulus locations
end
n.items = size(stimloc,1);

subdata = sortrows(cedata, find(strcmp(cols, 'itm')));
data.resp = cedata(:,strcmp(cols, 'rsp'));
data.resp(data.resp == 2) = 0; data.resp = data.resp + 1;
data.rt   = cedata(:,strcmp(cols, 'rt'))/1000;
data.item = cedata(:,strcmp(cols, 'itm'));
data.stimloc = stimloc;
