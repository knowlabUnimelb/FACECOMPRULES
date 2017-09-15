%% Analysis_FaceComp_MDS

%% Clear Variable Space

clear all
close all
clc

%% Extract Data From Folder
% Find the files
data_folder     = {'Data'};
temp_dir        = dir(fullfile(pwd,data_folder{1}));

for i = 3:size(temp_dir,1);
    file_list{i-2} = temp_dir(i).name;
end % for i

% Collect the data
data = [];

for i = 1:size(file_list,2);
    temp_var = dlmread(fullfile(pwd,data_folder{1},file_list{i}));
    temp_var = temp_var(:,1:5);
    data = [data; temp_var];
end % for i...

subs    = unique(data(:,1));
nsubs   = numel(subs);
nstim   = 9;

data(:,5) = 8 - data(:,5);

temp_mds = [];
temp_rot = [];

targetCoordinates = [];
targetCoordinates(:,:,1) = [3 3; 3 1.67; 1.67 3; 1.67 1.67; 3 1; 1.67 1; 1 3; 1 1.67; 1 1];
targetCoordinates(:,:,2) = [3 3; 3 1.67; 1.67 3; 1.67 1.67; 3 1; 1.67 1; 1 3; 1 1.67; 1 1];
targetCoordinates(:,:,3) = [3 3; 3 2; 2 3; 2 2; 3 1; 2 1; 1 3; 1 2; 1 1];
targetCoordinates(:,:,4) = [3 3; 3 2; 2 3; 2 2; 3 1; 2 1; 1 3; 1 2; 1 1];

for i = 1:nsubs
    pdata       = data(data(:,1) == subs(i),:);
    pnum        = subs(i);
    condition   = mean(pdata(:,2));
    
    ideal       = targetCoordinates(:,:,condition);
    
%     % Find distance between each item in category space
%     cnt = 1;
%     dists = nan(nstim^2,1);
%     for k = 1:nstim
%         for l = 1:nstim
%             dists(cnt,1) = sqrt(sum((x(k,:) - x(l,:)).^2));
%             cnt = cnt + 1;
%         end
%     end
%     
%     % This matches the each possible pairing to their distances
%     xx = sort(allcomb(1:nstim,1:nstim),  2);
%     
%     [a,b] = unique(xx, 'rows'); xxx = xx(b,:);
%     dists = dists(b);
%     [ii,jj] = find(xxx(:,1) ~= xxx(:,2)); xxxx = xxx(ii,:);
%     dists = dists(ii);
    
    %     tdata = aggregate([sort(pdata(:, 3:4), 2), pdata(:,5)], 1:2, 3);
    
    %     tdata = aggregate(pdata, [3 4], 5);
    %     [r, p] = corrcoef(tdata(:,3), dists);
    %     subcorrs(i,2) = r(1,2);
    %     subcorrs(:,1) = pnum;
%     subdata = [pdata(:,1), sort(pdata(:, 3:4), 2), pdata(:,5)];
    %
    
    %% Organize data
    aggdata.data    = aggregate([sort(pdata(:, 3:4), 2), pdata(:,5)], 1:2, 3);
    aggdata.std     = aggregate([sort(pdata(:, 3:4), 2), pdata(:,5)], 1:2, 3,@std);
    aggdata.sdata   = squareform(aggdata.data(:,3), 'tomatrix');
    aggdata.sqstd   = squareform(aggdata.std(:,3), 'tomatrix');
    
    %% Do MDS
    [aggdata.cmdY, aggdata.cmdeigvals] = cmdscale(aggdata.sdata);
    aggdata.cmdevals = [aggdata.cmdeigvals aggdata.cmdeigvals/max(abs(aggdata.cmdeigvals))];
    
    [aggdata.Y, aggdata.stress, aggdata.disparities] = mdscale(aggdata.sdata, 2);
    
    temp_mds = [temp_mds;[repmat(pnum,nstim,1), aggdata.Y]];
    
    %% Do Procrustes Rotation
    
    [fit_value, rot_space] = procrustes(ideal,[aggdata.Y(:,1),aggdata.Y(:,2)]);
    
    temp_rot = [temp_rot;[repmat(pnum,nstim,1), rot_space]];
    
    %% Plot Data
    figure('WindowStyle','Docked','Color',[1 1 1]);
    subplot(1,2,1)
    plot(aggdata.Y(:,1), aggdata.Y(:,2), ' ok')
    text(aggdata.Y(:,1), aggdata.Y(:,2)+.1, {'HH', 'HL', 'LH', 'LL', 'Ex', 'Ix', 'Ey', 'Iy', 'R'}, 'FontSize', 15);
    title('Fitted Solution', 'Fontsize', 15);
    axis square
    
    subplot(1,2,2)
    plot(rot_space(:,1), rot_space(:,2), ' ok')
    text(rot_space(:,1), rot_space(:,2)+.1, {'HH', 'HL', 'LH', 'LL', 'Ex', 'Ix', 'Ey', 'Iy', 'R'}, 'FontSize', 15);
    set(gca, 'XLim', [0 4], 'YLim', [0 4])
    title('Procrustes Rotation', 'Fontsize', 15);
    axis square
    
    temp = ['Participant: ' num2str(pnum)];
    supertitle(temp)
end % for i...

