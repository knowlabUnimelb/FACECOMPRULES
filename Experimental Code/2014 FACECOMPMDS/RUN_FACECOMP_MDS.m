%% MDS for GARNER INTEGRAL/HARD
clear all
clc
global ptb3
WaitSecs(1e-7); % Hack to load WaitSecs
warning('off', 'MATLAB:mex:deprecatedExtension')

% Screen('Preference', 'SkipSyncTests', 2 );

% Get PsychtoolboxVersion and adjust display mode if ptb version = 3
x = PsychtoolboxVersion; if ischar(x); ptb = str2double(x(1)); else ptb = x; end; ptb3 = ptb >= 3;

debug = false; % If debug = true, show stimulus layout upfront

%% Environment Variables
seed = 12699;            % Seed for random number generator
xup = -50; xleft = -18;  % center of screen offsets for showtext
bgcolor = [0 0 0]; % Background color

nstim = 9;  % Number of stimuli
nreps = 15; % Number of repetitions for pairs?

rkeys = {'1', '2', '3', '4', '5', '6', '7', '8'};
stimsize = 187; % Stimulus size
scalefact = 2;
isi = .5;       % Intertrial interval
%% Open Experiment Window
% Present subject information screen until correct information is entered
subject = []; 
subject = input('Enter Subject Number: ');

condition = []; 
condition = input('Enter Condition Number. 1 - Upright Aligned, 2 - Upright Misalign, 3 - Inverted Aligned, 4 - Inverted Misaligned: ');

screenparms = prepexp(0, bgcolor);     % Open onscreen window
rand ('state', seed + subject * 2); % Seed random number generator

datafile = ['FACERULES_FACECOMP_MDS_s' num2str(subject) '.dat'];
%% Set up lists
showtext(screenparms,  stimsize/10, 'Loading Lists...', 0, xup, xleft); if ptb3; Screen('Flip', screenparms.window); end
tic

ncombs = nchoosek(nstim,2);

% Generate all pairwise combinations
mcomb = unique(sort(allcomb(1:nstim, 1:nstim), 2), 'rows');
mcomb(mcomb(:,1) == mcomb(:,2), :) = [];

allCombs = repmat(mcomb, nreps, 1);         % replicate for the number of presentations
lrorder = rand(size(allCombs, 1), 1) <= .5; % random array for randomizing right/left presentation
allCombs(lrorder == 1, :) = fliplr(allCombs(lrorder == 1, :)); % randomize right/left presentation
allCombs = allCombs(randperm(ncombs * nreps), :);

showtext(screenparms,  stimsize/10, ['Loading Lists...Finished (' num2str(toc) ' seconds)'], 0, xup, xleft); if ptb3; Screen('Flip', screenparms.window); end
WaitSecs(.2);

%% Load all faces into visual memory of MATLAB

% Load Stimulus Set 6
switch condition    
    case 1
        stimbmps = {
            'Set_UA_1.bmp';...
            'Set_UA_2.bmp';...
            'Set_UA_3.bmp';...
            'Set_UA_4.bmp';...
            'Set_UA_5.bmp';...
            'Set_UA_6.bmp';...
            'Set_UA_7.bmp';...
            'Set_UA_8.bmp';...
            'Set_UA_9.bmp'};
    case 2
        stimbmps = {
            'Set_US_1.bmp';...
            'Set_US_2.bmp';...
            'Set_US_3.bmp';...
            'Set_US_4.bmp';...
            'Set_US_5.bmp';...
            'Set_US_6.bmp';...
            'Set_US_7.bmp';...
            'Set_US_8.bmp';...
            'Set_US_9.bmp'};
    case 3
        stimbmps = {
            'Set_IA_1.bmp';...
            'Set_IA_2.bmp';...
            'Set_IA_3.bmp';...
            'Set_IA_4.bmp';...
            'Set_IA_5.bmp';...
            'Set_IA_6.bmp';...
            'Set_IA_7.bmp';...
            'Set_IA_8.bmp';...
            'Set_IA_9.bmp'};
    case 4
        stimbmps = {
            'Set_IS_1.bmp';...
            'Set_IS_2.bmp';...
            'Set_IS_3.bmp';...
            'Set_IS_4.bmp';...
            'Set_IS_5.bmp';...
            'Set_IS_6.bmp';...
            'Set_IS_7.bmp';...
            'Set_IS_8.bmp';...
            'Set_IS_9.bmp'};
end

proportionA = [.5, .25, 0];
proportionC = [.5, .25, 0];

proportionB = .5 - proportionA;
proportionD = .5 - proportionC;

showtext(screenparms,  stimsize/10, 'Loading Stimuli...', 0, xup, xleft); 
Screen('Flip', screenparms.window);

% LOAD STIMULI INTO TEXTURES
% Initialize progress bar
ProgBar = DrawProgressBar(screenparms, size(stimbmps,1), 'Generating Stimuli'); Screen('Flip', screenparms.window);

stimTexture = cell(size(stimbmps,1),1); % Initialize cell matrix for textures
% [intstimloc, dh, dv] = CenterRect([0,0, colorsize, colorsize], screenparms.rect); % Get the rectangle position of the stimulus in the center of the display
% intstimmat = ones(screenparms.rect(4), screenparms.rect(3), 3) * screenparms.screen(1); % initialize stimulus matrix screenheight x screenwidth x 3 matrix of ones

