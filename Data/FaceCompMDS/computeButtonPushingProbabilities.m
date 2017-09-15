function posterior = computeButtonPushingProbabilities(data, eps)
% Compute posterior probability under uniform prior that subject is making
% the responses with a roughly uniform probability.  Comparison models are
% pushing one button only (8 models) and pushing two buttons only (8 choose
% 2 models)
%
% data is mdsdata (columns: subject, condition, item1, item2, rating)


subjects = unique(data(:,1));
buttonCounts = aggregate(data, [1 5], 5, @count);

% eps = .25; 

model0 = repmat(1/8, 1, 8);

model1 = eye(8); 
model1 = model1 .* (1 - eps);
model1(model1 == 0) = eps/7;

model2idx = sort(allcomb(1:8, 1:8), 2);
model2idx(model2idx(:,1) == model2idx(:,2),:) = []; 
model2 = zeros(size(model2idx, 1), 8); 
for i = 1:size(model2,1);
   model2(i, model2idx(i,:)) = (1 - eps)/2; 
end
model2 = unique(model2, 'rows');
model2(model2 == 0) = eps/6;

logprior = log(1./(size([model0; model1; model2], 1)));

for i = 1:numel(subjects)
    subcounts = aggregate(data(data(:,1) == subjects(i), :), [1 5], 5, @count); subcounts(:,1) = []; 
    subcounts = fillMissingCounts(subcounts, 1:8);
    logp = logmnpdf(subcounts(:,2)', [model0; model1; model2]);
    logsum = log(sum(mnpdf(subcounts(:,2)', [model0; model1; model2]) .* exp(logprior)));
    
    posterior(:,i) = logp + logprior - logsum;
end
posterior = exp(posterior(1,:));