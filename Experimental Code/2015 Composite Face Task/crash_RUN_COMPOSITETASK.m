% 2015 REP Composite Task - Faces
%% 
clear all
clc

WaitSecs(1e-7); % Hack to load WaitSecs
warning('off', 'MATLAB:mex:deprecatedExtension')

debug = false; % If debug == true, do experiment with reduced number of trials

%% Environment Variables
bgcolor = [0 0 0]; % User specified background color
txtColor = [255 255 255];
stimsize = 187;
feedback = {'...Wrong...', '...Correct...'};
textsize = 60;
fixsize = 50;
lineWidth = 5;
timeout = 5;

%% Experimental Variables
seed = 43958;
fixationDuration = 1; %.5;  % Fixation cross presentation length (1.5 secs)
studyPresTime    = .2; %1.5;
fbkDuration      = 2;     % Feedback presentation length
iti              = 2;  % Intertrial interval

%% Enter block to start from
startfromBlock = 2
%startfromTrial = 1

switch debug % Reduce the number of trials for debugging
    case true
  %      RTBox('fake',1);
        nPracTrials = 0;                     % Number of practice trials = 38 (25 Stimuli * 1)
        nSetTrials  = 256;                    % Number of experimental trials = 4 Stimuli x  2 Cued (Top/Bottom) x 2 Resp (Same/Diff) x 2 Congruent/Incongruent x 2 Upright/Inverted x 2 Aligned/Misaligned x 2 FaceSets
        nBlocks = 2;                          % Number of blocks = 3
        nRepsPerBlock = 1;                    % N Reps per block
        nTrialsPerBlock = 2; % Number of trials per block = 48
        nExpTrials = nBlocks * nTrialsPerBlock;
    case false
        nPracTrials = 16;                     % Number of practice trials = 38 (25 Stimuli * 1)
        nSetTrials  = 256;                    % Number of experimental trials = 4 Stimuli x  2 Cued (Top/Bottom) x 2 Resp (Same/Diff) x 2 Congruent/Incongruent x 2 Upright/Inverted x 2 Aligned/Misaligned x 2 FaceSets
        nBlocks = 16;                         % Number of blocks = 16 (Cued part is blocked)
        nRepsPerBlock = 2;                    % N Reps per block
        nTrialsPerBlock = nRepsPerBlock * nSetTrials/nBlocks; % Number of trials per block = 48
        nExpTrials = nBlocks * nTrialsPerBlock;
end

%% Open Experiment Window
% Present subject information screen until correct information is entered
subject     = input('Enter Subject Number [101-199]:');
screenparms = prepexp(0, bgcolor, []); % Open onscreen window

rng(seed + subject * 2, 'twister') % Seed random number generator
outputfile = sprintf('crash_2015_comptask_s%03d.dat', subject);
csvoutputfile = sprintf('crash_2015_comptask_s%03d.csv', subject);
dataFolder = fullfile(pwd, 'Data');

%if data not recording propertly, consider looking at
%datafile = ['s' num2str(subject) '_' datafile];
%trialdatafile = ['temp_' datafile]

%% Face Stimulus Set
imageFolder = fullfile(pwd, 'Stimulus Images');
imageFiles  = dir(fullfile(imageFolder, '*.bmp'));
[~,~,trialSets]   = xlsread('Trial Types.xlsx');
labels = trialSets(1,:);
trialSets(1,:) = [];

