function FillScreen(screenparms)
global ptb3
if ptb3; Screen('FillRect', screenparms.window, screenparms.screen); else Screen('FillRect', screenparms.screen); end