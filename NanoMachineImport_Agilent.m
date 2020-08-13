%% NanoMachineImport_Agilent
% By Robert J Scales
% Because the Agilent data is exported as Excel spreadsheets which have
% multiple indent data stored in them. Then in order to mean across
% multiple arrays of indents made you have to load the data from multiple
% files. Bruker has the data from each indent as a singular file. Hence,
% this process is not needed.

function NanoMachineImport_Agilent(debugON,mode,bins,w,ErrorPlotMode)
%% Starting Up
dlg_title = 'NanoMachineImport_Agilent';

testTF = true;

if testTF == true
    clc;
    mode = 'qs';
    debugON = true;
    bins = 100;
    w = 0;
    ErrorPlotMode = 'Standard deviation';
    clearvars('-except','mode','debugON','bins','w','ErrorPlotMode');
end

% The below data will be dependent on whether the data to import is CSM or
% QS.
if strcmp(mode,'qs') == true
    NoColsOfData = 7;
    NoYCols = NoColsOfData-1;
    XDataCol = 2;
    MaxDepthCol = 8;
    % Creates a table so that the data can be easily analysed.
    varNames = {'Depth (nm)','Time (s)','Load (uN)','X Pos (um)','Y Pos (um)','Raw Displacement (nm)','Raw Load (mN)'};
elseif strcmp(mode,'csm') == true
    NoColsOfData = 6;
    NoYCols = NoColsOfData-1;
    XDataCol = 1;
    MaxDepthCol = 3;
    % Creates a table so that the data can be easily analysed.
    varNames = {'Depth (nm)','Load (mN)','Time (s)','HCS (N/m)','Hardness (GPa)','Modulus (GPa)'};
end

% This gets the file data for the sample.
[file,path] = uigetfile({'*.xlsx;*.xls'},'Select nanoindentation Excel file to import:','MultiSelect','on');
filename = string(fullfile(path,file));

if isa(file,'double') == true
    errordlg('No file selected! Code terminated!')
    return
end

% If one file is chosen its file type will be char and not cell, hence
% this makes it into a 1x1 cell if true.
if isa(file,'char') == true
    file = cellstr(file);
end

file = string(file);
NoOfSamples = size(file,2);


if debugON == true
    fprintf("Loading from '%s'\n",path);
end


% This prepares a string array to be filled in with the full filenames
% and the name the user wished to label the data with.
fileNameList = strings(NoOfSamples,2);
fileNameList(:,2) = transpose(string(filename));

% The prepares arrays for the data to be filled in with.
PreValueData = zeros(bins,NoYCols,1);
IndentDepthLimits = nan(NoOfSamples,1);

%% Main Data Gathering

% Goes through each sample and runs NanoMachineImport on each and finds
% their indent depth limits to make sure it will bin the same for all
% of the samples. PreValueData is then concatenated in the 3rd
% dimension by the indents from each sample.
for i=1:NoOfSamples
    fprintf("Currently on sample number %d/%d\n",i,NoOfSamples);
    [FunctionOutPut,SpreadSheetName] = LoadSpreadsheetData(debugON,file,filename,bins,w,MaxDepthCol,XDataCol,NoYCols,mode,varNames);
%     [FunctionOutPut,IDName,filename] = NanoMachineImport(bins,StdDevWeightingMode,debugON);
    IndentDepthLimits(i) = FunctionOutPut.DepthLimit;
    PreValueData = cat(3,PreValueData,FunctionOutPut.IndentsArray);
    fileNameList(i,1) = SpreadSheetName;
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
    XData = FunctionOutPut.BinMidpoints;
    
    % Makes the first column the bin midpoints, and then adds the
    % meaned data across all indents to the side of that column vector.
    ValueData = horzcat(XData,mean(PreValueData,3,'omitnan'));

    % This calculates the standard error using the above weighting choice.
    ErrorData_StdDev = std(PreValueData,w,3,'omitnan');

    % This is the standard error.
    ErrorData_StdError = ErrorData_StdDev/realsqrt(NumOfIndents);

    % The outputted error is then horizontally concatenated like
    % ValueData above.
    if strcmp(ErrorPlotMode,'Standard error') == true
        ErrorData = horzcat(XData,ErrorData_StdError);
    elseif strcmp(ErrorPlotMode,'Standard deviation') == true
        ErrorData = horzcat(XData,ErrorData_StdDev);
    end
