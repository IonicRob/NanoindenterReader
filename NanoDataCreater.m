%% Nanoindentation Data Creater
% Written by Robert J Scales

function NanoDataCreater(debugON,PlotAesthetics,DefaultDlg,USS,ImageFormatType)
%% Basic Set-up
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

%%%%%%%%%%%%%%%%%%%%%%%%%%% IMPORTANT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This tells the code how many samples you wish to load/create. E.g. for
% CSM Agilent to plot or mean the data of two arrays type in two; & for QS
% Bruker if you want to plot the data from seperate groups of indents, type
% in the number of groups, it will then mean all of the indents within each
% group but not between groups!!!
prompt = 'Type in the number of samples to load';
NumberOfSamples = str2double(inputdlg(prompt,dlg_title));

% This prepares a string array to be filled in with the full filenames
% and the name the user wished to label the data with.
fileNameList = strings(NumberOfSamples,2);

%% Settings

%%%%%%%%%%%%%%%%%%%%%%%%%%% IMPORTANT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This tells the code whether to mean between the groups of indents which
% it is told that exist. You should never choose yes if you are working
% with something that is not Agilent.
if NumberOfSamples>1
    % If you tell the code there are more than one sample to import, then
    % it will ask whether you want to mean across them all or keep them
    % seperate samples.
    Message = {'Take the mean across all Agilent sample data?';'Select "No" unless you are going to load just Agilent spreadsheets!'};
    MeanSamples = questdlg(Message,dlg_title,'Yes','No',DefaultDlg.MeanSamples);
else
    MeanSamples = 'No';
end

% This next bit checks to see if 'SettingsDone' exists, if not then the
% code hasn't been run before and so not previous settings exist.
quest = {'Choose the settings choice mode:'};
if logical(exist('SettingsDone','var'))
    pbnts = {'Dialogue Boxes','Use Scipt Settings','Use Previously Used Settings'};
else
    pbnts = {'Dialogue Boxes','Use Scipt Settings'};
end

% The following chooses between using the USS settings in NanoMainCode or
% whether you want to specify the settings via dialogue boxes.
[SettingsViaDialogueYN,~] = uigetpref('Settings','Dialogue',dlg_title,quest,pbnts);
switch SettingsViaDialogueYN
    case 'dialogue boxes'
        % The below function is used to make the main script shorter.
        [bins,FormatAnswer,StdDevWeightingMode,ErrorPlotMode] = FormattingChoosing(DefaultDlg);
        % This creates 'SettingsDone' i.e. settings have been chosen.
        SettingsDone = true;
    case 'use scipt settings'
        % To alter these alter the values in USS in NanoMainCode.
        bins = USS.bins;
        FormatAnswer = USS.FormatAnswer;
        StdDevWeightingMode = USS.StdDevWeightingMode;
        ErrorPlotMode = USS.ErrorPlotMode;
        SettingsDone = true;
    case 'Use Previously Used Settings'
        disp('Using previously used settings!');
end

% This is the standard deviation weighting mode.
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

        % The below cycles through by the number of samples you specified
        % in the "Basic Set-up" section of this code.
        for i=1:NumberOfSamples
             % Details of this function are written in its code. It
             % effectively obtains the data for the sample.
            [FunctionOutPut,IDName,filename] = NanoMachineImport(bins,StdDevWeightingMode,debugON);
            
            % This then extracts the data from the above function and
            % places it into the 3D arrays, where the 3rd dimension is for
            % each sample.
            [ValueData,ErrorData] = NonMeanDataGenerator(i,ValueData,ErrorData,FunctionOutPut,ErrorPlotMode);
            
            % This is used for building a list of the name and file
            % location for each sample.
            fileNameList(i,:) = [IDName,filename];
        end
        % The completed list is then used for both plotting and saving
        % purposes.
        SampleNameList = fileNameList(:,1);
    case 'Yes'
        disp('Meaning samples for Agilent data!');
        % The below process is more complicated than above, hence it has
        % been made as a function within this code for simplicity.
        [ValueData,ErrorData,fileNameList] = AgilentMeanDataGenerator(bins,NumberOfSamples,fileNameList,w,ErrorPlotMode,StdDevWeightingMode,debugON);
        % As all of the files have been merged into one meaned dataset,
        % there is only 1 samplename, hence the SampleNameList is changed
        % to be a user typed input.
        message = 'Type in the name of the meaned data (e.g. the material name):';
        SampleNameList = string(inputdlg(message,dlg_title,[1,50]));
end


%% Plotting

% The below lines of code are needed for the plotting function.
% DataIDName has been replaced by a placeholder value, as this variable is
% generated later on in NanoDataSave.
FileStuctures{1} = struct('ValueData',ValueData,'ErrorData',ErrorData,'SampleNameList',SampleNameList,'DataIDName','PlaceHolder-DataIDName');

% This function plots all of the figures that you want to plot based on the
% structure FileStuctures generated above to describe this session.
NanoPlotter(FileStuctures,PlotAesthetics,FormatAnswer);

%% Saving Results

% LoadingMode is set to false in order to execute code specific for this
% code in NanoDataSave.
LoadingMode = false;

cd(LOC_init);
% This function saves the figures efficiently.
DataIDName = nan; % This is just double checking that you will have to write the value for this in NanoDataSave.
[DataIDName,SaveTime,SavingData,LOC_save] = NanoDataSave(ImageFormatType,LoadingMode,LOC_init,fileNameList,DataIDName);    

% The below few lines generates a structure based on the one generated
% above but changes the DataIDName to that generated in NanoDataSave.
dataToSave = FileStuctures{1};
dataToSave.DataIDName = DataIDName;

