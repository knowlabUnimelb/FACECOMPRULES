function [fit, coordinates, R2] = mdsModelSC(parms, data, varargin)

optargs = {[1 8], 'euclidean', 2}; % 'cityblock'
newVals = cellfun(@(x) ~isempty(x), varargin);% skip any new inputs if they are empty
optargs(newVals) = varargin(newVals); % now put these defaults into the valuesToUse cell array, and overwrite the ones specified in varargin.
[simRange, distFun, r] = optargs{:}; % Place optional args in memorable variable names

%%
% if numel(parms) > 6
%     r = abs(parms(7));
%     parms = parms(1:6);
% end

m = parms(1);
b = parms(2);
x = [0 parms(3) 2*parms(3)];
y = [0 parms(4) 2*parms(4)];
sc = allcomb(x, y); % stimCoordinates 
sc = sc([9 8 6 5 7 4 3 2 1], :);
coordinates = [sc(:,1)', sc(:,2)'];

if strcmp(distFun, 'minkowski')
    cd = pdist(sc, distFun, r); % 
else
    cd = pdist(sc, distFun);
end

%% Function relating the distance to the similarity ratings is a negative linear function
% First scale all distance values to between 0 and 1
% simp = b - m * cd;
simp = b * exp(-m * cd);

fit = sum((simp - squareform(data, 'tovector')).^2);
[r, p] = corrcoef(simp, squareform(data, 'tovector')); 
R2 = r(1,2)^2;