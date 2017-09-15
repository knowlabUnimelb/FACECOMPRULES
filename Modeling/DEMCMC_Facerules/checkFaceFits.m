% Need to ensure that I've used the correct MDS for each fit
clear all
clc

fitlocation = 'C:\Users\littled\Dropbox\Fast Machine 2\DEMCMC\Fits\Facerules';

models = {'serialst', 'parallelst', 'coactive  ', 'serialex', 'parallelex', 'mixedSPst'};
subjects = [101 103 105 107 109 202 204 208 210 301 302 303 304 306 401 402 403 404]; % These need to match datafiles in the Data folder

bad = []; good = [];
for sidx = 1:numel(subjects)
    for midx = 1:numel(models)
        keep models subjects sidx midx fitlocation bad good
        
        % Model to estimate
        subject = subjects(sidx);
        stoppingrule = models{midx}(end-1:end); % Options: {'st', 'ex', '  '} - Use '  ' for coactive model
        model = models{midx}; % ['parallel', stoppingrule]; % Options: {'serial', 'parallel', 'coactive', 'mixedSP'}
        
        %% Correct MDS infromationcorr
        if subject > 100 && subject < 200
            correctStimLoc = dlmread(fullfile('MDS', 'CompFaceRules_1_constrained.crd')); % Stimulus locations
        elseif subject > 200 && subject < 300
            correctStimLoc = dlmread(fullfile('MDS', 'CompFaceRules_2_constrained.crd')); % Stimulus locations
        elseif subject > 300 && subject < 400
            correctStimLoc = dlmread(fullfile('MDS', 'CompFaceRules_3_constrained.crd')); % Stimulus locations
        else
            correctStimLoc = dlmread(fullfile('MDS', 'CompFaceRules_4_constrained.crd')); % Stimulus locations
        end
        
        if exist(fullfile(fitlocation, sprintf('s%d_%s.mat', subject, model)), 'file') == 2
            load(fullfile(fitlocation, sprintf('s%d_%s.mat', subject, model)), 'stimloc')
            
            if ~all(stimloc == correctStimLoc)
                bad = [bad; subject find(strcmp(model, models))];
                fprintf('Subject %d , Model Fit %s is bad\n', subject, model);
            else
                good = [good; subject find(strcmp(model, models))];
            end
        else
            fprintf('\nMissing File %s\n', sprintf('s%d_%s.mat', subject, model));
        end
    end
end