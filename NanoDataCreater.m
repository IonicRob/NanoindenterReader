%% Nanoindentation Data Creater
% Written by Robert J Scales

function NanoDataCreater(debugON,PlotAesthetics,DefaultDlg,USS,ImageFormatType)
%% Set-up
clc;

% This is the title for notifications.
dlg_title = 'NanoindentationDataCreater';
fprintf('%s: Started!\n\n',dlg_title);

% The below gives the option to clear white list the clearing of certain
% variables and/or clear all preferences.
NanoCreaterLoaderClearer(false,false);

% This saves the initial directory, i.e. where the script is stored
% in.
LOC_init = cd;

prompt = 'Type in the number of samples to load';
NumberOfSamples = str2double(inputdlg(prompt,dlg_title));

% This prepares a string array to be filled in with the full filenames
% and the name the user wished to label the data with.
fileNameList = strings(NumberOfSamples,2);

%% Settings

if NumberOfSamples>1
    Message = {'Do you want to take the mean over all of the indents in all of the selected files?';'"Yes" only works with Agilent data!'};
    MeanSamples = questdlg(Message,dlg_title,'Yes','No',DefaultDlg.MeanSamples);
else
    MeanSamples = 'No';
end

% SettingsViaDialogueYN = questdlg('Choose how to apply settings?','Settings','Dialogue Boxes','Use Scipt Settings','Dialogue Boxes');
quest = {'Choose the settings choice mode:'};
% This next bit checks to see if 'SettingsDone' exists, if not then the
% code hasn't been run before and so not previous settings exist.
if logical(exist('SettingsDone','var'))
    pbnts = {'Dialogue Boxes','Use Scipt Settings','Use Previously Used Settings'};
else
    pbnts = {'Dialogue Boxes','Use Scipt Settings'};
end

[SettingsViaDialogueYN,~] = uigetpref('Settings','Dialogue',dlg_title,quest,pbnts);
switch SettingsViaDialogueYN
    case 'dialogue boxes'
        [bins,FormatAnswer,StdDevWeightingMode,ErrorPlotMode] = FormattingChoosing(DefaultDlg);
        % This creates 'SettingsDone' i.e. settings have been chosen.
        SettingsDone = true; % This is used!
    case 'use scipt settings'
        bins = USS.bins;
        FormatAnswer = USS.FormatAnswer;
        StdDevWeightingMode = USS.StdDevWeightingMode;
        ErrorPlotMode = USS.ErrorPlotMode;
        SettingsDone = true; % This is used!
    case 'Use Previously Used Settings'
        disp('Using previously used settings!');
end

w = wGenerator(StdDevWeightingMode);

if debugON
    fprintf('bins = %s\n',string(bins));
    fprintf('FormatAnswer = %s\n',string(FormatAnswer));
    fprintf('StdDevWeightingMode = %s\n',string(StdDevWeightingMode));
    fprintf('ErrorPlotMode = %s\n',string(ErrorPlotMode));
    fprintf('SettingsDone = %s\n',string(SettingsDone));
end


%% Main Data Processing Section

switch MeanSamples
    case 'No'
        disp('NOT meaning samples!');
        % The prepares arrays for the data to be filled in with.
        ValueData = zeros(bins,6,NumberOfSamples);
        ErrorData = zeros(bins,6,NumberOfSamples);
%         BinPopulations = zeros(bins,NumberOfSamples);

        for i=1:NumberOfSamples
            [FunctionOutPut,IDName,filename] = NanoMachineImport(bins,StdDevWeightingMode,debugON);
            [ValueData,ErrorData] = NonMeanDataGenerator(i,ValueData,ErrorData,FunctionOutPut,ErrorPlotMode);
            fileNameList(i,:) = [IDName,filename];
        end
        SampleNameList = fileNameList(:,1);
    case 'Yes'
        disp('Meaning samples for Agilent data!');
        [ValueData,ErrorData,fileNameList] = AgilentMeanDataGenerator(bins,NumberOfSamples,fileNameList,w,ErrorPlotMode,StdDevWeightingMode,debugON);
        message = 'Type in the name of the meaned data (e.g. the material name):';
        SampleNameList = string(inputdlg(message,dlg_title,[1,50]));
