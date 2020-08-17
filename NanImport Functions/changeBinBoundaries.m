%% changeBinBoundaries

function [DepthLimit,bin_boundaries,binWidth,bin_boundaries_text,bin_midpoints,bins,OverwriteTF] = changeBinBoundaries(debugON,NoOfSamples,fileNameList,bins,mode,XDataCol)
    title = 'changeBinBoundaries';

    [DepthLimit,bin_boundaries,binWidth,bin_boundaries_text,bin_midpoints] = MaxDepthObtainer(NoOfSamples,fileNameList,mode,bins,XDataCol);

%     if strcmp(mode,'qs') == true
        message = sprintf('Change depth limit?\nCurrent depth limit = %3.dnm & bin width = %3.dnm',DepthLimit, binWidth);
        ManualBoundaries = questdlg(message,title,'Yes','No','No');
        switch ManualBoundaries
            case 'Yes'
                disp('Boundaries are being changed manually!');
                [DepthLimit,bin_boundaries,binWidth,bin_boundaries_text,bin_midpoints,bins] = changeBinBoundaries_Main(DepthLimit,binWidth,bins);
%                 [DepthLimit,bin_boundaries,binWidth] = changeBinBoundaries_Main(DepthLimit,binWidth,bins);
                OverwriteTF = true;
            case 'No'
                % Data already generated above by MaxDepthObtainer!
                disp('Boundaries are unchanged from standard...');
                OverwriteTF = false;
        end
%     end

end
%% Nested Functions
function [new_DepthLimit,new_bin_boundaries,new_binWidth,new_bin_boundaries_text,new_bin_midpoints,bins] = changeBinBoundaries_Main(DepthLimit,binWidth,bins)
    title = 'Changing maximum bin depth limit';
    Row1 = sprintf('Enter new depth limit \n(old limit = %3.dnm  ... Num of bins = %d)',DepthLimit,bins);
    Row2 = sprintf('OR Enter bin width \n(old width = %3.dnm ... Num of bins = %d)',binWidth,bins);
    newDL = inputdlg({Row1,Row2},title,[1,70;1,70]);
    if isempty(newDL) == true
        errordlg('No new depth limit or bin width chosen!');
        [new_DepthLimit,new_bin_boundaries,new_binWidth,new_bin_boundaries_text,new_bin_midpoints] = setOutputsToNaN;
    elseif isempty(newDL{1}) == false && isempty(newDL{2}) == true
        % If depth set
        fprintf('Only max depth was filled in!\n');
        new_DepthLimit = str2double(string(newDL{1}));
%         new_binWidth = new_DepthLimit/bins;
%         new_bin_boundaries = transpose(linspace(0,new_DepthLimit,bins+1));
        [new_bin_boundaries,new_binWidth,new_bin_boundaries_text,new_bin_midpoints] = GenerateBinDetails(new_DepthLimit,bins);
        message = sprintf('New depth limit = %3.dnm ... New bin width = %3.dnm)',new_DepthLimit,new_binWidth);
        DLG = helpdlg(message);
    elseif isempty(newDL{1}) == true && isempty(newDL{2}) == false
        % If binWidth set
        fprintf('Only bin width was filled in!\n');
        new_binWidth = str2double(string(newDL{2}));
        new_DepthLimit = new_binWidth*bins;
        [new_bin_boundaries,new_binWidth,new_bin_boundaries_text,new_bin_midpoints] = GenerateBinDetails(new_DepthLimit,bins);
