%% NanoImport_Agilent_Sample_Meaner


function [ValueData,ErrorData] = NanoImport_Agilent_Sample_Meaner(PreValueData,FunctionOutPut,w,ErrorPlotMode)
    % Number of indents
    NumOfIndents = size(PreValueData,3);

    % The following assumes that the bin-midpoints for all of the samples
    % are the same!! This should be true due to the "changeBinBoundaries"
    % function! This is so each row represents the same indent depth bin.
    XData = FunctionOutPut.BinMidpoints;

    % Makes the first column the bin midpoints, and then adds the
    % meaned data across all indents to the side of that column vector.
    ValueData = horzcat(XData,mean(PreValueData,3,'omitnan'));

    % This calculates the standard error using the above weighting choice.
    ErrorData_StdDev = std(PreValueData,w,3,'omitnan');

    % This is the standard error.
    ErrorData_StdError = ErrorData_StdDev/realsqrt(NumOfIndents);

    % The outputted error is then horizontally concatenated like
    % ValueData above.
    if strcmp(ErrorPlotMode,'Standard error') == true
        ErrorData = horzcat(XData,ErrorData_StdError);
    elseif strcmp(ErrorPlotMode,'Standard deviation') == true
        ErrorData = horzcat(XData,ErrorData_StdDev);
    end
        
% OLD STUFF    
%     if all(IndentDepthLimits(:) == IndentDepthLimits(1))
%     else
%         % Self-explanatory
%         PopUp = errordlg('Indent termination depths are not the same!');
%         ValueData = nan;
%         ErrorData = nan;
%         waitfor(PopUp);
%         return
%     end   

    
end