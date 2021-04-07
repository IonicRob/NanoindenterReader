%% NanoImport_SummariseArray
% By Robert J Scales

function NanoImport_SummariseArray
%% Settings
close all
clear
clc
old_path = addpath('./Analyse/','./Import/','./Plotter/');
set(0, 'DefaultLineLineWidth', 2);
set(0,'defaultAxesFontSize',20); % This sets the font size for all text in all of the figures!
set(0,'defaultLineMarkerSize',12); % This sets the marker size for all text in all of the figures!

Depth_Min = 300;
Depth_Max = 500;

NumXIndents = 60;

XIndents_Space = 10;
XIndents_Units = 'um';

YIndents_Space = -100;
YIndents_Units = 'um';

%% Starting Up

% uisetpref('clearall');
SavingData = 'auto';

dlg_title = mfilename;
fprintf('%s: Started!\n\n',dlg_title);

[debugON,~] = ifcalled;

cd_init = cd; % Initial directory

filter = {'*.xlsx','Agilent Files (*.xlsx)';'*.txt','Bruker Files (*.txt)'};

% This gets the file data for the sample.
[file,path,fileTypeIndex] = uigetfile(filter,'Select file(s) to import:','MultiSelect','on');
cd_load = path;
% Below uses the file and path data above and produces it into the correct
% format, along with producing other useful data.
[NoOfFiles,fileNameList,files] = getFileCompiler(debugON,path,file);
if isnan(NoOfFiles) == true
    return
end

%% Importing Data

% This gives the user the option of where to save the data or not to
% save the data at all.
[SavingLocYN,cd_save] = NanoSaveFolderPref('Imported files save location?:',cd_init,cd_load);

for CurrFileNum=1:NoOfFiles    
    filename = fileNameList(CurrFileNum,2);

    switch fileTypeIndex
        case 1
            [SheetNames,NumOfIndentsInFile,Calibration_ColNames,ListOfSheets] = NanoImport_General_Agilent(filename);
        case 2
            [NumOfIndentsInFile,Calibration_ColNames] = NanoImport_General_Bruker(filename);
    end
    
    if CurrFileNum == 1
        firstColNames = Calibration_ColNames;
    end
    
    if CurrFileNum == 1 || isequal(Calibration_ColNames,firstColNames) == false
        % This only happens if it is the first file loaded, or the column
        % headers do not match with the first file.
        % This allows the user to select what columns the indent
        % displacement is working and the load too.
        PromptString = 'Select the indent displacement:';
        DispCol = listdlg('ListString',Calibration_ColNames,'PromptString',PromptString,'SelectionMode','single');
        PromptString = 'Select the y-variable to plot:';
        YVariable = listdlg('ListString',Calibration_ColNames,'PromptString',PromptString,'SelectionMode','single');
        YVariableName = string(Calibration_ColNames{YVariable});
        fprintf('Calibrated importing data so the indent depth is col-%d, and y-variable is col-%d...\n',DispCol,YVariable);
    end
    
    Array_Values = nan(NumOfIndentsInFile,length(Calibration_ColNames));
    Array_Errors = nan(NumOfIndentsInFile,length(Calibration_ColNames));
    fprintf('Array_Values size = %d x %d\n',size(Array_Values,1),size(Array_Values,2));
    
    LoadBar = waitbar(0,'Started Importing Indents');
        
    % Want to add mass import
    for i = 1:NumOfIndentsInFile
        waitbar(i/NumOfIndentsInFile,LoadBar,sprintf('Working On Indent %d/%d',i,NumOfIndentsInFile));
        switch fileTypeIndex
            case 1
                % Agilent Method
                SheetNum = ListOfSheets(i);
                CurrIndentName = SheetNames(SheetNum);
                Current_Matrix = readmatrix(filename,'Sheet',SheetNum,'FileType','spreadsheet');
                clear SheetNum
            case 2
                % Bruker Method
                CurrIndentName = files(CurrFileNum);
                Current_Matrix = readmatrix(filename);
        end


        if isnan(Current_Matrix) == true
            DLG = warndlg(sprintf('This sheet called "%s" is empty, and hence will be skipped...',CurrIndentName));
            waitfor(DLG);
            break
        end
        %% Meaning
        
        [~,index_min] = min(abs(Current_Matrix(:,DispCol)-Depth_Min));
        [~,index_max] = min(abs(Current_Matrix(:,DispCol)-Depth_Max));
        
        Array_Values(i,:) = mean(Current_Matrix(index_min:index_max,:),1);
        Array_Errors(i,:) = std(Current_Matrix(index_min:index_max,:),0,1);
        clear Current_Matrix
    end
    close(LoadBar);
    %% Plotting
    close all
    XDataCol = DispCol;
    varNames = string(Calibration_ColNames);
    w = 0;
    ErrorPlotMode = 'Standard deviation';
    method_name = 'SummariseArray';

    SF = 0.6;
    
    ValueData = Array_Values;
    ErrorData = Array_Errors;

