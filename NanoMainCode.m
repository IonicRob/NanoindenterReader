%% Nanoindentation Matlab Code
% By Robert J Scales


%% Clean Slate Section
% Clears the command window
clc

% Closes all figures
close all

% Clears variables except for those listed. This will be done every time
% you restart Matlab anyway so don't worry.
%   clearvars('-except','ImageFormatType');

% The below clears all of the 'Do Not Show This Again' for
% preference diaglogue boxes.
%   uisetpref('clearall');

%% NanoMainCode Settings

% To change pre-defined settings in the code change the values within this
% function. There are options to change certain settings within the latter
% scripts that run.
[PlotAesthetics,debugON,DefaultDlg,USS] = SettingsFunction;

% This titles all of the dialogue boxes ran in this code.
code_title = 'Nanoindentation Main Code';

% This function sets the figure image saving file type.
ImageFormatType = changeFigureSaveType;

%% Main Section

% The code either generates data for samples(s), which is the "Create"
% action, or it grabs the outputted ".mat" files from "Create" which can
% contain either one sample, multiple samples, or the mean across multiple
% samples (using the mean option for Agilent files).
CreateOrLoad = questdlg('What action do you want to do?',code_title,'Create','Load','Create');

switch CreateOrLoad
    case 'Create'
        NanoDataCreater(debugON,PlotAesthetics,DefaultDlg,USS,ImageFormatType)
    case 'Load'
        NanoDataLoader(debugON,PlotAesthetics,DefaultDlg,ImageFormatType)
    case ''
        errordlg('No action was chosen! Code will terminate!')
        return
end


%% Functions

function [PlotAesthetics,debugON,DefaultDlg,USS] = SettingsFunction
    % This sets the font size for all text in all of the figures!
    set(0,'defaultAxesFontSize',20);
    % This sets the marker size for all text in all of the figures!
    set(0,'defaultLineMarkerSize',12);

    % Setting this to true allows debugging messages to pop up within
    % following code that is run. It is useful to turn on to see what the
    % code is doing.
    debugON = true;
    
    % The below are non-crucial settings which have been decided to not be
    % editable via dialogue boxes when running the script.
    PlotAesthetics.capsize = 0;
    PlotAesthetics.linewidth = 2;
    PlotAesthetics.facealpha = 0.25;

    % The default settings used by John Waite's (ex Oxford DPhil) Matlab
    % code were:
    % FormatAnswer = 'Line + Error Bars';
    % StdDevWeightingMode = 'N-1';
    % ErrorPlotMode = Standard deviation';
    % These have mainly been used, however the 'Line + Error Region' option
    % looks better aesthetically.
    
    % Default Dialogue Box Choices - You can change this if you want to speed
    % things up when choosing in the dialogue boxes. The meaning of these
    % are explained when looking at NanoDataCreater.
    DefaultDlg.FormatAnswer = 'Line + Error Region';
    DefaultDlg.StdDevWeightingMode = 'N-1';
    DefaultDlg.ErrorPlotMode = 'Standard deviation';
    DefaultDlg.MeanSamples = 'No';

    % Script Settings - These are selected if you select 'Use Scipt Settings'!
    % See NanoDataCreater for more explanation on what these mean.
    USS.bins = 100;
    USS.FormatAnswer = 'Line + Error Region';
    USS.StdDevWeightingMode = 'N-1';
    USS.ErrorPlotMode = 'Standard deviation';
end


% The below helps keep track whether the user wants to change what the code
% saves the figures as in terms of file type.
function ImageFormatType = changeFigureSaveType
    % This sees if this variable already exists, which it should do if the
    % code has been ran before.
    if logical(exist('ImageFormatType','var')) == false
        % In the case where the format type variable does not exist, it
        % forces the user to choose one.
        ImageFormatType = ImageSaveType;
    else
        % The following occurs if a choice has been made before.
        % N.B. Ignore the below warning, this occurs when ImageFormatType
        % already exists.
        quest = sprintf('Change image saving filetype from ".%s"?:',ImageFormatType);
        
        % This is a user preference dialogue asking if they wish to change
        % what it saves the figures as.
        [ImageSavingRepYN,~] = uigetpref('Settings','ImageSaving',code_title,quest,{'Yes','No'},'DefaultButton','No');
        
        % If the user selects yes then it gives them the option to choose
        % what to save the figures as, otherwise it will use the
        % pre-existing variable value.
        if strcmp(ImageSavingRepYN,'yes')
            ImageFormatType = ImageSaveType;
        elseif strcmp(ImageSavingRepYN,'no')
             fprintf('"ImageFormatType" from before of "%s" will be used\n',ImageFormatType);
        end
    end
end

% This is used in changeFigureSaveType.
function ImageFormatType = ImageSaveType
    PromptString = {'Select image filetype for figures to save as:','Only one type can be selected at a time.'};
    imageTypeList = {'fig','m','tiffn','tiff','jpeg','png','pdf','svg','eps'};
    
    % List dialogue pop-up.
    [ImageFormatType,~] = listdlg('PromptString',PromptString,'SelectionMode','single','ListString',imageTypeList);
    
    % This changes ImageFormatType from being a number to the character
    % value in imageTypeList.
    ImageFormatType = imageTypeList{ImageFormatType};
end




