%% NanoImport_Agilent_CSM
% By Robert J Scales
% Because the Agilent data is exported as Excel spreadsheets which have
% multiple indent data stored in them. Then in order to mean across
% multiple arrays of indents made you have to load the data from multiple
% files. Bruker has the data from each indent as a singular file. Hence,
% this process is not needed.

function NanoImport_Agilent_CSM(debugON,bins,w,ErrorPlotMode)
%% Starting Up
dlg_title = 'NanoImport_Agilent_CSM';
fprintf('--------------------------------\n%s: Started!\n',dlg_title);
cd_init = cd;

testTF = false;

if testTF == true
    clc;
    WARN = warndlg('Currently in testing mode for NanoImport_Agilent_CSM!!');
    waitfor(WARN);
    debugON = true;
    bins = 100;
    w = 0;
    ErrorPlotMode = 'Standard deviation';
    clearvars('-except','debugON','bins','w','ErrorPlotMode');
end

% The below data will be dependent on whether the data to import is CSM or
% QS... THIS IS IN CSM MODE
mode = 'csm';
NoColsOfData = 6;
NoYCols = NoColsOfData-1;
XDataCol = 1;
MaxDepthCol = 3;
% Creates a table so that the data can be easily analysed.
varNames = {'Depth (nm)','Load (mN)','Time (s)','HCS (N/m)','Hardness (GPa)','Modulus (GPa)'};


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
    curr_filename = fileNameList(i,2); curr_file = file(i);
    if debugON == true
        fprintf('filename working on = %s',curr_filename);
    end
    [FunctionOutPut,SpreadSheetName] = NanoImport_Agilent_LoadData(debugON,curr_file,curr_filename,bins,w,MaxDepthCol,XDataCol,NoYCols,mode,varNames);
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
[dataToSave] = NanoImport_Saving(debugON,ValueData,ErrorData,w,ErrorPlotMode,varNames,XDataCol,cd_init,path);

fprintf('%s: Completed!\n\n',dlg_title);
end

%% Nested Functions

