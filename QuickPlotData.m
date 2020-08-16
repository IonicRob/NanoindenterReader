%% QuickPlotData

function QuickPlotData(XData,FinalArray,varNames,waitTime)
    for i=1:size(FinalArray,2)
        DebugFigure = figure();
        plot(XData,FinalArray(:,i));
        title(varNames{i+1});
        xlabel(varNames{1});
        pause(waitTime);
        close(DebugFigure);
    end
end