end


%% Plotting
cd(LOC_init);

close all

DataIDName = 'PlaceHolder-DataIDName';
FileStuctures{1} = struct('ValueData',ValueData,'ErrorData',ErrorData,'SampleNameList',SampleNameList,'DataIDName',DataIDName);

% Below here it works in a similar way to NanoData Loader
figure('Name','LFigure','windowstate','maximized');
figure('Name','tFigure','windowstate','maximized');
figure('Name','HCSFigure','windowstate','maximized');
figure('Name','EFigure','windowstate','maximized');
figure('Name','HFigure','windowstate','maximized');

DataTypeList = {'Load (mN)','Time (s)','Harmonic Contact Stiffness (N/m)','Hardness (GPa)','Youngs Modulus (GPa)'};
PlotDataTypes = ChooseDataToPlot(DataTypeList);

figHandles = findobj('Type', 'figure');

PlottingInfo.DataTypeList = DataTypeList;
PlottingInfo.PlotDataTypes = PlotDataTypes;
PlottingInfo.X_Axis_Label = 'Indent Depth (nm)';
PlottingInfo.legendLocation = 'southeast';

cd(LOC_init);
NanoPlotter(FileStuctures,PlotAesthetics,FormatAnswer,figHandles,PlottingInfo);


%% Saving Results

LoadingMode = false;
cd(LOC_init);
[DataIDName,SaveTime,SavingData,LOC_save] = NanoDataSave(ImageFormatType,LoadingMode,LOC_init,dlg_title,fileNameList);    

dataToSave = FileStuctures{1};
dataToSave.DataIDName = DataIDName;
% dataToSave = struct('ValueData',ValueData,'ErrorData',ErrorData,'SampleNameList',SampleNameList,'DataIDName',DataIDName);

disp('Saving the processed nanoindentation data');
DataSaveName = sprintf('%s_%s_Data.mat',DataIDName,SaveTime);
cd(LOC_save);
switch SavingData
    case 'auto'
        save(DataSaveName,'dataToSave','-mat');
        fprintf('Auto-saved "%s" as "%s"\n',DataIDName,DataSaveName);
    case 'semi-auto'
        uisave('dataToSave',DataSaveName);
        fprintf('Semi-auto-saved "%s" as "%s"\n',DataIDName,DataSaveName);
    case 'manual'
        disp('You have to manually save the data');
    otherwise
        errordlg('Variable "SavingData" was not suitable!')
        fprintf('SavingData = "%s"\n\n',SavingData);
        cd(LOC_init);
        return
end

cd(LOC_init);
fprintf('NanoDataCreater: Complete!\n\n');
end
%%










    
%% Functions

function w = wGenerator(StdDevWeightingMode)

    switch StdDevWeightingMode
        case 'N-1'
            w = 0;
        case 'N'
            w = 1;
        case 'Using bin errors'
            w = 0; % Need to update this!!
        case ''
            w = 0;
    end
    
end

function [bins,FormatAnswer,StdDevWeightingMode,ErrorPlotMode] = FormattingChoosing(DefaultDlg)
    dlg_title = 'Nanoindentation Data Creater';
    % This is the number of bins which it will group the data along the
    % x-axis with.
    bins = str2double(inputdlg({'How many bins do you want to use'},dlg_title,[1,50]));

    % This is how the data will be shown on the graph.
%     quest = {'Choose how to plot the data:'};
%     pbnts = {'Line + Error Region','Line + Error Bars','Line'};
%     [FormatAnswer,~] = uigetpref('Settings','PlotFormat',dlg_title,quest,pbnts,'DefaultButton','Line + Error Region');
    FormatAnswer = questdlg('How do you want to present the data?',dlg_title,'Line + Error Region','Line + Error Bars','Line',DefaultDlg.FormatAnswer);

    switch FormatAnswer
        case 'Line'
            disp('No error bars will be shown on the graph');
            StdDevWeightingMode = 'N-1';
        case ''
            errordlg('Exit button was pressed! Code will terminate!')
            return
        otherwise
            % This is the weighting mode to do for the standard deviation
            % and standard error, see Matlab documentation on std.
