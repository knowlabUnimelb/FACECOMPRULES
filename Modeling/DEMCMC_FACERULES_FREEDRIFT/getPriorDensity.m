function pdf = getPriorDensity(varname, xval, hyperprior)
% See makePriorDistribution

switch varname
    case {'v1', 'v2', 'v3', 'v4', 'v5', 'v6', 'v7', 'v8', 'v9', 'A', 'bMa1', 'bMa2', 's', 't0'}
        pdf = lognormpdf(xval, hyperprior(1), hyperprior(2));
end