%     clear Array_Values Array_Errors

    x_data = (1:1:NumXIndents)*XIndents_Space;

    % Removing Columns with NaN
    [ValueData,XDataCol,idx] = f_RemoveNaNColumns(ValueData,XDataCol);
    ErrorData(:,idx) = [];
    varNames(:,idx) = [];
    disp('Removed columns of just NaN...');
    YDataCol = find(varNames==YVariableName, 1);
    
    ValueData_smoothed = smoothdata(ValueData,1,'rlowess','SmoothingFactor',SF);
    ErrorData_smoothed = smoothdata(ErrorData,1,'rlowess','SmoothingFactor',SF);

    NumYIndents = ceil(NumOfIndentsInFile/NumXIndents);

    SummarisedArray = []; %nan(NumXIndents,size(ValueData,2),NumYIndents);

    ILP = figure('Name','Individual Line Plot');
    ICP = figure('Name','Individual Colour Plot');
    
    for j=1:NumYIndents
        y_pos = (j-1)*YIndents_Space;
        y_pos_array = ones(NumXIndents,1)*y_pos;
        DisplayName = sprintf('@ y = %d %s',y_pos,YIndents_Units);
        Range = (1+((j-1)*60)):1:(j*60);
        if max(Range) > size(ValueData,1)
            Range = (1+((j-1)*60)):1:size(ValueData,1);
        end
        y_data = ValueData(Range,YDataCol);
        y_data_smoothed = ValueData_smoothed(Range,YDataCol);
        if rem(j, 2) ~= 0 %If odd
            figure(ILP);
            P = plot(x_data, y_data,'x','DisplayName',DisplayName);
            Color = P.Color;
            hold on
            plot(x_data, y_data_smoothed,'-','DisplayName',DisplayName,'Color',Color);
            
            figure(ICP);
            ColorLinePlot(x_data,y_pos_array,y_data)
            
            DataForSummarisedArray = ValueData(Range,:);
        else %If even
            figure(ILP);
            P = plot(x_data, flipud(y_data),'x','DisplayName',DisplayName);
            Color = P.Color;
            hold on
            plot(x_data, flipud(y_data),'-','DisplayName',DisplayName,'Color',Color);
            
            figure(ICP);
            ColorLinePlot(x_data,y_pos_array,flipud(y_data))
            
            DataForSummarisedArray = flipud(ValueData(Range,:));
        end
        hold on
        SummarisedArray = cat(3,SummarisedArray,DataForSummarisedArray);
    end
    
    figure(ICP);
    daspect([1 1 1]);
    
    figure(ILP);
    legend();
    plotLabels(sprintf('Seperate Lines - Smoothing Factor of %.1f',SF),sprintf('x-distance (%s)',XIndents_Units),varNames(YDataCol));
    ylims = ylim;

    Name_split = split(files(CurrFileNum),'.');
    FileIDName = sprintf('SummArrayAll__%s_%s',Name_split(1),CurrIndentName);
    NanoImport_Saving(debugON,ValueData,ErrorData,w,ErrorPlotMode,varNames,XDataCol,method_name,cd_init,SavingLocYN,cd_save,SavingData,FileIDName); % dataToSave

    %% Mean Of All Lines
    figure('Name','Combined Lines','WindowState','Maximized');
    SF = 0.7;
    SummarisedArray_Mean = smoothdata(mean(SummarisedArray,3),1,'rlowess','SmoothingFactor',0);
    SummarisedArray_Mean_Smoothed = smoothdata(mean(SummarisedArray,3),1,'rlowess','SmoothingFactor',SF);
    plot(x_data, SummarisedArray_Mean(:,YDataCol),'x','DisplayName','Mean Across All Lines');
    hold on
    
    plot(x_data, SummarisedArray_Mean_Smoothed(:,YDataCol),'-','DisplayName','Smoothed');
    plotLabels(sprintf('Combined Lines - Smoothing Factor of %.1f',SF),sprintf('x-distance (%s)',XIndents_Units),varNames(YDataCol));
    legend();
    ylim(ylims);

    % Color Plot
    figure('Name','Color Line');
    ColorLinePlot(x_data,ones(60,1)*0.2,SummarisedArray_Mean(:,YDataCol));
    
