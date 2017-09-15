% 2014 Semester 1
% Composite/Split Face Experiment
% Condition 1: Upright, aligned face morphs
% Condition 2: Upright, split face morphs
% Condition 3: Inverted, aligned face morphs
% Condition 4: Inverted, split face morphs
% Condition 5: Upright, aligned schematic faces
% Condition 6: Upright, split schematic faces
% Condition 7: Inverted, aligned schematic faces
% Condition 8: Inverted, split schematic faces
%
% Reference: Fific, Little & Nosofsky (2010; Psy Review), Little, Nosofsky &
% Denton (2011; JEP:LMC), Little, Nosofsky, Donkin & Denton (2013)
%
% There are two categories defined as follows:
%
%  7  |  3     1
%     |
%  8  |  4     2
%     |------------
%  9     6     5
%
% For this version, the stimulus spacings are:
%
%
%   .2
%
%   .6
%   .8
%      .8 .6    .2

%%
clear all
clc
global ptb3
x = PsychtoolboxVersion; if ischar(x); ptb = str2double(x(1)); else ptb = x; end; ptb3 = ptb >= 3;

WaitSecs(1e-7); % Hack to load WaitSecs
warning('off', 'MATLAB:mex:deprecatedExtension')

% If debug == true, do experiment with reduced number of trials
debug = false; %
debugCondition = 1;
debugRotation  = 1;

%% Environment Variables
xup = -50; xleft = -18; % center of screen offsets for showtext
bgcolor = [0 0 0]; % User specified background color
txtColor = [255 255 255];
stimsize = 187;
feedback = {'...Wrong...', '...Correct...'};
textsize = 60;

timeout = 5;

resizeProportion = .6;

%% Experimental Variables
seed = 34694;
fixationDuration = 1.5;  % Fixation cross presentation length (1.77 secs)
fbkDuration      = 2;     % Feedback presentation length
iti              = 2;  % Intertrial interval

switch debug % Reduce the number of trials for debugging
    case true
        RTBox('fake',1);
        nPracTrials = 0;                     % Number of practice trials = 38 (25 Stimuli * 1)
        nExpTrials  = 9;                    % Number of experimental trials = 9 Stimuli * 10 reps * 9 blocks = 810
        nBlocks = 2;                          % Number of blocks = 3
        nExpTrials = nExpTrials * nBlocks;
        nTrialsPerBlock = nExpTrials/nBlocks; % Number of trials per block = 135
    case false
        nPracTrials = 9;                     % Number of practice trials = 38 (25 Stimuli * 1)
        nExpTrials  = 450;                    % Number of experimental trials = 9 Stimuli * 10 reps * 9 blocks = 810
        nBlocks = 10;                          % Number of blocks = 3
        nTrialsPerBlock = nExpTrials/nBlocks; % Number of trials per block = 135
end

%% Open Experiment Window
% Present subject information screen until correct information is entered
subject     = input('Enter Subject Number [201-299]:');
session     = input('Enter Session Number [1-5]:');
condition   = input('Enter Condition Number [1-8]:');
rotation  = 1; %presetRotation;

screenparms = prepexp(bgcolor); % Open onscreen window
% rng(seed + subject * 2)
rand ('state', seed + subject * 2 + session); % Seed random number generator

stimulusCondition = condition;
outputfile = sprintf('2014_comprules_s%03d_con%d_ses%d.dat', subject, condition, session);


%% Face Stimulus Set
if condition <= 4
    basetop = {'dDX0202.bmp', 'dDX0303.bmp', 'dDX0505.bmp'};
    basebot = {'dDY0202.bmp', 'dDY0303.bmp', 'dDY0505.bmp'};
else
    basetop = {'SX0101.bmp', 'SX0202.bmp', 'SX0303.bmp'};
    basebot = {'SY0101.bmp', 'SY0202.bmp', 'SY0303.bmp'};
end

% Define stimulus coordinates by the top half and the bottom half
stimuli = [3 3; 3 2; 2 3; 2 2; 3 1; 2 1; 1 3; 1 2; 1 1];

