%Written by Stephan Lewandowsky to set up experiment using Psychophysics
%toolbox
function screenparms = prepexp(varargin)
global ptb3

warning off MATLAB:DeprecatedLogicalAPI

if ptb3
    scns = Screen('Screens');
    if nargin > 0
        screencolor = varargin{1};
        [screenparms.window, screenparms.rect] = Screen('OpenWindow', max(scns)-1, screencolor);
        screenparms.screen = screencolor;
    else
        [screenparms.window, screenparms.rect] = Screen('OpenWindow', max(scns)-1);
    end
    ListenChar(2)


else
    if nargin > 0  % If specified, open window with user specified color
        screencolor = varargin{1};
        screenparms.window = Screen(0,'OpenWindow',screencolor); % Open window
        screenparms.screen = screencolor;
        screenparms.rect   = Screen(screenparms.window,'Rect');
    else % Otherwise, open default white screen
        screenparms.window = Screen(0,'OpenWindow');
        screenparms.rect   = Screen(screenparms.window,'Rect');
    end
end

ShowCursor(0);	% arrow cursor
HideCursor;
screenparms.white=WhiteIndex(screenparms.window);
screenparms.black=BlackIndex(screenparms.window);

% Choose fonts likely to be installed on this platform
switch computer
    case 'MAC2',
        screenparms.serifFont = 'Bookman';
        screenparms.sansSerifFont = 'Arial'; % or Helvetica
        screenparms.symbolFont = 'Symbol';
        screenparms.displayFont = 'Impact';
    case 'PCWIN'
        screenparms.serifFont = 'Bookman Old Style';
        screenparms.sansSerifFont = 'Arial';
        screenparms.symbolFont = 'Symbol';
        screenparms.displayFont = 'Impact';
    otherwise
        error(['Unsupported OS: ' computer]);
end