function output = fillMissingCounts(incounts, values)
% FILLMISSINGCOUNTS Fill in missing indexes 
%   FILLMISSINGCOUNTS(X,I) takes a matrix of values, X, in which the first
%   value is an index to a condition (such as returned from the AGGREGGATE
%   function) and checks for any missing indexes included in the vector, I.
%   These indexes are given values of 0 in the remaining columns;
%
% Example: 
% 
% data = [...
%             1      0.70605
%             1     0.031833
%             1      0.27692
%             3     0.046171
%             3     0.097132
%             3      0.82346
%             3      0.69483
%             3       0.3171
%             4      0.95022
%             4     0.034446
%         ];
%
% >> X = aggregate(X, 1, 2)
% 
% X =
% 
%             1      0.33827
%             3      0.39574
%             4      0.49233
%
% >> Y = fillMissingCounts(ans, [1 2 3 4])
% 
% Y =
% 
%             1      0.33827
%             2            0
%             3      0.39574
%             4      0.49233
%
% See also: aggregate

output = []; 
for i = 1:(numel(values))
    if ~isempty(incounts(incounts(:,1) == values(i)))
        output = [output; incounts(incounts(:,1) == values(i), :)];
    else
        output = [output; values(i), zeros(1, size(incounts, 2)-1)];
    end
end