%% NanoPlotter_main
% By Robert J Scales
%
% DataTypeList,PlotDataTypes,figHandles are needed by NanoMeaner

function [DataTypeList,PlotDataTypes,figHandles] = NanoPlotter_main(debugON,FileStuctures,PlotAesthetics)
    %% Setting Up
    fprintf('NanoPlotter_main: Started!\n');

    % Converts from string array that is needed to save it into a
    % cell array for further processing. 1st array should be indent depth
    % in nm! Hence not included in this.
    DataTypeList = cellstr(FileStuctures{1}.varNames);
    PromptString = {'Select what data to plot against depth:','Multiple can be selected at once.'};
    [PlotDataTypes,~] = listdlg('PromptString',PromptString,'SelectionMode','multiple','ListString',DataTypeList);
    if debugON == true
        disp('PlotDataTypes = ...');
        disp(PlotDataTypes);
    end
    clear PromptString
    
    for i = 1:length(DataTypeList)
        currDataType = DataTypeList{i};
        split_DataTypeList = split(currDataType);
        fig_Name = split_DataTypeList{1};
        figure('Name',fig_Name,'windowstate','maximized');
    end

    figHandles = findobj('Type', 'figure'); % Gets the current figure handles
    NumberOfFiles = length(FileStuctures);
    % The first column is the indent depth column
    Y_Axis_Labels = DataTypeList; % y-axis labels
    X_Axis_Label = 'Indent Depth (nm)'; % x-axis label
    legendLocation = 'southeast';
    capsize = PlotAesthetics.capsize;
    linewidth = PlotAesthetics.linewidth;
    facealpha = PlotAesthetics.facealpha;
    
    if debugON == true
        disp('DEBUG ON!')
        disp('Initial figure handles are:');
        disp(figHandles);
        fprintf('Number of loaded files = %d\n',NumberOfFiles)
    end
    
    ErrorsYNArray = false(NumberOfFiles,1);
 
    for u = 1:NumberOfFiles
        ErrorsYNArray(u) = ~all(isnan(FileStuctures{u,1}.ErrorData),'all');
    end
    ErrorsYN = all(ErrorsYNArray,'all');
    
    if ErrorsYN == true
        % The below chooses how the data will be presented in the figures.
        % This is how the data will be shown on the graph.
        FormatAnswer = questdlg('How do you want to present the data?',dlg_title,'Line + Error Region','Line + Error Bars','Line',DefaultDlg.FormatAnswer);
        if strcmp(FormatAnswer,'') == true
            DLG = errordlg('Exit button was pressed! Code will terminate!');
            waitfor(DLG);
            return
        end
    else
        FormatAnswer = 'Line';
    end
    
    %% Main Loop 
    for FileNum = 1:NumberOfFiles
        CurrentIDName = FileStuctures{FileNum,1}.DataIDName;
        fprintf('Currently working on %s\n',CurrentIDName);
        
        ValueData = FileStuctures{FileNum,1}.ValueData;
        XDataCol = FileStuctures{FileNum,1}.XDataCol;
        ErrorData = FileStuctures{FileNum,1}.ErrorData;
        NumberOfSamples = size(ValueData,3);
        
        SampleNameList = FileStuctures{FileNum,1}.SampleNameList;

        for i=1:NumberOfSamples
            LegendName = SampleNameList(i);
            currValueData = ValueData(:,:,i);
            currErrorData = ErrorData(:,:,i);
            
            if debugON == true
                disp('Current Value Data = ...')
                disp(currValueData);
            end
            
            if strcmp(FormatAnswer,'Line + Error Region') == true || strcmp(FormatAnswer,'Line') == true
                Color = LinePlotting(currValueData,PlotDataTypes,LegendName,linewidth,XDataCol);
            elseif strcmp(FormatAnswer,'Line + Error Bars') == true
                ErroBarPlotting(currValueData,currErrorData,PlotDataTypes,LegendName,linewidth,capsize,XDataCol);
            else
                errordlg(sprintf('Plotting mode does not match with any known options!\n = "%s"',FormatAnswer));
                return
            end

            
            if strcmp(FormatAnswer,'Line + Error Region') == true
                % This pre-processes the input data so that it can plot the error
                % region using the output data (EFP).
                ErrorRegionPlotting(currValueData,currErrorData,PlotDataTypes,Color,facealpha,XDataCol);
            end
            
            clear LegendName currValueData currErrorData Color
        end
        
        clear CurrentIDName ValueData ErrorData NumberOfSamples SampleNameList Color
    end
    figureFormatting(PlotDataTypes,DataTypeList,X_Axis_Label,legendLocation);
        
    figureClosing(debugON,DataTypeList,PlotDataTypes);
    

    
    fprintf('NanoPlotter_main: Complete!\n\n');
