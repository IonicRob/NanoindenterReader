%% QuickPlotData
% By Robert J Scales
% This quickly plots the YData against the XData as line plots with markers.
% It is a fairly basic code.

function QuickPlotData(XData,FinalArray,varNames,waitTime)
    for i=1:size(FinalArray,2)
        DebugFigure = figure();
        plot(XData,FinalArray(:,i),'-x');
        title(varNames{i+1});
        xlabel(varNames{1});
        pause(waitTime);
        close(DebugFigure);
    end
end