else
    % Self-explanatory
    errordlg('Indent termination depths are not the same!')
%     ValueData = nan;
%     ErrorData = nan;
%     fileNameList = nan;
    return
end

%% Final Stage

message = 'Type in the name of the meaned data (e.g. the material name):';
SampleNameList = string(inputdlg(message,dlg_title,[1,50]));

FileStuctures{1} = struct('ValueData',ValueData,'ErrorData',ErrorData,'SampleNameList',SampleNameList,'DataIDName',SampleNameList);



end

%% Functions

function [OutPut,SpreadSheetName] = LoadSpreadsheetData(debugON,file,filename,bins,w,MaxDepthCol,XDataCol,NoYCols,mode,varNames)
    title = 'NanoMachineImport_Agilent - MainProcess Function';
    [ProgressBar,SpreadSheetName] = NanoMachineImport_first_stage(title,file);
    
    SheetNames = sheetnames(filename);
    
    % This accesses the first sheet named 'Results'
    opts_Sheet1 = detectImportOptions(filename,'Sheet','Results','FileType','spreadsheet','PreserveVariableNames',true);
    Table_Sheet1 = readtable(filename,opts_Sheet1);
    % This then calculates the number of indents from which it will cycle
    % through, hence if you delete entries on here and their associated
    % sheets it will be fine
    NumOfIndents = size(Table_Sheet1,1)-3;
    message = sprintf('%s: Set-up - "Results" Analysed',SpreadSheetName);
    waitbar(1/4,ProgressBar,message);
    
    
    % This accesses the second sheet named 'Required Inputs'
    opts_Sheet2 = detectImportOptions(filename,'Sheet','Required Inputs','FileType','spreadsheet','PreserveVariableNames',true);
    Table_Sheet2 = readtable(filename,opts_Sheet2);
    
    % This accesses the depth limit, from which it will then work out the
    % bin boundaries.
    DepthLimit = table2array(Table_Sheet2(1,MaxDepthCol)); % in nm
    bin_boundaries = transpose(linspace(0,DepthLimit,bins+1));
    binWidth = bin_boundaries(2)-bin_boundaries(1);
    
    if strcmp(mode,'qs') == true
        message = sprintf('Change depth limit?\nCurrent depth limit = %3.dnm & bin width = %3.dnm',DepthLimit, binWidth);
        ManualBoundaries = questdlg(message,title,'Yes','No','No');
        if strcmp(ManualBoundaries,'Yes')
            disp('Boundaries are being changed manually!');
            [DepthLimit,bin_boundaries,binWidth] = changeBinBoundaries(DepthLimit,binWidth,bins);
        end
    end
    
    message = sprintf('%s: Set-up - "Required Inputs" Analysed',SpreadSheetName);
    waitbar(2/4,ProgressBar,message);

    % This section generates the names of the bin boundaries, which will
    % pop up during debug if it can't compute a bin. The midpoints of the
    % bins which are used as the x-axis points are also calculated.
    bin_boundaries_text = strings(bins,1);
    bin_midpoints = zeros(bins,1);
    for BinNum=1:bins
        bin_boundaries_text(BinNum,1) = sprintf("%d:%d",bin_boundaries(BinNum),bin_boundaries(BinNum+1));
        bin_midpoints(BinNum,1) = mean([bin_boundaries(BinNum),bin_boundaries(BinNum+1)]);
    end
    message = sprintf('%s: Set-up - Bin Calculations Done',SpreadSheetName);
    waitbar(3/4,ProgressBar,message);
    
    % This is a 3D array which will store the force, time, HCS, H, and E
    % data, with the 3rd axis being for each indent.
    PenultimateArray = zeros(bins,NoYCols,NumOfIndents);
    PenultimateErrors = zeros(bins,NoYCols,NumOfIndents);
    
    message = sprintf('%s: Set-up Complete!',SpreadSheetName);
    waitbar(1,ProgressBar,message);
    
    indProTime = nan(NumOfIndents,1);
    
    % This for loop cycles for each indent
    for currIndNum = 1:NumOfIndents
        tic
        % This updates the progress bar with required details.
        [indAvgTime,RemainingTime] = NanoMachineImport_avg_time_per_indent(ProgressBar,indProTime,currIndNum,NumOfIndents,SpreadSheetName);

        % There are 4 sheets auto-generated that aren't indent data, then
        % it works from right to left, hence minus the indent number.
        SheetNum = 4+NumOfIndents-currIndNum;
        
        if debugON == true
            fprintf("Current indent number %d/%d\n",currIndNum,NumOfIndents);
            fprintf('Cuurent Avg. time per indent is %.3g secs\n\n',indAvgTime(end))
        end
        
        SheetName = SheetNames(SheetNum);
        Table_Current = TablePrep(filename,SheetName,NoYCols+1,mode);
        