for i = 1:size(stimbmps,1)
    stimInfo = imfinfo(fullfile(pwd, 'Stimuli', stimbmps{i}));
    stimImage = imread(fullfile(pwd, 'Stimuli', stimbmps{i}), stimInfo.Format);
%     stimImage = imresize(stimImage,1,'Colormap','original');
    if size(stimImage, 3) == 1
        stimImage = ind2rgb(imread(fullfile(pwd, 'Stimuli', stimbmps{i}), stimInfo.Format), stimInfo.Colormap) * 255;
    end
    
    [stimRect,dh,dv] = CenterRect([0 0 stimInfo.Height stimInfo.Width], screenparms.rect);
    stimTexture{i} = Screen('MakeTexture', screenparms.window, stimImage);
    
    ProgBar(i); Screen('Flip', screenparms.window); % Update the progress bar
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

showtext(screenparms,  stimsize/10, ['Loading Stimuli...Finished (' num2str(toc) ' seconds)'], 0, xup, xleft); if ptb3; Screen('Flip', screenparms.window); end
WaitSecs(.2);

% Response Variables
resp = char(ones(size(allCombs)) * 32); % 32 is ascii map code to ' '
t    = zeros(size(allCombs,1),1);

%% Set up presentation areas
fullscreen = screenparms.rect;
[cx, cy] = RectCenter(fullscreen);
upperleft = [fullscreen(1) fullscreen(2) cx cy];
upperright = [cx fullscreen(2) screenparms.rect(3) cy];
[centerscreen, dh, dv] = CenterRect(upperleft, fullscreen);

% DL 6/9/12: Here I just center the image within each of those quadrants
stimInfo.Width = stimInfo.Width;
stimInfo.Height = stimInfo.Height;
upperleft = CenterRect([0 0 stimInfo.Width stimInfo.Height], upperleft);
upperright = CenterRect([0 0 stimInfo.Width stimInfo.Height], upperright);

upperleft([1 3]) = upperleft([1 3]) + 100;
upperright([1 3]) = upperright([1 3]) - 100;
% upperleft([2 4]) = upperleft([2 4]) + 120;
% upperright([2 4]) = upperright([2 4]) + 120;

%% Present instructions
instPage = {'Instructions1.bmp', 'Instructions2.bmp', 'Instructions3.bmp', 'Instructions4.bmp'};
expPage  = {'ExamplePage1.bmp', 'ExamplePage2.bmp', 'ExamplePage3.bmp', 'ExamplePage4.bmp'};
showInstructions(screenparms, fullfile(pwd, 'Instructions', instPage{condition}))
showInstructions(screenparms, fullfile(pwd, 'Instructions', expPage{condition}))

%% Show Trials
cnt = 1;
waitfkey (screenparms, stimsize, 'Press SPACE to start similarity comparisons');
for i = 1:size(allCombs,1)
    % Show Fixation Cross
    showtext(screenparms,  stimsize/3, '+', 0, xup, xleft); 
    Screen('Flip', screenparms.window); 
    WaitSecs(isi);
    
    % Present item 1
    Screen('DrawTexture', screenparms.window, stimTexture{allCombs(i,1)}, [], upperleft); %Screen('Flip', screenparms.window);
    % Present item 2
    Screen('DrawTexture', screenparms.window, stimTexture{allCombs(i,2)}, [], upperright); %Screen('Flip', screenparms.window);
    
    showtext(screenparms,  stimsize/6, '       1 - 2 - 3 - 4 - 5 - 6 - 7 - 8      ', 0, 200, -50);
    showtext(screenparms,  stimsize/8, 'Least Similar - - - - - - - - Most Similar', 0, 300, -75);
    Screen('Flip', screenparms.window);
    
    % Record response
    while ~any(strcmp(resp(cnt,1),  rkeys));
        [resp(cnt,1), t(cnt,1)] = getresponse;
    end
    FillScreen(screenparms); 
    Screen('Flip', screenparms.window);
    WaitSecs(isi);
    
    % Insert a short break at every 1/12 trials
    if ismember(cnt, round((size(allCombs,1))/12) * (1:12))
        waitfkey (screenparms, stimsize, 'Please press SPACE after a short break');
        FillScreen(screenparms); 
        Screen('Flip', screenparms.window);
        WaitSecs(1);
    end
    cnt = cnt + 1;
end
totalTrials = cnt-1;

%% Record Output
showtext(screenparms,  stimsize/10, 'Recording Data...', 0, xup, xleft); 
Screen('Flip', screenparms.window);

% Organize output
% allCombs = [tempallCombs(tempallCombs(:,3) == hueorder(1), 1:2); tempallCombs(tempallCombs(:,3) == hueorder(2), 1:2); tempallCombs(tempallCombs(:,3) == hueorder(3), 1:2)];
response = str2num(resp(1:totalTrials,:));
output = [repmat([subject, condition], totalTrials,1), allCombs(1:totalTrials,:), response, t(1:totalTrials,1)];
% Output file = [Subject, M1, M2, response, time]
dlmwrite(datafile, output, '-append');

showtext(screenparms,  stimsize/10, ['Recording Data...Finished (' num2str(toc) ' seconds)'], 0, xup, xleft); 
Screen('Flip', screenparms.window);
waitfkey (screenparms, stimsize, 'Please call the experimenter');
Screen('Flip', screenparms.window);

WaitSecs(.2);
closeexp(screenparms) %% Close experiment
