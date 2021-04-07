%% NanoImport_SummariseArray
% By Robert J Scales

function NanoImport_SummariseArray
%% Settings
close all
clear
clc
old_path = addpath('./Analyse/','./Import/','./Plotter/');
set(0, 'DefaultLineLineWidth', 2);

Depth_Min = 300;
Depth_Max = 500;

NumXIndents = 60;

XIndents_Space = 10;
XIndents_Units = 'um';

YIndents_Space = 100;
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
        fprintf('Calibrated importing data so the indent depth is col-%d, and y-variable is col-%d...\n',DispCol,YVariable);
    end
    
    Array_Values = nan(NumOfIndentsInFile,1);
    Array_Errors = nan(NumOfIndentsInFile,1);
    
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
        
        x_column = Current_Matrix(:,DispCol);
        y_column = Current_Matrix(:,YVariable);
        
        [~,index_min] = min(abs(x_column-Depth_Min));
        [~,index_max] = min(abs(x_column-Depth_Max));
        
        Mean_Value = mean(y_column(index_min:index_max));
        Mean_Error = std(y_column(index_min:index_max));
        
        clear Current_Matrix x_column y_column
        
        Array_Values(i,1) = Mean_Value;
        Array_Errors(i,1) = Mean_Error;
        clear Mean_Value Mean_Error
    end
    close(LoadBar);
    %% Plotting
%     XDataCol = DispCol;
%     varNames = string(Calibration_ColNames);
%     w = 0;
%     ErrorPlotMode = 'Standard deviation';
%     method_name = 'SummariseArray';

    ValueData = smoothdata(Array_Values);
    ErrorData = Array_Errors;

%     clear Array_Values Array_Errors
    
%     Name_split = split(filename,'.');
%     FileIDName = sprintf('SummArray__%s_%s',Name_split(1),CurrIndentName);

    x_data = (1:1:NumXIndents)*XIndents_Space;

    NumYIndents = ceil(NumOfIndentsInFile/NumXIndents);
    for j=1:NumYIndents
        DisplayName = sprintf('@ y = %d %s',(j-1)*YIndents_Space,YIndents_Units);
        Range = (1+((j-1)*60)):1:(j*60);
        if max(Range) > size(ValueData,1)
            Range = (1+((j-1)*60)):1:size(ValueData,1);
        end
        if rem(j, 2) ~= 0
            %If odd
            plot(x_data, ValueData(Range),'DisplayName',DisplayName);
        else
            %If even
            plot(x_data, flipud(ValueData(Range)),'DisplayName',DisplayName);
        end
        hold on
    end
    legend();
    plotLabels('Figure Title',sprintf('x-distance (%s)',XIndents_Units),Calibration_ColNames(YVariable));
%     NanoImport_Saving(debugON,ValueData,ErrorData,w,ErrorPlotMode,varNames,XDataCol,method_name,cd_init,SavingLocYN,cd_save,SavingData,FileIDName); % dataToSave
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

