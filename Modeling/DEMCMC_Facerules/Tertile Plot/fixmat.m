clear all
clc

% subjects =  [101 105 107 109 202 206 210 301 302 303 304 306 401 402 403 404];
subjects = 204;

for i = 1:numel(subjects);
    load(sprintf('s%dplotData.mat', subjects(i)));
    sim.resp = sim.resp(:,find(~cellfun(@isempty, sim.rt(1,:))));
    sim.rt = sim.rt(:,find(~cellfun(@isempty, sim.rt(1,:))));
    save(sprintf('s%dplotData.mat', subjects(i)), 'data', 'sim');
end