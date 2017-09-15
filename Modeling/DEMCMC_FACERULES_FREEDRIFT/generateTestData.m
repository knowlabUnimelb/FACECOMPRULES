function [data, parms] = generateTestData(model, nd, stimloc, varargin)

optargs = {.5, .5, .5, .5, .5, .5, .5, .5, .5,...
     .75, .25, .25, .1, .3};
newVals = cellfun(@(x) ~isempty(x), varargin); % skip any new inputs if they are empty
optargs(newVals) = varargin(newVals); % now put these defaults into the valuesToUse cell array, and overwrite the ones specified in varargin.
[v1,v2, v3, v4, v5, v6, v7, v8, v9, A, bMa1, bMa2, s, t0] = optargs{:}; % Place optional args in memorable variable names

parms = struct('v1', v1, 'v2', v2, 'v3', v3, 'v4', v4,...
                'v5', v5, 'v6', v6, 'v7', v7, 'v8', v8, 'v9', v9,...
               'A', A, 'bMa1', bMa1, 'bMa2', bMa2, 's', s, 't0', t0);

%% Parameters
stoppingrule = model(end-1:end);

vc = [v1 v2 v3 v4 v5 v6 v7 v8 v9]'; % Drift rate for the "A" accumulator

%% Simulate data
n.items = size(vc,1);

data = struct('rt', [], 'resp', [], 'item', [], 'stimloc', stimloc);
for i = 1:n.items
    simparms = struct('vc', vc(i,:), 'A', parms.A, 'bMa', [parms.bMa1, parms.bMa2], 's', parms.s, 't0', parms.t0);

    [rt, resp] = simcoactive(nd, simparms, stoppingrule);
    
    data.rt = [data.rt; rt];
    data.resp = [data.resp; resp];
    data.item = [data.item; i * ones(nd, 1)];
end

maxrt = 10;
data.resp(data.rt > maxrt) = [];
data.item(data.rt > maxrt) = [];
data.rt(data.rt   > maxrt) = [];
