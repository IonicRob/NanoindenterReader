%% NanoImport_Agilent_bin_func
%
% This code bins the data for the current indent (Table_Current) and
% obtains the mean for that bin along with the error, and the populations
% in each of the bins.

function [TemplateArray,TemplateErrors,N] = NanoImport_Agilent_bin_func(debugON,w,Table_Current,BinStruct,msg_struct)
%%

    testTF = false;

    if testTF == true
        WARN = warndlg('Currently in testing mode for NanoImport_Agilent_bin_func!!');
        waitfor(WARN);
        clc
        clearvars('-except','testTF');
        testData = [1,5,4;2,10,6;3,15,8;4,20,10;5,25,12;6,30,14;7,35,16;8,40,18;9,45,20;10,50,22;11,55,24;12,60,26;13,65,28;14,70,30;15,75,32;16,80,34;17,85,36;18,90,38;19,95,40;20,100,42;1,2.5,5;2,5,7;3,7.5,9;4,10,11;5,12.5,13;6,15,15;7,17.5,17;8,20,19;9,22.5,21;10,25,23;11,27.5,25;12,30,27;13,32.5,29;14,35,31;15,37.5,33;16,40,35;17,42.5,37;18,45,39;19,47.5,41;20,50,43];
        w = 0;
        Table_Current = testData;
        BinStruct = struct('XDataCol',1,'bins',10,'bin_boundaries',[0,2,4,6,8,10,12,14,16,18,20]);
        ProgressBar = waitbar(0,'Test');
        msg_struct = struct('IDName','Test','currIndNum',1,'NumOfIndents',1,'RemainingTime',5,'ProgressBar',ProgressBar);
    end
    
    %% Main

    NumOfColumns = size(Table_Current,2);
    NumOfDataColumns = NumOfColumns-1;

    % Extracts the info from the structure.
    XDataCol = BinStruct.XDataCol;
    bins = BinStruct.bins;
    bin_boundaries = BinStruct.bin_boundaries;

    % This bins the indent head displacement and counts how many in
    % each bin along with what bin each row belongs to. N = bin populations
    [N,~,binIndex] = histcounts(Table_Current(:,XDataCol),bin_boundaries);

    % These are all of the columns which contain data other than the XData.
    DataColumns = horzcat(1:XDataCol-1,XDataCol+1:NumOfColumns);
    
    % Initialises the arrays.
    TemplateArray = zeros(bins,NumOfDataColumns);
    TemplateErrors = zeros(bins,NumOfDataColumns);
    
    if debugON == true
        arraySizeDebug(TemplateArray,'TemplateArray initial');
        arraySizeDebug(TemplateErrors,'TemplateErrors initial');
    end

    % This will cycle through each of the bins
    for BinNum=1:bins
        % This finds the displacment data which are within the bin
        % range, and then selects the appropriate data.
        DataInBin = Table_Current(( binIndex == BinNum ),DataColumns);
        
        % The data is then mean averaged along each column (1) i.e.
        % along each type of measurement.
        Bin_Data = mean(DataInBin,1,'omitnan');
        Bin_StdDev = std(DataInBin,w,1,'omitnan');
        Bin_Error = Bin_StdDev/realsqrt(N(BinNum));
                
        % This adds the data into the 3D array.
        TemplateArray(BinNum,:) = Bin_Data;
        TemplateErrors(BinNum,:) = Bin_Error; % I don't believe this is used outside of this function!
        message = sprintf('%s - Indent %d/%d - Bin %d/%d\nTime Left ~ %.3g secs',msg_struct.IDName,msg_struct.currIndNum,msg_struct.NumOfIndents,BinNum,bins,msg_struct.RemainingTime);
        waitbar((msg_struct.currIndNum-1)/msg_struct.NumOfIndents,msg_struct.ProgressBar,message);
        clear Bin_Data Bin_StdDev Bin_Error DataInBin message
    end
    
    if debugON == true
        arraySizeDebug(TemplateArray,'TemplateArray after');
        arraySizeDebug(TemplateErrors,'TemplateErrors after');
    end
    
    if testTF == true
        midpoint_unit = (bin_boundaries(2)-bin_boundaries(1))/2;
        midpoints = transpose(bin_boundaries(1:end-1)+midpoint_unit);
        TemplateArray = horzcat(midpoints,TemplateArray(:,:,msg_struct.currIndNum));
        TemplateErrors = horzcat(midpoints,TemplateErrors(:,:,msg_struct.currIndNum));
        close(ProgressBar);
    end
    
end