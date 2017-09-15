function [out, lnL] = logDensLikeFD(x, data, model)
% Free drift
% Organize parameters based on the model
% Use holmes PDA method to compute the likelihood for each data point
% Sum these loglikelihoods to compute the overall log likelihood

%% Set up the model 
stoppingrule = 'st';
fmodel = @simcoactive;

%% Transform parms back to correct range
names = fieldnames(x);
for i = 1:numel(names)
    if regexp(names{i}, 'v\d', 'once') == 1
        x.(names{i}) = logit(x.(names{i}), 'inverse');
        vc(i,1) = x.(names{i});
    end
end
x.A    = exp(x.A);
x.bMa1 = exp(x.bMa1);
x.bMa2 = exp(x.bMa2);
x.s    = exp(x.s);
x.t0   = exp(x.t0);
nitems = size(vc,1);

%% Organize the parameters for the model and loop through items
for i = 1:nitems
    parms(i).('vc') = vc(i,:);
    parms(i).('A') = x.('A');
    parms(i).('bMa') = [x.('bMa1'), x.('bMa2')];
    parms(i).('s') = x.('s');
    parms(i).('t0') = x.('t0');
end

%% Loop
fit = nan(nitems,1);
for i = 1:nitems
    iparms = parms(i);
    
    % Set up the data for the current item
    idata = [data.resp(data.item == i), data.rt(data.item == i)];
    
    % Get likelihood for each data point
    lik = pdaholmes(fmodel, 1e6, idata, iparms, stoppingrule);
    lnL{i} = lik;
    % Sum over all data points
    fit(i) = sum(log(lik));
end
out = sum(fit);