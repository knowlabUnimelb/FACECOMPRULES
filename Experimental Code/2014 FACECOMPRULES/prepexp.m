%Written by Stephan Lewandowsky to set up experiment using Psychophysics
%toolbox
function screenparms = prepexp(varargin)

warning off MATLAB:DeprecatedLogicalAPI
warning off MATLAB:mex:deprecatedExtension



scns = Screen('Screens');
if nargin > 0
    screencolor = varargin{1};
    [screenparms.window, screenparms.rect] = Screen('OpenWindow', 0, screencolor, [0 0 1280 1024]);
    screenparms.screen = screencolor;
else
    [screenparms.window, screenparms.rect] = Screen('OpenWindow', 0, screencolor, [0 0 1280 1024]);
end
ListenChar(2)


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
    case 'PCWIN64'
        screenparms.serifFont = 'Bookman Old Style';
        screenparms.sansSerifFont = 'Arial';
        screenparms.symbolFont = 'Symbol';
        screenparms.displayFont = 'Impact';
    case 'GLNXA64'
        screenparms.serifFont = 'Bookman Old Style';
        screenparms.sansSerifFont = 'Arial';
        screenparms.symbolFont = 'Symbol';
        screenparms.displayFont = 'Impact';
    otherwise
        error(['Unsupported OS: ' computer]);
end