nt = size(trialSets(indexCellWithMat(trialSets(:,1), 1), :), 1);
oldBlockList = trialSets(:,1);
for i = 1:numel(unique([trialSets{:,1}]))
   if mod(i,2) == 1 % odd: Bottom
       tempList = repmat((1:2:nt)', 2, 1);
       tempList = tempList(randperm(nt));
       trialSets(indexCellWithMat(oldBlockList(:,1), i), 1) = mat2cell(tempList, ones(nt,1),1);
   else % even: Top
       tempList = repmat((2:2:nt)', 2, 1);
       tempList = tempList(randperm(nt));
       trialSets(indexCellWithMat(oldBlockList(:,1), i), 1) = mat2cell(tempList, ones(nt,1),1);      
   end
end

%% LOAD STIMULI INTO TEXTURES
ProgBar = DrawProgressBar(screenparms, size(imageFiles,1), 'Generating Stimuli', txtColor); 
Screen('Flip', screenparms.window);

stimTexture = cell(size(imageFiles,1),1); % Initialize cell matrix for textures
for i = 1:size(imageFiles,1)
    stimNames{i,1} = imageFiles(i).name;
    stimImage = imread(fullfile(imageFolder, stimNames{i,1})); % Read image information    
    stimTexture{i} = Screen('MakeTexture', screenparms.window, stimImage); % Save to texture
    ProgBar(i); 
    Screen('Flip', screenparms.window); % Update the progress bar
end
fixcrossH = CenterRect([0 0 fixsize 1], screenparms.rect);
fixcrossV = CenterRect([0 0 1 fixsize], screenparms.rect);

%% PRESENT INSTRUCTIONS
instructionFolder = 'Instructions';
trainingInstructions = {'CompositeFaceInstructions.bmp'};
showInstructions(screenparms, fullfile(pwd, instructionFolder, trainingInstructions{1}), 'RTBox')
% showInstructions(screenparms, fullfile(pwd, instructionFolder, trainingInstructions{2}), 'RTBox')
endImage = (fullfile(pwd, instructionFolder, 'Thanks.bmp'));

%% Run Experiment
blockNumbers = unique(cell2mat(trialSets(:,1)));
blockOrder   = randperm(numel(blockNumbers));
outputCell = [];
blockcnt = startfromBlock
for bidx = blockcnt:nBlocks
    blockSet = trialSets(indexCellWithMat(trialSets(:,1), blockOrder(bidx)), :);
    blockSet = repmat(blockSet, nRepsPerBlock, 1);
    blockSetOrder = randperm(size(blockSet,1));
    expBlockSet = blockSet(blockSetOrder, :);
    expBlockSet = expBlockSet(1:nTrialsPerBlock, :);
    
    response     = nan(nTrialsPerBlock,1); 
    rt           = nan(nTrialsPerBlock,1);
    sameFlag     = nan(nTrialsPerBlock,1); 
    correctFlag  = nan(nTrialsPerBlock,1);
    
    priorityLevel = MaxPriority(screenparms.window,'WaitBlanking');
    
    % Present block instructions
    showtext(screenparms, 20, sprintf('For this block, you should attend to the %s half of the face', expBlockSet{1,strcmp(labels, 'Cued')}), 0, 0, 0);
    showtext(screenparms, 20, 'Press any button to begin this block', 0, 100, 0);
    Screen('Flip', screenparms.window);
    RTBox('clear'); % clear buffer and sync clocks before stimulus onset
    while ~any(RTBox('ButtonDown')); WaitSecs(0.01); end % Wait for any button press
    Screen('Flip', screenparms.window);
            
    % Start experiment
    %trialcnt = startfromTrial;
    for i = 1:nTrialsPerBlock        
        studyTexture = stimTexture(strcmp(stimNames,...
            sprintf('Set%d_%s%s_%d.bmp',...
            expBlockSet{i, strcmp(labels, 'Set')},...
            'Upright',...
            'Aligned',...
            expBlockSet{i, strcmp(labels, 'Study')})));
        testTexture  = stimTexture(strcmp(stimNames,...
            sprintf('Set%d_%s%s_%d.bmp',...
            expBlockSet{i, strcmp(labels, 'Set')},...
            expBlockSet{i, strcmp(labels, 'Direction')},...
            expBlockSet{i, strcmp(labels, 'Alignment')},...
            expBlockSet{i, strcmp(labels, 'Test')})));
        
        Screen('DrawLine', screenparms.window, screenparms.white, fixcrossH(1), fixcrossH(2), fixcrossH(3), fixcrossH(4), lineWidth)
        Screen('DrawLine', screenparms.window, screenparms.white, fixcrossV(1), fixcrossV(2), fixcrossV(3), fixcrossV(4), lineWidth)
        Screen('Flip', screenparms.window); % Flip the fixation cross to the front buffer
        WaitSecs(fixationDuration); % Wait
       
        % Present study stimulus
        Priority(priorityLevel);
        WaitSecs(.1);
        
        Screen('DrawTexture', screenparms.window, studyTexture{1});
        Screen('Flip', screenparms.window); % Flip the fixation cross to the front buffer
        WaitSecs(studyPresTime);
        FillScreen(screenparms); 
        Screen('Flip', screenparms.window);
        WaitSecs(.2);
        
        Screen('DrawTexture', screenparms.window, testTexture{1});
        Screen('Flip', screenparms.window); % Flip the fixation cross to the front buffer
        WaitSecs(studyPresTime);
        FillScreen(screenparms); 
        Screen('Flip', screenparms.window);

        % Present instructions
        showtext(screenparms, stimsize/6, 'SAME', 0, 300, -screenparms.rect(4)/4);
        showtext(screenparms, stimsize/8, '(Press LEFT)', 0, 350, -screenparms.rect(4)/4);
        showtext(screenparms, stimsize/6, 'DIFFERENT', 0, 300, screenparms.rect(4)/4);
        showtext(screenparms, stimsize/8, '(Press RIGHT)', 0, 350, screenparms.rect(4)/4);
        
        RTBox('clear'); % clear buffer and sync clocks before stimulus onset
        vbl = Screen('Flip', screenparms.window);
        
        % Record response
        [cpuTime, buttonPress] = RTBox(timeout);  % computer time of button response
        if numel(buttonPress) > 1; 
            cpuTime = cpuTime(1); 
            buttonPress = buttonPress(1); 
        end
        
        
        FillScreen(screenparms); 
        Screen('Flip', screenparms.window);
        
        if ~isempty(cpuTime)
            rt(i, 1) = (cpuTime - vbl);
        else
            rt(i, 1) = nan;
        end
        
        if ismember(buttonPress, {'1', '2'})
            response(i, 1) = 1;
        elseif ismember(buttonPress, {'3', '4'})
            response(i, 1) = 2;
        end
        
        % Display feedback
        if strcmp(expBlockSet(i, strcmp(labels, 'Resp')), 'Same')
            sameFlag(i,1) = 1; % correct response is same
        else
            sameFlag(i,1) = 2; % correct respnse is diff
        end
        
        if response(i,1) == sameFlag(i,1) && rt(i,1) < 5000 % their respones is correct
            correctFlag(i,1) = 1;
            FillScreen(screenparms);
            Screen('Flip', screenparms.window);
            WaitSecs(iti);
        elseif response(i,1) ~= sameFlag(i,1) && rt(i,1) < 5000 % their response is incorrect
            correctFlag(i,1) = 0;
            showtext(screenparms, stimsize/3, feedback{1}, 0, 0, 0);
            Screen('Flip', screenparms.window);
            WaitSecs(fbkDuration);
            FillScreen(screenparms); 
            Screen('Flip', screenparms.window);
            WaitSecs(iti);
        else
            correctFlag(i,1) = nan;
            showtext(screenparms, stimsize/3, 'Too Slow!', 0, 0, 0);
            Screen('Flip', screenparms.window); 
            WaitSecs(fbkDuration);
            FillScreen(screenparms); 
            Screen('Flip', screenparms.window); 
            WaitSecs(iti);
        end
        Priority(0);
    end
    
    %% Reformat output to mat
    output = [repmat(subject, nTrialsPerBlock, 1),... % subject
              repmat(bidx, nTrialsPerBlock, 1),...    % block
              cell2mat(expBlockSet(:, strcmp(labels, 'Number'))),... % Block number
              cell2mat(expBlockSet(:, strcmp(labels, 'Set'))),...    % Face set
              strcmp(expBlockSet(:, strcmp(labels, 'Cued')), 'Top'),...   % Cued half
              strcmp(expBlockSet(:, strcmp(labels, 'Resp')), 'Same'),...   % Correct answer
              strcmp(expBlockSet(:, strcmp(labels, 'Congruent')), 'Congruent'),... % Congruent
              strcmp(expBlockSet(:, strcmp(labels, 'Direction')), 'Upright'),... % Direction
              strcmp(expBlockSet(:, strcmp(labels, 'Alignment')), 'Aligned'),... Alignment
              cell2mat(expBlockSet(:, strcmp(labels, 'Study'))),... % Study item
              cell2mat(expBlockSet(:, strcmp(labels, 'Test'))),...  % Test item
              correctFlag,...
              response,...
              rt];
    dlmwrite(fullfile(dataFolder, outputfile), output, '-append')       
    
    
    outputCell = [outputCell;...
        mat2cell(repmat(subject, nTrialsPerBlock, 1), ones(nTrialsPerBlock,1), 1),... 
        mat2cell(repmat(bidx, nTrialsPerBlock, 1), ones(nTrialsPerBlock,1), 1),...
        expBlockSet,...
        mat2cell(correctFlag, ones(nTrialsPerBlock,1), 1),... 
        mat2cell(response, ones(nTrialsPerBlock,1), 1),... 
        mat2cell(rt, ones(nTrialsPerBlock,1), 1)];
    
    
    if bidx == nBlocks
        showtext(screenparms, 20, 'Preparing Output', 0, 0, 0);
        Screen('Flip', screenparms.window); 
    end
    
end
cell2csv(fullfile(dataFolder, csvoutputfile), outputCell)
showInstructions(screenparms, endImage, 'RTBox');
closeexp(screenparms) %% Close experiment