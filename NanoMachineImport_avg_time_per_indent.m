%% NanoMachineImport_avg_time_per_indent

function [indAvgTime,RemainingTime] = NanoMachineImport_avg_time_per_indent(ProgressBar,indProTime,currIndNum,NumOfIndents,IDName)

    % The below two indAvgTime can be used to find the average time per
    % indent, currently the moving mean average is being use.
    indAvgTime = movmean(indProTime(1:currIndNum),[3 0],'omitnan');
    
    % This calculates the remaining time and updates the progress bar
    % using that.
    RemainingTime = (NumOfIndents-currIndNum)*indAvgTime(end);
    message = sprintf('%s - Indent %d/%d\nTime Left ~ %.3g secs',IDName,currIndNum,NumOfIndents,RemainingTime);
    waitbar((currIndNum-1)/NumOfIndents,ProgressBar,message);
end