%             quest = {'Choose the error to show on the graph:'};
%             pbnts = {'Standard deviation','Standard error'};
%             [ErrorPlotMode,~] = uigetpref('Settings','Error',dlg_title,quest,pbnts,'DefaultButton','Standard deviation');
            ErrorPlotMode = questdlg('Choose to show standard error or standard deviation:',dlg_title,'Standard error','Standard deviation',DefaultDlg.ErrorPlotMode);
            
            % This chooses whether the standard deviation or standard error
            % will be plotted as the y-uncertainties in the graphs.
%             quest = {'Choose the standard deviation weighting to use:'};
%             pbnts = {'N-1','N','Using bin errors'};
%             [StdDevWeightingMode,~] = uigetpref('Settings','Weighting',dlg_title,quest,pbnts,'DefaultButton','N-1');
            StdDevWeightingMode = questdlg('Choose the standard deviation weighting to use:',dlg_title,'N-1','N','Using bin errors',DefaultDlg.StdDevWeightingMode);
            
            if strcmp(ErrorPlotMode,'') == true
                warndlg('No error choice was made, hence default will be shown!');
            end
            if strcmp(StdDevWeightingMode,'') == true
                warndlg('No weighting choice was made, hence default will be chosen!');
            end
    end
end

function [ValueData,ErrorData] = NonMeanDataGenerator(i,ValueData,ErrorData,FunctionOutPut,ErrorPlotMode)
    ValueData(:,:,i) = FunctionOutPut.FinalArray;
%     BinPopulations(:,i) = FunctionOutPut.BinsPop;
    switch ErrorPlotMode
        case 'Standard error'
            ErrorData(:,:,i) = FunctionOutPut.FinalErrors;
        case 'Standard deviation'
            ErrorData(:,:,i) = FunctionOutPut.FinalStdDev;
        case ''
            ErrorData(:,:,i) = FunctionOutPut.FinalErrors;
    end
end

function [ValueData,ErrorData,fileNameList] = AgilentMeanDataGenerator(bins,NumberOfSamples,fileNameList,w,ErrorPlotMode,StdDevWeightingMode,debugON)
    % The prepares arrays for the data to be filled in with.
    PreValueData = zeros(bins,5,1);
    IndentDepthLimits = nan(NumberOfSamples,1);

    for i=1:NumberOfSamples
        [FunctionOutPut,IDName,filename] = NanoMachineImport(bins,StdDevWeightingMode,debugON);
        IndentDepthLimits(i) = FunctionOutPut.DepthLimit;
        PreValueData = cat(3,PreValueData,FunctionOutPut.IndentsArray);
        fileNameList(i,:) = [IDName,filename];
    end
    % Removes the first layer of zeros
    PreValueData(:,:,1) = [];
    NumOfIndents = size(PreValueData,3);

    if all(IndentDepthLimits(:) == IndentDepthLimits(1))
        ValueData = horzcat(FunctionOutPut.BinMidpoints,mean(PreValueData,3,'omitnan'));
        % This calculates the standard error using the above weighting choice.
        ErrorData_StdDev = std(PreValueData,w,3,'omitnan');
        % This is the standard error.
        ErrorData_StdError = ErrorData_StdDev/realsqrt(NumOfIndents);
        if strcmp(ErrorPlotMode,'Standard error') == true
            ErrorData = horzcat(FunctionOutPut.BinMidpoints,ErrorData_StdError);
        elseif strcmp(ErrorPlotMode,'Standard deviation') == true
            ErrorData = horzcat(FunctionOutPut.BinMidpoints,ErrorData_StdDev);
        end
    else
        errordlg('Indent termination depths are not the same!')
        ValueData = nan;
        ErrorData = nan;
        fileNameList = nan;
        return
    end

end


function PlotDataTypes = ChooseDataToPlot(DataTypeList)
    PromptString = {'Select what data to plot against depth:','Multiple can be selected at once.'};
    [PlotDataTypes,~] = listdlg('PromptString',PromptString,'SelectionMode','multiple','ListString',DataTypeList);
end