%         new_bin_boundaries = transpose(linspace(0,new_DepthLimit,bins+1));
        message = sprintf('New bin width = %3.dnm ... New depth limit = %3.dnm)',new_binWidth,new_DepthLimit);
        DLG = helpdlg(message);
    elseif isempty(newDL{1}) == false && isempty(newDL{2}) == false
        % If both are filled in, then it has to change the number of bins!
        fprintf('Both are depth and width are filled in!\n');
        test_DepthLimit = str2double(string(newDL{1}));
        test_binWidth = str2double(string(newDL{2}));
        Ratio = (test_DepthLimit-0)/test_binWidth;
        Remainder = mod(Ratio,1);
        if Remainder == 0
            new_DepthLimit = test_DepthLimit;
            % The integer ratio becomes the number of bins!
            bins = Ratio;
            [new_bin_boundaries,new_binWidth,new_bin_boundaries_text,new_bin_midpoints] = GenerateBinDetails(new_DepthLimit,bins);
            message = sprintf('New bin width = %dnm ... New depth limit = %dnm ... New Number of Bins = %d)',new_binWidth,new_DepthLimit,bins);
            DLG = helpdlg(message);
        else
            DLG = errordlg('The ratio of new depth limit and bin width is not an integer!');
            [new_DepthLimit,new_bin_boundaries,new_binWidth,new_bin_boundaries_text,new_bin_midpoints] = setOutputsToNaN;
        end
    else
        DLG = errordlg('Nothing chosen for "changeBinBoundaries_Main"');
    end
    waitfor(DLG);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [DepthLimit,bin_boundaries,binWidth,bin_boundaries_text,bin_midpoints] = MaxDepthObtainer(NoOfSamples,fileNameList,mode,bins,XDataCol)
    title = 'changeBinBoundaries - MaxDepthObtainer Function';  
    fprintf('%s: Started!\n',title);
    % Very similar to NanoImport_Agilent_LoadData
    Max_DepthLimit = nan;
    
    for i=1:NoOfSamples
        fprintf("Currently on sample number %d/%d \n",i,NoOfSamples);
        filename = fileNameList(i,2);
        SheetNames = sheetnames(filename);

        opts_Sheet1 = detectImportOptions(filename,'Sheet','Results','FileType','spreadsheet','PreserveVariableNames',true);
        Table_Sheet1 = readtable(filename,opts_Sheet1);
        NumOfIndents = size(Table_Sheet1,1)-3;

        for currIndNum = 1:NumOfIndents
            SheetNum = 4+NumOfIndents-currIndNum;
            SheetName = SheetNames(SheetNum);
            Table_Current = TablePrep(filename,SheetName,mode);
            curr_MaxX = max(Table_Current(:,XDataCol));
            Max_DepthLimit = max(curr_MaxX,Max_DepthLimit,'omitnan');
        end
    end

    DepthLimit = Max_DepthLimit;
    disp('Max_DepthLimit...'); disp(Max_DepthLimit);
    [bin_boundaries,binWidth,bin_boundaries_text,bin_midpoints] = GenerateBinDetails(Max_DepthLimit,bins);

    fprintf('%s: Completed!\n',title);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    else
        % Assumes that we do not need to vet out bad y-data for
        % quasi-static method.
        Table_Current = Table_Sheet(:,:);
    end
end

function [bin_boundaries,binWidth,bin_boundaries_text,bin_midpoints] = GenerateBinDetails(Max_DepthLimit,bins)

    
    bin_boundaries = transpose(linspace(0,Max_DepthLimit,bins+1));
    binWidth = bin_boundaries(2)-bin_boundaries(1);
    bin_boundaries_text = strings(bins,1);
    bin_midpoints = zeros(bins,1);
    for BinNum=1:bins
        bin_boundaries_text(BinNum,1) = sprintf("%d:%d",bin_boundaries(BinNum),bin_boundaries(BinNum+1));
        bin_midpoints(BinNum,1) = mean([bin_boundaries(BinNum),bin_boundaries(BinNum+1)]);
    end

end

function [new_DepthLimit,new_bin_boundaries,new_binWidth,new_bin_boundaries_text,new_bin_midpoints] = setOutputsToNaN
    new_DepthLimit = nan;
    new_bin_boundaries= nan;
    new_binWidth = nan;
    new_bin_boundaries_text = nan;
    new_bin_midpoints = nan;
    return
end