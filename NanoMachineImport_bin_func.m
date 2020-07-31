%% NanoMachineImport_bin_func

function [PenultimateArray,PenultimateErrors,N] = NanoMachineImport_bin_func(Table_Current,bins,bin_boundaries,PenultimateArray,PenultimateErrors,ProgressBar,IDName,currIndNum,NumOfIndents,RemainingTime)
%%

    % NEED TO UPDATE THIS SO w CAN CHANGE!
    w = 0;

    % This bins the indent head displacement and counts how many in
    % each bin along with what bin each row belongs to.
    [N,~,binIndex] = histcounts(Table_Current(:,1),bin_boundaries);

    % This will cycle through each of the bins
    for BinNum=1:bins
        % This finds the displacment data which are within the bin
        % range, and then selects the appropriate data.
            %DataInBin_and_x = Table_Current(( binIndex == BinNum ),:);
        DataInBin = Table_Current(( binIndex == BinNum ),2:end);
        % The data is then mean averaged along each column i.e.
        % along each type of measurement.
        Bin_Data = mean(DataInBin,1,'omitnan');
        % EARLIER DIDN'T DO WEIGHTING PROPERLY!
        Bin_StdDev = std(DataInBin,w,1,'omitnan');
        Bin_Error = Bin_StdDev/realsqrt(N(BinNum));

        % This adds the data into the 3D array.
        PenultimateArray(BinNum,:,currIndNum) = Bin_Data;
        PenultimateErrors(BinNum,:,currIndNum) = Bin_Error;
        message = sprintf('%s - Indent %d/%d - Bin %d/%d\nTime Left ~ %.3g secs',IDName,currIndNum,NumOfIndents,BinNum,bins,RemainingTime);
        waitbar((currIndNum-1)/NumOfIndents,ProgressBar,message);
    end
end