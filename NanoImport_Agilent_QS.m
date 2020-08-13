%% NanoImport_Agilent_QS
% By Robert J Scales
% Because the Agilent data is exported as Excel spreadsheets which have
% multiple indent data stored in them. Then in order to mean across
% multiple arrays of indents made you have to load the data from multiple
% files. Bruker has the data from each indent as a singular file. Hence,
% this process is not needed.

function NanoImport_Agilent_QS(debugON,bins,w,ErrorPlotMode)
%% Starting Up
dlg_title = 'NanoImport_Agilent_QS';
fprintf('%s: Started!\n\n',dlg_title);
cd_init = cd;

testTF = false;

if testTF == true
    clc;
    WARN = warndlg('Currently in testing mode for NanoImport_Agilent_QS!!');
    waitfor(WARN);
    debugON = true;
    bins = 100;
    w = 0;
    ErrorPlotMode = 'Standard deviation';
    clearvars('-except','debugON','bins','w','ErrorPlotMode');
end

% The below data will be dependent on whether the data to import is CSM or
% QS... THIS IS IN QS MODE
mode = 'qs';
NoColsOfData = 7;
NoYCols = NoColsOfData-1;
XDataCol = 2;
MaxDepthCol = 8;
% Creates a table so that the data can be easily analysed.
varNames = {'Depth (nm)','Time (s)','Load (uN)','X Pos (um)','Y Pos (um)','Raw Displacement (nm)','Raw Load (mN)'};


% This gets the file data for the sample.
[file,path] = uigetfile({'*.xlsx;*.xls'},'Select nanoindentation Excel file to import:','MultiSelect','on');

% Below uses the file and path data above and produces it into the correct
% format, along with producing other useful data.
[NoOfSamples,fileNameList,file] = getFileCompiler(debugON,path,file);

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
    filename = fileNameList(i,2);
    [FunctionOutPut,SpreadSheetName] = NanoImport_Agilent_LoadData(debugON,file,filename,bins,w,MaxDepthCol,XDataCol,NoYCols,mode,varNames);
    IndentDepthLimits(i) = FunctionOutPut.DepthLimit;
    PreValueData = cat(3,PreValueData,FunctionOutPut.IndentsArray);
    fileNameList(i,1) = SpreadSheetName;
end

% Removes the first layer of zeros, which is created when we
% preallocate PreValueData.
PreValueData(:,:,1) = [];

% This means the data to produce the values and their associated errors
[ValueData,ErrorData] = NanoImport_Agilent_Sample_Meaner(PreValueData,IndentDepthLimits,FunctionOutPut,w,ErrorPlotMode);

%% Final Stage

% This saves the data as a structure called dataToSave.
[~] = NanoImport_Saving(debugON,ValueData,ErrorData,w,ErrorPlotMode,varNames,XDataCol,cd_init,path);

fprintf('%s: Completed!\n\n',dlg_title);
end

%% Nested Functions

function string_array = cell2string(cell_array)
    table_of_cell = cell2table(cell_array);
    A = char(table_of_cell)
end
