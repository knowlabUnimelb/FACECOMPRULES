function [fit, coordinates, R2] = mdsModel0(parms, data, varargin)

optargs = {[1 8], 'euclidean', 2}; % 'cityblock'
newVals = cellfun(@(x) ~isempty(x), varargin);% skip any new inputs if they are empty
optargs(newVals) = varargin(newVals); % now put these defaults into the valuesToUse cell array, and overwrite the ones specified in varargin.
[simRange, distFun, r] = optargs{:}; % Place optional args in memorable variable names

%%
if numel(parms) > 18
    r = parms(21);
    parms = parms(1:18);
end

m = parms(1);
b = parms(2);
ncoordinates = numel(parms) - 2;

% x = parms(3:(3 + ncoordinates/2 - 1)); 
% y = parms((3 + ncoordinates/2):numel(parms));

x = [parms(3:(3 + ncoordinates/2 - 1)); 0]; % Last x point is fixed at 0
y = [parms((3 + ncoordinates/2):numel(parms)); 0]; % Last y point is fixed at 0
coordinates = [x', y'];
sc = [x y]; % stimCoordinates

if strcmp(distFun, 'minkowski')
    cd = pdist(sc, distFun, r); %
else
    cd = pdist(sc, distFun);
end

%% Function relating the distance to the similarity ratings is a negative linear function
% First scale all distance values to between 0 and 1
% scd = cd./max(cd);
% simp = simRange(2) - (simRange(2)-simRange(1)) * scd; % Predicted similarity ratings
simp = b - m * cd;

fit = sum((simp - squareform(data, 'tovector')).^2);

[R1, p] = corrcoef(simp, squareform(data, 'tovector'));
R2 = R1(1,2)^2;

% save('temp');
end

