function showInstructions(screenparms, instructionFile, advance, waittime)
global ptb3

if nargin == 2
    advance = 'space';
end

imageInfo = imfinfo(instructionFile);
instructionImage = imread(instructionFile, imageInfo.Format);
if size(instructionImage, 3) == 1
    instructionImage = ind2rgb(imread(instructionFile, imageInfo.Format), imageInfo.Colormap) * 255;
end


[imageRect,dh,dv] = CenterRect([0 0 imageInfo.Width imageInfo.Height], screenparms.rect);
if ptb3
    instructionTexture = Screen('MakeTexture', screenparms.window, instructionImage);
    Screen('DrawTexture', screenparms.window, instructionTexture, [], imageRect);
    Screen('Flip', screenparms.window);
else
    Screen(screenparms.window, 'PutImage',  instructionImage, imageRect);
end

switch advance
    case 'space'
        try
            pressSpace; if ptb3; Screen('Flip', screenparms.window); end
        catch
            pause; FillScreen(screenparms);  if ptb3; Screen('Flip', screenparms.window); end
        end
    case 'time'
        if nargin == 3
            waittime = 1;
        end
        WaitSecs(waittime)
end