end

%% Functions

function Color = LinePlotting(currValueData,PlotDataTypes,LegendName,linewidth,XDataCol)
    for j = PlotDataTypes
        columnNum = j; % e.g. = 3 if HCS selected
        figure(columnNum)
        Data = plot(currValueData(:,XDataCol),currValueData(:,columnNum),'DisplayName',LegendName,'LineWidth',linewidth);
        Color = Data.Color;
        hold on
    end
end

function ErroBarPlotting(currValueData,currErrorData,PlotDataTypes,LegendName,linewidth,capsize,XDataCol)
    for i = PlotDataTypes
        columnNum = i; % e.g. = 3 if HCS selected
        figure(columnNum)
        errorbar(currValueData(:,XDataCol),currValueData(:,columnNum),currErrorData(:,columnNum),'DisplayName',LegendName,'LineWidth',linewidth,'CapSize',capsize);
        hold on
    end
end

function ErrorRegionPlotting(currValueData,currErrorData,PlotDataTypes,Color,facealpha,XDataCol)
    for i = PlotDataTypes
        columnNum = i; % e.g. = 3 if HCS selected
        figure(columnNum)
        XData = currValueData(:,XDataCol);
        YData = currValueData(:,columnNum);
        YErr = currErrorData(:,columnNum);
        [EFP,~] = PatchPreProcessorFunc(XData,YData,YErr);
        ErrBarFill = patch('XData',EFP.X,'YData',EFP.Y,'FaceColor',Color,'FaceAlpha',facealpha,'EdgeColor','none');
        set(get(get(ErrBarFill,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); %Does not plot it on legend
        hold on
    end
end

function figureFormatting(PlotDataTypes,DataTypeList,X_Axis_Label,legendLocation)
    NumberOfPlots = length(PlotDataTypes);
    for i = 1:NumberOfPlots
        currDataNum = PlotDataTypes(i); % e.g. = 3 if HCS selected
        figure(currDataNum)
        ylabel(DataTypeList(currDataNum));
        xlabel(X_Axis_Label);
%         YLIM = ylim();
%         XLIM = xlim();
%         ylim([0,NewLimit(YLIM(2))]);
%         xlim([0,NewLimit(XLIM(2))]);
        grid on;
        legend('location',legendLocation);
    end
end

function NewLimitValue = NewLimit(currLimit)
    addOn = floor(log10(currLimit))-1;
    NewLimitValue = currLimit+(10^addOn);
    disp(currLimit);
    disp(NewLimitValue);
end

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

function figureClosing(debugON,DataTypeList,PlotDataTypes)
    for FigNum = 1:length(DataTypeList)
        [~,col] = find(PlotDataTypes==FigNum);
        
        if debugON == true && isempty(col) == false
            fprintf('FigNum = %d\ncol = %d\n',FigNum,col);
        end
        
        % This happens if col is empty, which should happen if that figure
        % option was not chosen, and hence it closes that figure.
        if isempty(col)
            close(figure(FigNum))
        end
    end
end