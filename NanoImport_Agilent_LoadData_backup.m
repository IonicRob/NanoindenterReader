%% NanoImport_Agilent_LoadData
% This works on each loaded indent array spreadsheet from at a time an
% Agilent CSM or QS output.

function [OutPut,SpreadSheetName] = NanoImport_Agilent_LoadData(debugON,file,filename,bins,w,MaxDepthCol,XDataCol,NoYCols,mode,varNames)
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
%     binWidth = bin_boundaries(2)-bin_boundaries(1);
    
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
    
    if debugON == true
        disp('Arrays debug');
        arraySizeDebug(PenultimateArray,'PenultimateArray');
        arraySizeDebug(PenultimateErrors,'PenultimateErrors');
    end
    
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
            fprintf('Cuurent Avg. time per indent is %.3g secs\n\n',indAvgTime(end));
        end
        
        % Preparing for NanoMachineImport_bin_func
        SheetName = SheetNames(SheetNum);
        Table_Current = TablePrep(filename,SheetName,mode);
        BinStruct = struct('XDataCol',XDataCol,'bins',bins,'bin_boundaries',bin_boundaries);
        msg_struct = struct('IDName',SpreadSheetName,'currIndNum',currIndNum,'NumOfIndents',NumOfIndents,'RemainingTime',RemainingTime,'ProgressBar',ProgressBar);

        % This obtains arrays which are binned for both the value and
        % standard dev., along with producing an array of the bin counts.
        [TemplateArray,TemplateErrors,N] = NanoMachineImport_bin_func(debugON,w,Table_Current,BinStruct,msg_struct);
        PenultimateArray(:,:,currIndNum) = TemplateArray;
        PenultimateErrors(:,:,currIndNum) = TemplateErrors;
        clearvars('TemplateArray','TemplateErrors');
        
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

%% Nested Functions
    
function Table_Current = TablePrep(filename,SheetName,mode)
    
    % This changes the range to the appropriate length
    if strcmp(mode,'csm') == true
        SheetRange = 'B:G';
        NoColsOfData = 6;
    elseif strcmp(mode,'qs') == true
        SheetRange = 'B:H';
        NoColsOfData = 7;
    end

    Table_Sheet = readmatrix(filename,'Sheet',SheetName,'FileType','spreadsheet','Range',SheetRange,'NumHeaderLines',2,'OutputType','double','ExpectedNumVariables',NoColsOfData);

    if strcmp(mode,'csm') == true
        % We look at H and E so that we can neglect data for which
        % unusually high magnitude numbers are produced.        
        GoodRows = (abs(Table_Sheet(:,5)) < 10^3) & (abs(Table_Sheet(:,6)) < 10^3);
        Table_Current = Table_Sheet(GoodRows,:);
    elseif strcmp(mode,'qs') == true
        % Assumes that we do not need to vet out bad y-data for
        % quasi-static method.
        Table_Current = Table_Sheet(:,:);
    end
end