% Depending on how the figures were saved, then the data produced by this
% function will be saved differently. This is what is loaded by
% NanoDataLoader to generate its plots.
disp('Saving the processed nanoindentation data');
DataSaveName = sprintf('%s_%s_Data.mat',DataIDName,SaveTime);
cd(LOC_save);
switch SavingData
    case 'auto'
        save(DataSaveName,'dataToSave','-mat');
        fprintf('Auto-saved "%s" as "%s"\n',DataIDName,DataSaveName);
    case 'semi-auto'
        % uisave brings up a dialogue box for saving the data, it allows
        % the option to change the name that the data is saved as.
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


% This allows the user to choose the settings via dialogue boxes.
function [bins,FormatAnswer,StdDevWeightingMode,ErrorPlotMode] = FormattingChoosing(DefaultDlg)
    dlg_title = 'Nanoindentation Data Creater';
    
    % This is the number of bins which it will group the data along the
    % x-axis with.
    bins = str2double(inputdlg({'How many bins do you want to use'},dlg_title,[1,50]));

    % This is how the data will be shown on the graph.
    FormatAnswer = questdlg('How do you want to present the data?',dlg_title,'Line + Error Region','Line + Error Bars','Line',DefaultDlg.FormatAnswer);

    switch FormatAnswer
        case ''
            % This occurs if no input is given by the user.
            errordlg('Exit button was pressed! Code will terminate!')
            return
        otherwise
            % This is chosen for all other inputs apart from if no input is
            % chosen, as the data could then be later analysed and it
            % would be useful to have these settings chosen.
            
            % This is the weighting mode to do for the standard deviation
            % and standard error, see Matlab documentation on std.
            ErrorPlotMode = questdlg('Choose to show standard error or standard deviation:',dlg_title,'Standard error','Standard deviation',DefaultDlg.ErrorPlotMode);
            
            % This chooses whether the standard deviation or standard error
            % will be plotted as the y-uncertainties in the graphs.
            StdDevWeightingMode = questdlg('Choose the standard deviation weighting to use:',dlg_title,'N-1','N','Using bin errors',DefaultDlg.StdDevWeightingMode);
            
            if strcmp(ErrorPlotMode,'') == true
                warndlg('No error choice was made, hence default will be shown!');
            end
            if strcmp(StdDevWeightingMode,'') == true
                warndlg('No weighting choice was made, hence default will be chosen!');
            end
    end
end

% This means each individual sample to plot.
function [ValueData,ErrorData] = NonMeanDataGenerator(i,ValueData,ErrorData,FunctionOutPut,ErrorPlotMode)
    ValueData(:,:,i) = FunctionOutPut.FinalArray;
%     BinPopulations(:,i) = FunctionOutPut.BinsPop;
    switch ErrorPlotMode
        case 'Standard error'
            ErrorData(:,:,i) = FunctionOutPut.FinalErrors;
        case 'Standard deviation'
            ErrorData(:,:,i) = FunctionOutPut.FinalStdDev;
        case ''
            % In the case that FormattingChoosing somehow doesn't prevent
            % this issue from occuring.
            ErrorData(:,:,i) = FunctionOutPut.FinalStdDev;
    end
end

% This is used for meaning the data across the Agilent output spreadsheets
% for the arrays done.
function [ValueData,ErrorData,fileNameList] = AgilentMeanDataGenerator(bins,NumberOfSamples,fileNameList,w,ErrorPlotMode,StdDevWeightingMode,debugON)
    % The prepares arrays for the data to be filled in with.
    PreValueData = zeros(bins,5,1);
    IndentDepthLimits = nan(NumberOfSamples,1);

    % Goes through each sample and runs NanoMachineImport on each and finds
    % their indent depth limits to make sure it will bin the same for all
    % of the samples. PreValueData is then concatenated in the 3rd
    % dimension by the indents from each sample.
    for i=1:NumberOfSamples
        [FunctionOutPut,IDName,filename] = NanoMachineImport(bins,StdDevWeightingMode,debugON);
        IndentDepthLimits(i) = FunctionOutPut.DepthLimit;
        PreValueData = cat(3,PreValueData,FunctionOutPut.IndentsArray);
        fileNameList(i,:) = [IDName,filename];
    end
    
    % Removes the first layer of zeros, which is created when we
    % preallocate PreValueData.
    PreValueData(:,:,1) = [];
    
    % Number of indents
    NumOfIndents = size(PreValueData,3);

    % The first part executes if the samples all aimed to go towards the
    % same indent depth, so that the depth per bin is the same between the
    % samples, which is effectively what the rows are showing, which should
    % all represent the same binning boundaries.
    if all(IndentDepthLimits(:) == IndentDepthLimits(1))
        % Makes the first column the bin midpoints, and then adds the
        % meaned data across all indents to the side of that column vector.
        ValueData = horzcat(FunctionOutPut.BinMidpoints,mean(PreValueData,3,'omitnan'));
        
        % This calculates the standard error using the above weighting choice.
        ErrorData_StdDev = std(PreValueData,w,3,'omitnan');
        
        % This is the standard error.
        ErrorData_StdError = ErrorData_StdDev/realsqrt(NumOfIndents);
        
        % The outputted error is then horizontally concatenated like
        % ValueData above.
        if strcmp(ErrorPlotMode,'Standard error') == true
            ErrorData = horzcat(FunctionOutPut.BinMidpoints,ErrorData_StdError);
        elseif strcmp(ErrorPlotMode,'Standard deviation') == true
            ErrorData = horzcat(FunctionOutPut.BinMidpoints,ErrorData_StdDev);
        end
    else
        % Self-explanatory
        errordlg('Indent termination depths are not the same!')
        ValueData = nan;
        ErrorData = nan;
        fileNameList = nan;
        return
    end

end





