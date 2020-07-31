%% Nanoindentation Data Importer
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

function OutPut = NanoImporter_CSM_Aglient(filename,IDName,bins,StdDevWeightingMode,LOC_load,debugON)
    %% Testing Section
    % Set 'testON' to true to allow for testing of this code itself.
    
    testON = false;
    
    if testON == true
        clear
        IDName = 'Test Code';
        bins = 100;
        debugON = true;
        StdDevWeightingMode = 'N-1';
        LOC_load = 'C:\Users\rober_000\OneDrive\Documents\2020 Summer Work\Matlab Codes';
        %LOC_load = 'C:\Users\robert\Desktop\Summer Project 2019 desktop\Summer Project Stuff 2019\Updated nanoindent excels\cleaned files';
        % For filename put in the fullfile location of the data you want to
        % test with.
        cd(LOC_load);
        [file,path] = uigetfile('*.xlsx','Select nanoindentation Excel file to import:');
        filename = fullfile(path,file);
    end
    
    %% Setup
    
    message = sprintf('%s: Setting up',IDName);
    ProgressBar = waitbar(0,message);
    
    if debugON == true
        fprintf("Loading from '%s'\n",LOC_load);
        waitTime = 1;
    end
    
    cd(LOC_load);
    
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
        
        % We look at H and E so that we can neglect data for which
        % unusually high magnitude numbers are produced.        
        GoodRows = (abs(Table_Sheet(:,5)) < 10^3) & (abs(Table_Sheet(:,6)) < 10^3);
        
        % This selects only the data with reasonable magnitudes.
        Table_Current = Table_Sheet(GoodRows,:);
        % This is the indent displacement array

        [PenultimateArray,PenultimateErrors,N] = NanoMachineImport_bin_func(Table_Current,bins,bin_boundaries,PenultimateArray,PenultimateErrors,ProgressBar,IDName,currIndNum,NumOfIndents,RemainingTime);
        
        indProTime(currIndNum,1) = toc;
    end
    waitbar(1,ProgressBar,'Finished working on indents!');
    %% Final Averaging for Indent Array
    
    % FinalArray averages along the 3rd axis, which is then effectively
    % averaging accross the indents, and if there are NaN's it ignores
    % those.
    
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
    
    
    FinalArray = mean(PenultimateArray,3,'omitnan');
    % This calculates the standard error using the above weighting choice.
    FinalStdDev = std(PenultimateArray,w,3,'omitnan');
    % This is the standard error.
    FinalErrors = FinalStdDev/realsqrt(NumOfIndents);
    
    % This outputs a structure called OutPut which will store all of the
    % results from the current sample.
    OutPut.BinMidpoints = bin_midpoints;
    OutPut.IndentsArray = PenultimateArray;
    OutPut.FinalArray = horzcat(bin_midpoints,FinalArray);
    OutPut.FinalStdDev = horzcat(bin_midpoints,FinalStdDev);
    OutPut.FinalErrors = horzcat(bin_midpoints,FinalErrors);
    OutPut.BinBoundaries = bin_boundaries;
    OutPut.DepthLimit = DepthLimit;
    OutPut.BinsPop = N;
    % The below is used for clearer code.
    XData = bin_midpoints;
    Load =  FinalArray(:,1);
    Time =  FinalArray(:,2);
    HCS =   FinalArray(:,3);
    H =     FinalArray(:,4);
    E =     FinalArray(:,5);
    
    % Creates a table so that the data can be easily analysed.
    varNames = {'Depth (nm)','Load (mN)','Time (s)','HCS (N/m)','Hardness (GPa)','Modulus (GPa)'};
    OutPut.FinalTable = table(XData,Load,Time,HCS,H,E,'VariableNames',varNames);
    
    
    % This plots all of the data for waitTime seconds before closing the figures
    if debugON == true
        for i=1:5
            DebugFigure = figure();
            plot(XData,FinalArray(:,i));
            title(varNames{i+1});
            xlabel(varNames{1});
            pause(waitTime);
            close(DebugFigure);
        end
    end
    close(ProgressBar);
end