%%
% Different boundary rotation: case 1 is canonical target items, case 2 is
% 90 deg clockwise rotation, case 3 is 180 degree clockwise rotation, case
% 4 is 270 degree clockwise rotation
switch rotation
    case 1
        feedbackprobs(:,1) = [1 1 1 1 0 0 0 0 0]';   % Category A feedback for each item
        stimNumbers = [1 2 3 4 5 6 7 8 9];
    case 2
        feedbackprobs(:,1) = [0 1 0 1 1 1 0 0 0]';   % Category A feedback for each item
        stimNumbers = [7 3 8 4 1 2 9 6 5];
    case 3
        feedbackprobs(:,1) = [0 0 0 1 0 1 0 1 1]';   % Category A feedback for each item
        stimNumbers = [9 6 8 4 5 2 7 3 1];
    case 4
        feedbackprobs(:,1) = [0 0 1 1 0 0 1 1 0]';   % Category A feedback for each item
        stimNumbers = [5 6 2 4 9 8 1 3 7];
end
feedbackprobs(:,2) = 1 - feedbackprobs(:,1); % Category B feedback for each item

%% LOAD STIMULI INTO TEXTURES
% Initialize progress bar
ProgBar = DrawProgressBar(screenparms, size(stimuli,1), 'Generating Stimuli', txtColor); Screen('Flip', screenparms.window);

stimHeight = 400;
stimWidth  = 340;
baseRect   = [0 0 stimWidth stimHeight];
screenRect = [0 0 1280 1024];
stimRect   = CenterRect(baseRect, screenRect);

% These will vary by condition
% topRect    = [stimRect(1), stimRect(2), stimRect(3), stimRect(4)/2];
% botRect    = [stimRect(1), stimRect(4)/2, stimRect(3), stimRect(4)];

% Gaussian Blur vars
X = -stimWidth/2:stimWidth/2 - 1;
Y = -stimHeight/2:stimHeight/2 - 1;
XY = allcomb(X, Y);

if condition <= 4 % Morphs
    mX = 10; 
    mY = 1;
    sdX = 2000;
    sdY = 9000;
else              % Schematic Faces
    mX = 1;
    mY = 1;
    sdX = 3000;
    sdY = 9000;  
end
Z = mvnpdf(XY, [mX mY], [sdX, 0; 0 sdY]); % Gaussian Blur [Xmean, Ymean], [Xstd, 0; 0, Ystd]

% Bar separating top and bottom halves
barWidth   = 10;

% Offset
offsetWidth = 100;

stimTexture = cell(size(stimuli,1),1); % Initialize cell matrix for textures
for i = 1:size(stimuli,1)
    topInfo  = imfinfo(fullfile(pwd, 'BaseFaces', basetop{stimuli(i,1)}));
    botInfo  = imfinfo(fullfile(pwd, 'BaseFaces', basebot{stimuli(i,2)}));
    
    topImage = imread(fullfile(pwd, 'BaseFaces', basetop{stimuli(i,1)}), topInfo.Format);
    botImage = imread(fullfile(pwd, 'BaseFaces', basebot{stimuli(i,2)}), botInfo.Format);
    
    if size(topImage, 3) == 1; topImage = ind2rgb(imread(fullfile(pwd, 'BaseFaces',  basetop{stimuli(i,1)}), topInfo.Format), topInfo.Colormap) * 255; end
    if size(botImage, 3) == 1; botImage = ind2rgb(imread(fullfile(pwd, 'BaseFaces',  basebot{stimuli(i,2)}), botInfo.Format), botInfo.Colormap) * 255; end
    
    % If aligned then align top and bottom halves
    if ismember(condition, [1 3 5 7]);
        stimImage = zeros(size(topImage, 1), size(topImage, 2), 3);
        for j = 1:3
            stimImage(:,:,j) = [topImage(1:size(topImage,1)/2, :, j);
                                botImage(1 + size(topImage,1)/2:end, :, j)];
        end
    else
        stimImage = zeros(size(topImage, 1), offsetWidth + size(topImage, 2), 3);
        for j = 1:3
            stimImage(:,:,j) = [topImage(1:size(topImage,1)/2, :, j), zeros(size(topImage,1)/2, offsetWidth);
                                zeros(size(topImage,1)/2, offsetWidth), botImage(1 + size(topImage,1)/2:end, :, j)];
        end
    end
    
    % Add Gaussian blur
    Z3 =  repmat(reshape(Z, stimHeight, stimWidth), [1 1 3]); 
    if ~ismember(condition, [1 3 5 7])
        expandZ3 = nan(size(stimImage));
        for j = 1:3
            expandZ3(:, :, j) = [Z3(1:size(topImage,1)/2, :, j), zeros(size(topImage,1)/2, offsetWidth);
                                 zeros(size(topImage,1)/2, offsetWidth), Z3(1 + size(topImage,1)/2:end, :, j)];
        end
        Z3 = expandZ3;
    end
    stimImage = (stimImage .* Z3)./max(max(max((stimImage .* Z3)))) * 255;
    
    % Add black bar across split
    if condition <= 4
        stimImage(size(stimImage, 1)/2 - barWidth/2:size(stimImage, 1)/2 + barWidth/2, :, :) = 0;
    else
        stimImage(size(stimImage, 1)/2 - barWidth/2 + 10:size(stimImage, 1)/2 + barWidth/2 + 10, :, :) = 0;
    end
    
    % Resize 
    stimImage = imresize(stimImage, resizeProportion, 'Colormap', 'original');
    if resizeProportion < 1
        stimImage(stimImage < 0 ) = 0; stimImage(stimImage > 255) = 255; 
    end
    
    
    % Get rect
    [stimRect,dh,dv] = CenterRect([0 0 size(stimImage, 1), size(stimImage, 2)], screenparms.rect);
    
    % Save to texture
    stimTexture{i} = Screen('MakeTexture', screenparms.window, stimImage);
    ProgBar(i); Screen('Flip', screenparms.window); % Update the progress bar
