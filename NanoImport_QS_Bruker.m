%% NanoImport_QS_Bruker
% By Robert J Scales
%
% Currently this code only takes bins up to the maximum indent depth (i.e.
% the loading up path, and not the unloading stage; as this give me a
% headache trying to sort it out for both directions).
%
% Attempting to make it do loading and unloading

function NanoImport_QS_Bruker(debugON,bins,w,ErrorPlotMode)
%% Testing Initialisation
title = 'NanoImport_QS_Bruker';

testON = false;

if testON == true
    clc;
    WARN = warndlg('Currently in testing mode for NanoImport_QS_Bruker!!');
    waitfor(WARN);
    bins = 100;
    debugON = true;
    w = 0;
    ErrorPlotMode = 'Standard deviation';
    clearvars('-except','title','debugON','bins','w','ErrorPlotMode');
end
%% Setup
% Similar to NanoImport_Agilent_General. I will note the biggest changes.

    cd_init = cd;
    varNames = {'Depth (nm)','Load (µN)','Time (s)','Disp. Voltage(V)','Force Voltage(V)'};
    XDataCol = 1;
    NoColsOfData = 5;
    NoYCols = NoColsOfData-1;
    waitTime = 2; % You can change this!

    % This allows to get the file name and location information for
    % multiple files, starting from the load location.
    msg = 'Select the ".txt" files for each of the indents to be imported';
    PopUp = helpdlg(msg,title);
    waitfor(PopUp);
    [file,path] = uigetfile({'*.txt'},'Select nanoindentation txt files for all the indents to import:','MultiSelect','on');
    
    if isa(file,'double') == true
        errordlg('No files selected! Code will terminate!')
        return
    end
        
    IDName = file{1}; % This becomes the ID for the loaded samples.
    ProgressBar = waitbar(0,sprintf('%s: Setting up',IDName)); % Creates the progress bar.
        
    % If one file is chosen its file type will be char and not cell, hence
    % this makes it into a 1x1 cell if true.
    if isa(file,'char') == true
        file = cellstr(file);
    end
    
    % This calculates the number of samples the user has chosen based on
    % the number of files chosen.
    NumOfIndents = length(file);
    
    MaxIndentDepth = nan;
    
    % The data for each indent will be stored within a cell array!
    MasterTable = cell(NumOfIndents,1);
    
    % This fills in fileNameList
    for i =1:NumOfIndents
        fprintf('Current file loaded = %s\n',file{i});
        IndentFilename = fullfile(path,file{i});
        opts = detectImportOptions(IndentFilename,'VariableNamesLine',6,'Encoding','windows-1252','ExpectedNumVariables',5,'PreserveVariableNames',true);
        currMatrix = readmatrix(IndentFilename,opts);
        Depth = currMatrix(:,1); % Depth in nm which is good.
        Load = currMatrix(:,2)/1000; % Load is converted from uN to mN!
        Time = currMatrix(:,3); % Time in s which is good.
        DispVoltage = currMatrix(:,4); % Fake HCS column.
        ForceVoltage = currMatrix(:,5); % Fake HCS column.
        currMaxIndentDepth = max(Depth);
        if debugON == true
            fprintf('\tMax depth in file loaded = %gnm\n',currMaxIndentDepth);
        end
        MaxIndentDepth = max([currMaxIndentDepth,MaxIndentDepth]);
        MasterTable{i} = MakeTableForIndent(Depth,Load,Time,DispVoltage,ForceVoltage,varNames);
        clear IndentFilename opts currMatrix Depth Load Time DispVoltage ForceVoltage currMaxIndentDepth
    end
    
