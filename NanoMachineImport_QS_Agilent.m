%% NanoMachineImport_QS_Agilent
% Written by Robert J Scales
% This works on the Excel spreadsheets produced by the nanoindenters, which
% shouldn't require any editing apart from deleting indents from the
% 'Results' sheet and their respective sheets.
%
% This code works by binning the depth limit into a set number of bins i.e.
% a depth limit of 2000nm with 100 bins will have bin ranges of 20nm
% in magnitude. It will then find the data points for each indent within
% each of these bin ranges and find the mean average value. It will then
% find the average bin value for of all of the indents for each bin.

function [OutPut,IDName,filename] = NanoMachineImport_QS_Agilent(bins,StdDevWeightingMode,debugON)
    %% Testing Section
    % Set 'testON' to true to allow for testing of this code itself.
    
    testON = false;
    
    if testON == true
        clear
        bins = 100;
        debugON = true;
        StdDevWeightingMode = 'N-1';
    end
    
%% Setup
    
    title = 'NanoMachineImport_CSM_Agilent';
    
    % This gets the file data for the sample.
    [file,path] = uigetfile({'*.xlsx;*.xls'},'Select nanoindentation Excel file to import:','MultiSelect','off');
    filename = fullfile(path,file);
    
    if isa(file,'double') == true
        errordlg('No file selected! Code terminated!')
        return
    end
    
    if debugON == true
        fprintf("Loading from '%s'\n",path);
    end
    
    [w,ProgressBar,waitTime,IDName] = NanoMachineImport_first_stage(title,StdDevWeightingMode,file);
    
    SheetNames = sheetnames(filename);
    
    % This accesses the first sheet named 'Results'
    opts_Sheet1 = detectImportOptions(filename,'Sheet','Results','FileType','spreadsheet','PreserveVariableNames',true);
    Table_Sheet1 = readtable(filename,opts_Sheet1);
    % This then calculates the number of indents from which it will cycle
    % through, hence if you delete entries on here and their associated
    % sheets it will be fine
    NumOfIndents = size(Table_Sheet1,1)-3;
    message = sprintf('%s: Set-up - "Results" Analysed',IDName);
    waitbar(1/4,ProgressBar,message);
    
    
    % This accesses the second sheet named 'Required Inputs'
    opts_Sheet2 = detectImportOptions(filename,'Sheet','Required Inputs','FileType','spreadsheet','PreserveVariableNames',true);
    Table_Sheet2 = readtable(filename,opts_Sheet2);
    % This accesses the depth limit, from which it will then work out the
    % bin boundaries.
    DepthLimit = table2array(Table_Sheet2(1,3)); % in nm
    bin_boundaries = transpose(linspace(0,DepthLimit,bins+1));
    message = sprintf('%s: Set-up - "Required Inputs" Analysed',IDName);
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
    message = sprintf('%s: Set-up - Bin Calculations Done',IDName);
    waitbar(3/4,ProgressBar,message);
    
    % This is a 3D array which will store the force, time, HCS, H, and E
    % data, with the 3rd axis being for each indent.
    PenultimateArray = zeros(bins,5,NumOfIndents);
    PenultimateErrors = zeros(bins,5,NumOfIndents);
    
    message = sprintf('%s: Set-up Complete!',IDName);
    waitbar(1,ProgressBar,message);
    %% Main body
    
    indProTime = nan(NumOfIndents,1);
    
    % This for loop cycles for each indent
    for currIndNum = 1:NumOfIndents
        tic
        % This updates the progress bar with required details.
        [indAvgTime,RemainingTime] = NanoMachineImport_avg_time_per_indent(ProgressBar,indProTime,currIndNum,NumOfIndents,IDName);

        % There are 4 sheets auto-generated that aren't indent data, then
        % it works from right to left, hence minus the indent number.
        SheetNum = 4+NumOfIndents-currIndNum;
        
        if debugON == true
            fprintf("Current sheet name/number = %s/%d\n",SheetNames(SheetNum),SheetNum);
            fprintf('Cuurent Avg. time per indent is %.3g secs\n\n',indAvgTime(end))
        end
        
        % Importing the data for the current indent
        Table_Sheet = readmatrix(filename,'Sheet',SheetNames(SheetNum),'FileType','spreadsheet','Range','B:G','NumHeaderLines',2,'OutputType','double','ExpectedNumVariables',6);
        
%         % We look at H and E so that we can neglect data for which
%         % unusually high magnitude numbers are produced.        
%         GoodRows = (abs(Table_Sheet(:,5)) < 10^3) & (abs(Table_Sheet(:,6)) < 10^3);
        
        % This selects only the data with reasonable magnitudes.
        Table_Current = Table_Sheet(:,:);

        % This obtains arrays which are binned for both the value and
        % standard dev., along with producing an array of the bin counts.
        [PenultimateArray,PenultimateErrors,N] = NanoMachineImport_bin_func(w,Table_Current,bins,bin_boundaries,PenultimateArray,PenultimateErrors,ProgressBar,IDName,currIndNum,NumOfIndents,RemainingTime);
        
        indProTime(currIndNum,1) = toc;
    end
    waitbar(1,ProgressBar,'Finished working on indents!');
    %% Final Averaging for Indent Array
    
    % This gets the penultimate array data and the other essential
    % information to produce an output structure containing all of the
    % information from the imported Excel spreadsheet.
    OutPut = NanoMachineImport_final_stage(PenultimateArray,w,NumOfIndents,bin_midpoints,bin_boundaries,DepthLimit,N,debugON,waitTime);
    close(ProgressBar);
    fprintf('%s: Completed!\n',title);
end