%% Check for Incomplete datasets

clear all
close all
clc

data    = dlmread('Condition 5-8.txt');

plist   = unique(data(:,1));
pno     = size(plist,1);

datasize    = 3*72;
cutoff      = 72;
output      = [];
incomplete  = [];

for  i = 1:pno 
    pdata = data(data(:,1) == plist(i),:);
    if size(pdata,1) >= cutoff
        pdata(:,1)  = repmat(i, size(pdata,1),1);
        output      = [output; pdata];
    else
        incomplete  = [incomplete;plist(i) size(pdata,1)]; 
    end
end 

% Include one participant who is missing only two trials
% pdata       = data(data(:,1) == incomplete(4,1),:);
% pdata(:,1)  = repmat(i+1, size(pdata,1),1);

% output = [output; pdata];

% Write to Output
% dlmwrite('CompositeRules_5_8_2block.dat',output);

disp(aggregate(aggregate(output,[1 2], 3, @count),2,3,@count))