%     figure('Name','Color Line Smoothed');
%     ColorLinePlot(x_data,ones(60,1)*0.8,SummarisedArray_Mean_Smoothed(:,YDataCol));
    
    ylim([0,1]);
    
    Name_split = split(files(CurrFileNum),'.');
    FileIDName = sprintf('SummArrayMean__%s_%s',Name_split(1),CurrIndentName);
    NanoImport_Saving(debugON,SummarisedArray_Mean,ErrorData,w,ErrorPlotMode,varNames,XDataCol,method_name,cd_init,SavingLocYN,cd_save,SavingData,FileIDName); % dataToSave

    FileIDName = sprintf('SummArrayMeanSmooth__%s_%s',Name_split(1),CurrIndentName);
    NanoImport_Saving(debugON,SummarisedArray_Mean_Smoothed,ErrorData,w,ErrorPlotMode,varNames,XDataCol,method_name,cd_init,SavingLocYN,cd_save,SavingData,FileIDName); % dataToSave
    
    %%
    figure('Name','Normalised Multiple Parameters');
    array2Use = normalize(SummarisedArray_Mean(:,:));
    plot(x_data, array2Use(:,5),'-','DisplayName','Hardness');
    plotLabels('Combined Lines',sprintf('x-distance (%s)',XIndents_Units),'Normalised Parameter (Unitless)');
    hold on
    plot(x_data, array2Use(:,6),'-','DisplayName',"Young's Modulus");
    plot(x_data, array2Use(:,4),'-','DisplayName',"HCS");
    YLINE = yline(0,'k');
    set(get(get(YLINE,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); %Does not plot it on legend
    legend();
    ylims2 = ylim();
    
    figure('Name','Smoothed Normalised Multiple Parameters');
    array2Use = normalize(SummarisedArray_Mean_Smoothed(:,:));
    plot(x_data, array2Use(:,5),'-','DisplayName','Hardness');
    plotLabels('Combined Lines',sprintf('x-distance (%s)',XIndents_Units),'Normalised Parameter (Unitless)');
    hold on
    plot(x_data, array2Use(:,6),'-','DisplayName',"Young's Modulus");
    plot(x_data, array2Use(:,4),'-','DisplayName',"HCS");
    YLINE = yline(0,'k');
    set(get(get(YLINE,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); %Does not plot it on legend
    legend();
    ylim(ylims2);
end


fprintf('%s: Completed!\n\n',dlg_title);
end

%% InBuilt Functions

function plotLabels(titleLabel,xLabel,yLabel)
    title(titleLabel);
    xlabel(xLabel);
    ylabel(yLabel);
end

function FileIDName = f_i_agilentfilenamegen(ListOfSheets,i,SheetNames,filename)
    disp('Agilent for auto save name');
    SheetNum = ListOfSheets(i);
    CurrIndentName = SheetNames(SheetNum);
    FileIDName = sprintf('Agi_RawData__%s_%s',filename,CurrIndentName);
end

function ColorLinePlot(x_pos,y_pos,values)
    sz = 25;
    c = values; %(values-min(ReferenceColorData))./max(ReferenceColorData);
    scatter(x_pos,y_pos,sz,c,'filled');
    hold on
    colorbar;
end