end

%% PRESENT INSTRUCTIONS
instructionFolder = 'Instructions';
trainingInstructions = {'Instructions.bmp', sprintf('Instructions Condition %d.bmp', condition)};
showInstructions(screenparms, fullfile(pwd, instructionFolder, trainingInstructions{1}), 'RTBox')
showInstructions(screenparms, fullfile(pwd, instructionFolder, trainingInstructions{2}), 'RTBox')

breakImage = (fullfile(pwd, instructionFolder, 'Break.bmp'));
endImage = (fullfile(pwd, instructionFolder, 'Thanks.bmp'));

%% Run Experiment
nstim = size(stimuli, 1);
breaktrials = nTrialsPerBlock * (1:nBlocks-1) + nstim;
overallcorrect=[];
for bblocks = 1:nBlocks
    if bblocks > 1; nPracTrials = 0; end
    output = [];
    
    % Preload variables
    pracStimInOrder     = repmat((1:nstim)', nPracTrials/nstim, 1);
    pracCurrentStimulus = pracStimInOrder(randperm(numel(pracStimInOrder)));
    expStimInOrder      = repmat((1:nstim)', nTrialsPerBlock/nstim, 1);
    expCurrentStimulus  = expStimInOrder(randperm(numel(expStimInOrder)));
    currentStimulus     = [pracCurrentStimulus; expCurrentStimulus];
    
    response     = zeros(ceil(nPracTrials + nTrialsPerBlock),1); rushtime = response;
    rt           = ones(ceil(nPracTrials + nTrialsPerBlock),1);
    categoryFlag = ones(ceil(nPracTrials + nTrialsPerBlock),1);
    correctFlag  = ones(ceil(nPracTrials + nTrialsPerBlock),1);
    
    priorityLevel = MaxPriority(screenparms.window,'WaitBlanking');
    
    % Start experiment
    trialcnt = 1;
    for i = 1:(nPracTrials + nTrialsPerBlock)
        showtext(screenparms, stimsize/3, '+', 0, xup, xleft); 
        if ptb3; Screen('Flip', screenparms.window); end;
        
        % Play tone after toneOnset duration
        WaitSecs(fixationDuration);

        % Present stimulus
        Priority(priorityLevel);
        WaitSecs(.1);
        if ptb3
            if ismember(condition, [1 2 5 6]);
                Screen('DrawTexture', screenparms.window, stimTexture{currentStimulus(i,1)});
            else
                Screen('DrawTexture', screenparms.window, stimTexture{currentStimulus(i,1)}, [], [], 180);
            end
        end
        
        % Present instructions
        showtext(screenparms, stimsize/9, 'Which category does this face belong to?', 0, 250, -70);
        showtext(screenparms, stimsize/6, 'A', 0, 300, -screenparms.rect(4)/4);
        showtext(screenparms, stimsize/8, '(Press LEFT)', 0, 350, -screenparms.rect(4)/4);
        showtext(screenparms, stimsize/6, 'B', 0, 300, screenparms.rect(4)/4);
        showtext(screenparms, stimsize/8, '(Press RIGHT)', 0, 350, screenparms.rect(4)/4);
        
        RTBox('clear'); % clear buffer and sync clocks before stimulus onset
        if ptb3; vbl = Screen('Flip', screenparms.window); end;
        
        % Record response
        [cpuTime, buttonPress] = RTBox(timeout);  % computer time of button response
        FillScreen(screenparms); if ptb3; Screen('Flip', screenparms.window); end
        
        if ~isempty(cpuTime)
            rt(i, 1) = (cpuTime - vbl) * 1000;
        else
            rt(i, 1) = nan;
        end
        
        
        if ismember(buttonPress, {'1', '2'})
            response(i, 1) = 1;
        elseif ismember(buttonPress, {'3', '4'})
            response(i, 1) = 2;
        else
            response(i, 1) = nan;
        end
        
        % Display feedback
        if feedbackprobs(currentStimulus(i,1), 1);
            categoryFlag(i,1) = 1; % category is A
        else
            categoryFlag(i,1) = 2; % category is B
        end
        
        if response(i,1) == categoryFlag(i,1) && rt(i,1) < 5000 % their respones is correct
            correctFlag(i,1) = 1;
            FillScreen(screenparms); if ptb3; Screen('Flip', screenparms.window); end
            WaitSecs(iti);
        elseif response(i,1) ~= categoryFlag(i,1) && rt(i,1) < 5000 % their response is incorrect
            correctFlag(i,1) = 0;
            showtext(screenparms, stimsize/3, feedback{1}, 0, 0, 0);
            if ptb3; Screen('Flip', screenparms.window); end
            WaitSecs(fbkDuration);
            FillScreen(screenparms); if ptb3; Screen('Flip', screenparms.window); end
            WaitSecs(iti);
        else
            correctFlag(i,1) = 9;
            showtext(screenparms, stimsize/3, 'Too Slow!', 0, 0, 0);
            if ptb3; Screen('Flip', screenparms.window); end
            WaitSecs(fbkDuration);
            FillScreen(screenparms); if ptb3; Screen('Flip', screenparms.window); end
            WaitSecs(iti);
        end
        Priority(0);
        
        %% Insert a short break at 1/4, 1/2, and 3/4 trials
        if ismember(trialcnt, nPracTrials)
            showtext(screenparms, 20, 'Press any button to start experimental trials', 0, 0, 0);
            if ptb3;  Screen('Flip', screenparms.window); end;
            
            RTBox('clear'); % clear buffer and sync clocks before stimulus onset
            while ~any(RTBox('ButtonDown')); WaitSecs(0.01); end % Wait for any button press
            
            if ptb3; Screen('Flip', screenparms.window); end
        elseif ismember(trialcnt, nTrialsPerBlock)
            showtext(screenparms, 20, 'Take a short break. Press any button to continue', 0, 0, 0);
            
            % Compute accuracy on current block
            if bblocks == 1
                blkcorrect = correctFlag(10:end,1);
            else
                blkcorrect = correctFlag;
            end
            nblk = numel(blkcorrect);
            blkcorrect(isnan(blkcorrect),:) = [];
            blkcorrect(blkcorrect == 9,:) = []; 
            blkpercent = 100 * sum(blkcorrect)/nblk;
            showtext(screenparms, 20, sprintf('Accuracy = %4.2f percent correct in last block', blkpercent), 0, 100, 0);
            
            if ptb3;  Screen('Flip', screenparms.window); end;
            
            RTBox('clear'); % clear buffer and sync clocks before stimulus onset
            while ~any(RTBox('ButtonDown')); WaitSecs(0.01); end % Wait for any button press
            
            if ptb3; Screen('Flip', screenparms.window); end
        end
        trialcnt = trialcnt + 1;
    end
        overallcorrect = [overallcorrect; blkcorrect];
    stimDims = stimuli(currentStimulus,:);
    
    % Flip A's and B's - I have to do this because I've reveresed the categories in the instructions and in feedbackprobs. This will make the output commensurate with the existing analysis programs
    categoryFlag(categoryFlag == 1) = 3; categoryFlag = categoryFlag - 1;
    response(response == 1) = 3; response = response - 1;
    
    output = [output; currentStimulus stimuli(currentStimulus,1) stimuli(currentStimulus,2) response categoryFlag correctFlag rt]; 
    
    if bblocks == nBlocks
        showtext(screenparms, 20, 'Preparing Output', 0, 0, 0);
        if ptb3; Screen('Flip', screenparms.window); end
    end
    
    %% Save data
    finaloutput = [repmat(subject, trialcnt-1,1), repmat(condition, trialcnt-1, 1), repmat(rotation, trialcnt-1, 1),  repmat(session, trialcnt-1,1), (1:trialcnt-1)', output];
    dlmwrite(outputfile, finaloutput, '-append');
end
showInstructions(screenparms, endImage, 'RTBox');
closeexp(screenparms) %% Close experiment

%% Check for bonus

overallAcc = sum(overallcorrect)./numel(overallcorrect);
fprintf('Overall Accuracy = %4.2f\n', overallAcc)