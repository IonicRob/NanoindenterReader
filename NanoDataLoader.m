%% Nanoindentation Data Loader
% Written by Robert J Scales

function NanoDataLoader(debugON,PlotAesthetics,DefaultDlg,ImageFormatType)
%% Set-up
% The comments for what the below does can be found pretty much in
% NanoDataCreater!

clc;
dlg_title = 'NanoindentationDataLoader';
fprintf('%s: Started!\n\n',dlg_title);
NanoCreaterLoaderClearer(false,false);
LOC_init = cd;

[FileStuctures,fileNameList,~] = LoadingFilesFunc(debugON);

%% Settings

[FormatAnswer] = FormattingChoosing(dlg_title,DefaultDlg);

%% Plotting
cd(LOC_init);

close all

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


%% Meaning the data across a depth range


cd(LOC_init);
ToMeanOrNotToMean = questdlg('Find a mean value within a range?',dlg_title,'Yes','No','No');
switch ToMeanOrNotToMean
    case 'Yes'
        NanoMeaner(FileStuctures,figHandles,DataTypeList,PlotDataTypes,LOC_init);
    otherwise
        disp('You have decided not to find the mean value within a range...');
end

%% Saving Results

LoadingMode = true;
cd(LOC_init);
[~,~,~,~] = NanoDataSave(ImageFormatType,LoadingMode,LOC_init,dlg_title,fileNameList);


fprintf('NanoDataLoader: Complete!\n\n');

end











    
%% Functions
function [FileStuctures,fileNameList,LOC_load] = LoadingFilesFunc(debugON)
    % Change current directory to the directory to load the data from.
    
    % This allows to get the file name and location information for
    % multiple files, starting from the load location.
    
    [file,path] = uigetfile('*.mat','Select nanoindentation "mat" files made by "NanoDataCreater" to plot (must all be in one folder):','MultiSelect','on');

    if isa(file,'double') == true
        errordlg('No files selected! Code will terminate!')
        return
    end
    
    LOC_load = path;
    
    % If one file is chosen its file type will be char and not cell, hence
    % this makes it into a 1x1 cell if true.
    if isa(file,'char') == true
        file = cellstr(file);
    end
    
    % This calculates the number of samples the user has chosen based on
    % the number of files chosen.
    NumberOfFiles = length(file);

    if debugON == true
        fprintf('Loading files from "%s"...\n',LOC_load);
        fprintf('Number of files detected = %d\n',NumberOfFiles);
    end
    
    % This prepares a string array to be filled in with the full filenames
    % and the name the user wished to label the data with.
    fileNameList = strings(NumberOfFiles,2);
    FileStuctures = cell(NumberOfFiles,1);
    
    % This fills in fileNameList
    for i =1:NumberOfFiles
        filename = fullfile(path,file{i});
        fileNameList(i,1) = file{i};
        fileNameList(i,2) = filename;
        %FileStuctures(i) = load(filename,'-mat');
        FileStucturesProto = load(filename,'-mat');
        FileStuctures{i} = FileStucturesProto.dataToSave;
        if debugON == true
            fprintf('Loaded file named "%s"\n',file{i});
        end
    end
end


function [FormatAnswer] = FormattingChoosing(dlg_title,DefaultDlg)
    % This is how the data will be shown on the graph.
    FormatAnswer = questdlg('How do you want to present the data?',dlg_title,'Line + Error Region','Line + Error Bars','Line',DefaultDlg.FormatAnswer);

    switch FormatAnswer
        case 'Line'
            disp('No error bars will be shown on the graph');
        case ''
            errordlg('Exit button was pressed! Code will terminate!')
            return
    end
end

function PlotDataTypes = ChooseDataToPlot(DataTypeList)
    PromptString = {'Select what data to plot against depth:','Multiple can be selected at once.'};
    [PlotDataTypes,~] = listdlg('PromptString',PromptString,'SelectionMode','multiple','ListString',DataTypeList);
end