%% Binning Set-up
    
    DepthLimit = MaxIndentDepth; % in nm
    bin_boundaries = transpose(linspace(0,DepthLimit,bins+1));
    bin_width = bin_boundaries(2)-bin_boundaries(1);
    if debugON == true
        fprintf('\tBin Width = %.2fnm...\t(to two decimal places)\n',bin_width);
    end

    % This section generates the names of the bin boundaries, which will
    % pop up during debug if it can't compute a bin. The midpoints of the
    % bins which are used as the x-axis points are also calculated.
    bin_boundaries_text = strings(bins,1);
    bin_midpoints = zeros(bins,1);
    for BinNum=1:bins
        bin_boundaries_text(BinNum,1) = sprintf("%d:%d",bin_boundaries(BinNum),bin_boundaries(BinNum+1));
        bin_midpoints(BinNum,1) = mean([bin_boundaries(BinNum),bin_boundaries(BinNum+1)]);
    end
    
        
    % Specifically this repeats the midpoints on the loading up but flips
    % it upside down and attaches it to the bottom.
    bin_midpoints =  vertcat(bin_midpoints,flipud(bin_midpoints));
    
    % This is done so that the loading and unloading can be done, by having
    % the number of rows twice the number of bins.
    PenultimateArray = zeros(2*bins,NoYCols,NumOfIndents);
    PenultimateErrors = zeros(2*bins,NoYCols,NumOfIndents);
    
    % Template 2D matrices per indent for NanoMachineImport_bin_func_QS
    TemplateArray = zeros(bins,NoYCols);
    TemplateErrors = zeros(bins,NoYCols);
    
%% Binning Main Body
    indProTime = nan(NumOfIndents,1);
    
    % This for loop cycles for each indent
    for currIndNum = 1:NumOfIndents
        tic
        % This updates the progress bar with required details.
        [indAvgTime,RemainingTime] = NanoImport_avg_time_per_indent(ProgressBar,indProTime,currIndNum,NumOfIndents,IDName);
        
        if debugON == true
            fprintf("Current indent number = %d\n",currIndNum);
            fprintf('Cuurent Avg. time per indent is %.3g secs\n\n',indAvgTime(end))
        end
        
        % This selects only the data with reasonable magnitudes.
        Table_Current = table2array(MasterTable{currIndNum});
        Table_Current = Table_Current(Table_Current(:,1)>0,:);
        % Finds the maximum depth of the current indent
        [~,RowOfMaxDepth] = max(Table_Current(:,1));
        Table_Current_loading = Table_Current(1:RowOfMaxDepth,:);
        Table_Current_unloading = Table_Current(RowOfMaxDepth:end,:);
        
        % This obtains arrays which are binned for both the value and
        % standard dev., along with producing an array of the bin counts.
        [D2Array_loading,D2Errors_loading,N_loading] = NanoImport_QS_Bruker_bin_func(w,Table_Current_loading,bins,bin_boundaries,TemplateArray,TemplateErrors,ProgressBar,IDName,currIndNum,NumOfIndents,RemainingTime);
        [D2Array_unloading,D2Errors_unloading,N_unloading] = NanoImport_QS_Bruker_bin_func(w,Table_Current_unloading,bins,bin_boundaries,TemplateArray,TemplateErrors,ProgressBar,IDName,currIndNum,NumOfIndents,RemainingTime);

        % These arrays are flipped upside down because they are ordered in
        % increasing bins, but the midpoints are descending.
        D2Array_unloading = flipud(D2Array_unloading);
        D2Errors_unloading = flipud(D2Errors_unloading);
        
        PenultimateArray(:,:,currIndNum) = vertcat(D2Array_loading,D2Array_unloading);
        PenultimateErrors(:,:,currIndNum) = vertcat(D2Errors_loading,D2Errors_unloading);
        N = horzcat(N_loading,N_unloading);
        
        clear Table_Current Table_Current_loading Table_Current_unloading RowOfMaxDepth D2Array_loading D2Array_unloading D2Errors_loading D2Errors_unloading N_loading N_unloading
        
        indProTime(currIndNum,1) = toc;
    end
    
    
%% Final Compiling

    % This gets the penultimate array data and the other essential
    % information to produce an output structure containing all of the
    % information from the indent text files imported.
    OutPut = NanoMachineImport_final_stage(PenultimateArray,w,NumOfIndents,bin_midpoints,bin_boundaries,DepthLimit,N,debugON,waitTime,varNames);
    close(ProgressBar);
    
    ValueData = OutPut.FinalArray;
    if strcmp(ErrorPlotMode,'Standard deviation')
        ErrorData = OutPut.FinalStdDev;
    else
        ErrorData = OutPut.FinalErrors;
    end
    
    [~] = NanoImport_Saving(debugON,ValueData,ErrorData,w,ErrorPlotMode,varNames,XDataCol,cd_init,path);

    
    fprintf('%s: Complete!\n',title);
end

%% Functions

function OutputTable = MakeTableForIndent(Depth,Load,Time,DispVoltage,ForceVoltage,varNames)
    OutputTable = table(Depth,Load,Time,DispVoltage,ForceVoltage,'VariableNames',varNames);
end