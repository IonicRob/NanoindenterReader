%% Nanoindentation Matlab Code
% By Robert J Scales


%% Clean Slate
%Clear the command window
clc
close all
% clearvars('-except','ImageFormatType');

%% NanoMainCode Settings
% To change pre-defined settings in the code change the values within this
% function. There are options to change certain settings within the latter
% scripts that run.
[PlotAesthetics,debugON,DefaultDlg,USS] = SettingsFunction;

code_title = 'Nanoindentation Main Code';

if logical(exist('ImageFormatType','var')) == false
    ImageFormatType = ImageSaveType;
else
    pbnts = {'Yes','No'};
    quest = sprintf('Change image saving filetype from ".%s"?:',ImageFormatType);
    [ImageSavingRepYN,~] = uigetpref('Settings','ImageSaving',code_title,quest,pbnts,'DefaultButton','No');
    if strcmp(ImageSavingRepYN,'yes')
        ImageFormatType = ImageSaveType;
    elseif strcmp(ImageSavingRepYN,'no')
         fprintf('"ImageFormatType" from before of "%s" will be used\n',ImageFormatType);
    end
end

%% Main Section

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
    set(0,'defaultAxesFontSize',20); % This sets the font size for all text in all of the figures!
    set(0,'defaultLineMarkerSize',12); % This sets the marker size for all text in all of the figures!

    debugON = true;
    
    % The below are non-crucial settings which have been decided to not be
    % editable via dialogue boxes when running the script.
    PlotAesthetics.capsize = 0;
    PlotAesthetics.linewidth = 2;
    PlotAesthetics.facealpha = 0.25;

    % Default Dialogue Box Choices - You can change this if you want to speed
    % things up when choosing in the dialogue boxes.
    DefaultDlg.FormatAnswer = 'Line + Error Region';
    DefaultDlg.StdDevWeightingMode = 'N-1';
    DefaultDlg.ErrorPlotMode = 'Standard deviation';
    DefaultDlg.MeanSamples = 'No';

    % Script Settings - These are selected if you select 'Use Scipt Settings'!
    %       See the FormattingChoosing function for more details.
    USS.bins = 100;
    USS.FormatAnswer = 'Line + Error Region';
    USS.StdDevWeightingMode = 'N-1';
    USS.ErrorPlotMode = 'Standard deviation';
end

function ImageFormatType = ImageSaveType
    PromptString = {'Select image filetype for figures to save as:','Only one type can be selected at a time.'};
    imageTypeList = {'fig','m','tiffn','tiff','jpeg','png','pdf','svg','eps'};
    [ImageFormatType,~] = listdlg('PromptString',PromptString,'SelectionMode','single','ListString',imageTypeList);
    ImageFormatType = imageTypeList{ImageFormatType};
end