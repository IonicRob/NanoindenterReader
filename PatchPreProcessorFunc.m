% This function grabs all of the data it has analysed from NanoImporter and
% tries to remove all of the rows which contains data which would prevent
% the patched region from being plotted.
function [EFP,OutArray] = PatchPreProcessorFunc(XData,YData,YErr)
    fprintf('PatchPreProcessorFunc: Started!\n');
    CombinedArray = [YData,YErr];
    
    % This creates a logical array from which we will fill in if it is
    % being flagged as not suitable data.
    TF_isnan = false(length(XData),2);
    
    % The data is cycled through to produce logical arrays for each column.
    % Might be quicker to not even cycle through!!!!
    for i = 1:2
        TF_isnan(:,i) = isnan(CombinedArray(:,i));
    end
    
    %This is the logical array where 1's represent rows which contain bad
    %data.
    TF_final = logical(sum(TF_isnan,2));
    
    % Now we select the data we like.
    out_Val = YData(~TF_final,1);
    out_Err = YErr(~TF_final,1);
    out_X = XData(~TF_final,1);
    
    % This is for checking what data is being selected if the user wishes
    % to do so.
    OutArray = horzcat(out_X,CombinedArray(~TF_final,:));
    
    % These are the coordinates for the error region.
    EFP.X = [out_X;flipud(out_X)];
    EFP.Y = [out_Val+out_Err;flipud(out_Val-out_Err)];
    fprintf('PatchPreProcessorFunc: Complete!\n\n');
end