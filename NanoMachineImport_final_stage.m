%% NanoMachineImport_final_stage

function OutPut = NanoMachineImport_final_stage(PenultimateArray,w,NumOfIndents,bin_midpoints,bin_boundaries,DepthLimit,N,debugON,waitTime,varNames)
%% Final Averaging for Indent Array

    % FinalArray averages along the 3rd axis, which is then effectively
    % averaging accross the indents, and if there are NaN's it ignores
    % those.
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
    
%% Table Creating
    % The below is used for clearer code.
    XData = bin_midpoints;
    
    TableSize = [size(FinalArray,1),size(FinalArray,2)+1];
    varTypes    = cell(1,TableSize(2));
    varTypes(:) = {'double'};
    FinalTable = table('Size',TableSize,'VariableTypes',varTypes,'VariableNames',varNames);
    FinalTable(:,1) = table(XData);
    for column = 1:TableSize(2)-1
        FinalTable(:,column+1) = table(FinalArray(:,column));
    end
    OutPut.FinalTable = FinalTable;
    
%% Plotting the data briefly if debug is on
    % This plots all of the data for waitTime seconds before closing the figures
    
    QuickPlotData(XData,FinalArray,varNames,waitTime)
%     if debugON == true
%         for i=1:(TableSize(2)-1)
%             DebugFigure = figure();
%             plot(XData,FinalArray(:,i));
%             title(varNames{i+1});
%             xlabel(varNames{1});
%             pause(waitTime);
%             close(DebugFigure);
%         end
%     end
    
end