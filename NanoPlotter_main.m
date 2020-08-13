%% NanoPlotter_main
% By Robert J Scales
%
% DataTypeList,PlotDataTypes,figHandles are needed by NanoMeaner

function [DataTypeList,PlotDataTypes,figHandles] = NanoPlotter_main(FileStuctures,PlotAesthetics,FormatAnswer)
    fprintf('NanoPlotter: Started!\n');

    % Converts from string array that is needed to save it into a
    % cell array for further processing. 1st array should be indent depth
    % in nm! Hence not included in this.
    DataTypeList = cellstr(FileStuctures{1}.varNames(2:end));
%     DataTypeList = {'Load (mN)','Time (s)','Harmonic Contact Stiffness (N/m)','Hardness (GPa)','Youngs Modulus (GPa)'};
    PlotDataTypes = ChooseDataToPlot(DataTypeList);
    
%     % Below here it works in a similar way to NanoData Loader
%     figure('Name','LFigure','windowstate','maximized');
%     figure('Name','tFigure','windowstate','maximized');
%     figure('Name','HCSFigure','windowstate','maximized');
%     figure('Name','EFigure','windowstate','maximized');
%     figure('Name','HFigure','windowstate','maximized');
    
    for i = 1:length(DataTypeList)
        currDataType = DataTypeList{i};
        figure('Name',currDataType,'windowstate','maximized');
    end

    figHandles = findobj('Type', 'figure');
    NumberOfFiles = length(FileStuctures);
    % The first column is the indent depth column
    Y_Axis_Labels = DataTypeList; % y-axis labels
    X_Axis_Label = 'Indent Depth (nm)'; % x-axis label
    legendLocation = 'southeast';
    capsize = PlotAesthetics.capsize;
    linewidth = PlotAesthetics.linewidth;
    facealpha = PlotAesthetics.facealpha;
% 
    for FileNum = 1:NumberOfFiles

        CurrentIDName = FileStuctures{FileNum,1}.DataIDName;
        fprintf('Currently working on %s\n',CurrentIDName);
        ValueData = FileStuctures{FileNum,1}.ValueData;
        ErrorData = FileStuctures{FileNum,1}.ErrorData;
        SampleNameList = FileStuctures{FileNum,1}.SampleNameList;
        NumberOfSamples = size(ValueData,3);

        for i=1:NumberOfSamples
            LegendName = SampleNameList(i);
            currValueData = ValueData(:,:,i);
            currErrorData = ErrorData(:,:,i);

            if strcmp(FormatAnswer,'Line + Error Region') == true || strcmp(FormatAnswer,'Line') == true
                Color = LinePlotting(currValueData,PlotDataTypes,figHandles,LegendName,linewidth);
            elseif strcmp(FormatAnswer,'Line + Error Bars') == true
                ErroBarPlotting(currValueData,currErrorData,PlotDataTypes,figHandles,LegendName,linewidth,capsize)
            else
                errordlg(sprintf('Plotting mode does not match with any known options!\n = "%s"',FormatAnswer));
                return
            end

            if strcmp(FormatAnswer,'Line + Error Region') == true
                % This pre-processes the input data so that it can plot the error
                % region using the output data (EFP).
                ErrorRegionPlotting(currValueData,currErrorData,PlotDataTypes,figHandles,Color,facealpha)
            end
        end
    end
    figureFormatting(PlotDataTypes,figHandles,Y_Axis_Labels,X_Axis_Label,legendLocation)
    
    for i = 1:length(DataTypeList)
        [~,col] = find(PlotDataTypes==i);
        % This happens if col is empty, which should happen if that figure
        % option was not chosen, and hence it closes that figure.
        if isempty(col)
            close(figHandles(i))
        end
    end
    
    fprintf('NanoPlotter: Complete!\n\n');
end

%% Functions

function PlotDataTypes = ChooseDataToPlot(DataTypeList)
    PromptString = {'Select what data to plot against depth:','Multiple can be selected at once.'};
    [PlotDataTypes,~] = listdlg('PromptString',PromptString,'SelectionMode','multiple','ListString',DataTypeList);
end

function Color = LinePlotting(currValueData,PlotDataTypes,figHandles,LegendName,linewidth)
    NumberOfPlots = length(PlotDataTypes);
    for i = 1:NumberOfPlots
        currDataNum = PlotDataTypes(i); % e.g. = 3 if HCS selected
        currFigHandle = figHandles(currDataNum);
        figure(currFigHandle)
        columnNum = currDataNum+1;
        Data = plot(currValueData(:,1),currValueData(:,columnNum),'DisplayName',LegendName,'LineWidth',linewidth);
        Color = Data.Color;
        hold on
    end
end

function ErroBarPlotting(currValueData,currErrorData,PlotDataTypes,figHandles,LegendName,linewidth,capsize)
    NumberOfPlots = length(PlotDataTypes);
    for i = 1:NumberOfPlots
        currDataNum = PlotDataTypes(i); % e.g. = 3 if HCS selected
        currFigHandle = figHandles(currDataNum);
        figure(currFigHandle)
        columnNum = currDataNum+1;
        errorbar(currValueData(:,1),currValueData(:,columnNum),currErrorData(:,columnNum),'DisplayName',LegendName,'LineWidth',linewidth,'CapSize',capsize);
        hold on
    end
end

function ErrorRegionPlotting(currValueData,currErrorData,PlotDataTypes,figHandles,Color,facealpha)
    NumberOfPlots = length(PlotDataTypes);
    for i = 1:NumberOfPlots
        currDataNum = PlotDataTypes(i); % e.g. = 3 if HCS selected
        currFigHandle = figHandles(currDataNum);
        figure(currFigHandle)
        columnNum = currDataNum+1;
        XData = currValueData(:,1);
        YData = currValueData(:,columnNum);
        YErr = currErrorData(:,columnNum);
        [EFP,~] = PatchPreProcessorFunc(XData,YData,YErr);
        ErrBarFill = patch('XData',EFP.X,'YData',EFP.Y,'FaceColor',Color,'FaceAlpha',facealpha,'EdgeColor','none');
        set(get(get(ErrBarFill,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); %Does not plot it on legend
        hold on
    end
end

function figureFormatting(PlotDataTypes,figHandles,DataTypeList,X_Axis_Label,legendLocation)
    NumberOfPlots = length(PlotDataTypes);
    for i = 1:NumberOfPlots
        currDataNum = PlotDataTypes(i); % e.g. = 3 if HCS selected
        currFigHandle = figHandles(currDataNum);
        figure(currFigHandle)
        ylabel(DataTypeList(currDataNum));
        xlabel(X_Axis_Label);
        YLIM = ylim();
        XLIM = xlim();
        ylim([0,NewLimit(YLIM(2))]);
        xlim([0,NewLimit(XLIM(2))]);
        grid on;
        legend('location',legendLocation);
    end
end

function NewLimitValue = NewLimit(currLimit)
%     switch XorY
%         case 'X'
%             ticks = xticks;
%         case 'Y'
%             ticks = yticks;
%     end
%     addOn = abs(ticks(2)-ticks(1));
    addOn = floor(log10(currLimit))-1;
    NewLimitValue = currLimit+(10^addOn);
    disp(currLimit);
    disp(NewLimitValue);
end
