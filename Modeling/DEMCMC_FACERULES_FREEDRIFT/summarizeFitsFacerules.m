clear all
clc

% delete 2 (103) , 9 (208)
subjects = 206; %[ 101 105 107 109 202 204 206 210 301 302 303 304 306 401 402 403 404]; % These need to match datafiles in the Data folder
    models = {'freedriftst'};
    subdic1 = nan(numel(subjects),numel(models));
    subdic2 = nan(numel(subjects),numel(models));
for sidx = 1:numel(subjects)
    disp(sidx)
    subject = subjects(sidx);
    fitfolder = fullfile(pwd, 'Fits', 'Facerules');

    
    dic1 = nan(1,numel(models));
    dic2 = nan(1,numel(models));
    for i = 1:numel(models)
        if exist(fullfile(fitfolder, sprintf('s%d_%s_t.mat', subject, models{i})), 'file') == 2
        load(fullfile(fitfolder, sprintf('s%d_%s_t.mat', subject, models{i})), 'model', 'data', 'theta', 'logtheta', 'weight', 'n')
%         n.burnin = n.burnin + 500;
        n.burnin = n.mc - 750;
        dic1(1,i) = computeDIC(model, data, logtheta, weight(:,n.burnin:end), n.burnin, 1);
        dic2(1,i) = computeDIC(model, data, logtheta, weight(:,n.burnin:end), n.burnin, 2);
%         waic(1,i) = computeWAIC(data, logtheta, model, n);
        names = fieldnames(theta);
       
%         for pidx = 1:numel(names);
%             summary = mcmcsumm(logtheta.(names{pidx})(:,n.burnin+1:end));
%             gr.theta{sidx}(i, pidx) = summary.gr2max;
%         end
%         plotPosteriors
        end
    end
%     [~, submidx(:,sidx)] = min([dic1; dic2], [], 2);
    subdic1(sidx,:) = dic1;
    subdic2(sidx,:) = dic2;
%     subwaic(sidx,:) = waic;
end
% delete(gcp('nocreate'))