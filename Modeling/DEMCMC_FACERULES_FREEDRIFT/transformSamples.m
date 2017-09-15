function transformedSamples = transformSamples(theta, data)

names = fieldnames(theta);
for i = 1:numel(names)
    switch names{i}
        case {'A', 'bMa1', 'bMa2', 's', 't0'}
            transformedSamples.(names{i}) = exp(theta.(names{i}));
        case {'v1', 'v2', 'v3', 'v4', 'v5', 'v6', 'v7', 'v8', 'v9'}
            transformedSamples.(names{i}) = logit(theta.(names{i}), 'inverse');
    end
       
end