%         XData = 

        % This obtains arrays which are binned for both the value and
        % standard dev., along with producing an array of the bin counts.
        BinStruct = struct('XDataCol',XDataCol,'bins',bins,'bin_boundaries',bin_boundaries);
        msg_struct = struct('IDName',SpreadSheetName,'currIndNum',currIndNum,'NumOfIndents',NumOfIndents,'RemainingTime',RemainingTime,'ProgressBar',ProgressBar);
        [TemplateArray,TemplateErrors,N] = NanoMachineImport_bin_func(w,Table_Current,BinStruct,msg_struct);
        PenultimateArray(:,:,currIndNum) = TemplateArray;
        PenultimateErrors(:,:,currIndNum) = TemplateErrors;
        
        indProTime(currIndNum,1) = toc;
    end
    waitbar(1,ProgressBar,'Finished working on indents!');
    
    % This gets the penultimate array data and the other essential
    % information to produce an output structure containing all of the
    % information from the imported Excel spreadsheet.
    waitTime = 5;
    OutPut = NanoMachineImport_final_stage(PenultimateArray,w,NumOfIndents,bin_midpoints,bin_boundaries,DepthLimit,N,debugON,waitTime,varNames);
    close(ProgressBar);
    fprintf('%s: Completed!\n',title);
end

%%
    
function Table_Current = TablePrep(filename,SheetName,NoColsOfData,mode)

    % Importing the data for the current indent
    if strcmp(mode,'csm') == true
        SheetRange = 'B:G';
    elseif strcmp(mode,'qs') == true
        SheetRange = 'B:H';
    end
    
    Table_Sheet = readmatrix(filename,'Sheet',SheetName,'FileType','spreadsheet','Range',SheetRange,'NumHeaderLines',2,'OutputType','double','ExpectedNumVariables',NoColsOfData);

    if strcmp(mode,'csm') == true
        % We look at H and E so that we can neglect data for which
        % unusually high magnitude numbers are produced.        
        GoodRows = (abs(Table_Sheet(:,5)) < 10^3) & (abs(Table_Sheet(:,6)) < 10^3);
        disp(GoodRows);
        Table_Current = Table_Sheet(GoodRows,:);
    elseif strcmp(mode,'qs') == true
        Table_Current = Table_Sheet(:,:);
    end
end

%%

function [new_DepthLimit,new_bin_boundaries,new_binWidth] = changeBinBoundaries(DepthLimit,binWidth,bins)
    title = 'Changing maximum bin depth limit';
    Row1 = sprintf('Enter new depth limit \n(old limit = %3.dnm  ... Num of bins = %d)',DepthLimit,bins);
    Row2 = sprintf('OR Enter bin width \n(old width = %3.dnm ... Num of bins = %d)',binWidth,bins);
    newDL = inputdlg({Row1,Row2},title,[1,70;1,70]);
    if isempty(newDL) == true
        errordlg('No new depth limit or bin widthchosen!');
        new_DepthLimit = nan; new_bin_boundaries= nan; new_binWidth = nan;
        return
    elseif isempty(newDL{1}) == false
        new_DepthLimit = str2double(string(newDL{1}));
        new_binWidth = new_DepthLimit/bins;
        new_bin_boundaries = transpose(linspace(0,new_DepthLimit,bins+1));
        message = sprintf('New depth limit = %3.dnm ... New bin width = %3.dnm)',new_DepthLimit,new_binWidth);
        DLG = helpdlg(message);
    elseif isempty(newDL{1}) == true && isempty(newDL{2}) == false
        new_binWidth = str2double(string(newDL{2}));
        new_DepthLimit = new_binWidth*bins;
        new_bin_boundaries = transpose(linspace(0,new_DepthLimit,bins+1));
        message = sprintf('New depth limit = %3.dnm ... New bin width = %3.dnm)',new_DepthLimit,new_binWidth);
        DLG = helpdlg(message);
    else
        errordlg()
    end
    waitfor(DLG);
    
end