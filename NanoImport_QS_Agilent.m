%% NanoImport_Agilent_General
% By Robert J Scales
% Because the Agilent data is exported as Excel spreadsheets which have
% multiple indent data stored in them. Then in order to mean across
% multiple arrays of indents made you have to load the data from multiple
% files. Bruker has the data from each indent as a singular file. Hence,
% this process is not needed.

function NanoImport_QS_Agilent(debugON)
%% Starting Up
dlg_title = 'NanoImport_QS_Agilent';
fprintf('%s: Started!\n\n',dlg_title);

testTF = false;

if testTF == true
    clc;
    WARN = warndlg(sprintf('Currently in testing mode for %s!!',dlg_title));
    waitfor(WARN);
    debugON = true;
    clearvars('-except','dlg_title','debugON','bins','w','ErrorPlotMode','mode');
end

cd_init = cd; % Initial directory
waitTime = 2; % The time spent on each figure.


% This gets the file data for the sample.
[file,path] = uigetfile({'*.xlsx;*.xls'},'Select QS Agilent nanoindentation Excel file to import:','MultiSelect','on');
cd_load = path;
% Below uses the file and path data above and produces it into the correct
% format, along with producing other useful data.
[NoOfFiles,fileNameList,file] = getFileCompiler(debugON,path,file);
if isnan(NoOfFiles) == true
    return
end

%% Importing Data 01

for CurrFileNum=1:NoOfFiles
    filename = fileNameList(CurrFileNum,2);
    SheetNames = sheetnames(filename); % This is a list of all of the sheet names for that spreadsheet file.

    % This accesses the first sheet named 'Results' otherwise 
    try
        opts_Sheet1 = detectImportOptions(filename,'Sheet','Results','FileType','spreadsheet','PreserveVariableNames',true);
        Table_Sheet1 = readtable(filename,opts_Sheet1);
        AutoLoadingON = true;
        NumOfSheets = length(SheetNames);
        % NumOfDataSheets = isfinite(table2array(Table_Sheet1(1:end-3,2)));
        ListOfSheets = 4:(NumOfSheets-1);
        clear NumOfSheets
    catch
        warndlg(sprintf('Sheet named "Results" not found!\nUser will have to manually select all sheets with data!'));
        AutoLoadingON = false;
        %ListOfSheets = NanoImport_SheetSelector(SheetNames);
        PromptString = 'Select the sheets which contain the cantilever data';
        ListOfSheets = listdlg('ListString',cellstr(SheetNames),'PromptString',PromptString,'SelectionMode','multiple','Name',code_title);
    end

    ListOfSheetNames = SheetNames(ListOfSheets); % This stores the names of the sheets which have been selected to be analysed.


    %% Importing Data 02
    close all
    clc
    NumOfIndents = length(ListOfSheets);

    SheetNum = ListOfSheets(1);
    %Table_Sheet = readmatrix(filename,'Sheet',SheetName,'FileType','spreadsheet','Range',SheetRange,'NumHeaderLines',2,'OutputType','double','ExpectedNumVariables',NoColsOfData);
    %  Calibration_Sheet = readtable(filename,'Sheet',SheetNum,'FileType','spreadsheet');
    Calibration_ColNamesA = detectImportOptions(filename,'Sheet',SheetNum,'FileType','spreadsheet','NumHeaderLines',0).VariableNames;
    Calibration_ColNamesB = detectImportOptions(filename,'Sheet',SheetNum,'FileType','spreadsheet','NumHeaderLines',1).VariableNames;
    Calibration_ColNames = join([Calibration_ColNamesA;Calibration_ColNamesB],1);
    clear Calibration_ColNamesA Calibration_ColNamesB

    PromptString = 'Select the indent displacement:';
    DispCol = listdlg('ListString',Calibration_ColNames,'PromptString',PromptString,'SelectionMode','single');
    PromptString = 'Select the indent load:';
    LoadCol = listdlg('ListString',Calibration_ColNames,'PromptString',PromptString,'SelectionMode','single');
    fprintf('Calibrated importing data so the indent depth is col-%d, and indent load is col-%d...\n',DispCol,LoadCol);

    for i = 1:NumOfIndents
        ImportingFigure = figure('Name','ImpFig','WindowState','Maximized');
        SheetNum = ListOfSheets(i);
        CurrIndentName = SheetNames(SheetNum);
        ylabel(Calibration_ColNames(LoadCol));
        xlabel(Calibration_ColNames(DispCol));
        title(sprintf('Current Sample: %s',CurrIndentName));
        Current_Matrix = readmatrix(filename,'Sheet',SheetNum,'FileType','spreadsheet');

        if isnan(Current_Matrix) == true
            DLG = warndlg(sprintf('This sheet called "%s" is empty, and hence will be skipped...',CurrIndentName));
            waitfor(DLG);
            close(ImportingFigure);
            break
        end
        

        LoadDisp = plot(Current_Matrix(:,DispCol),Current_Matrix(:,LoadCol));
        hold on
        
        AnalyseIndentYN = questdlg('Do you want to analyse this indent?','Choosing Data','Yes','No','Yes');
        if strcmp(AnalyseIndentYN,'No') == true
            close(ImportingFigure);
            continue
        end


        PlotGradientsON = false;
        if PlotGradientsON == true
            % Gradient = gradient(Current_Matrix(:,DispCol),Current_Matrix(:,LoadCol));
            % plot(Current_Matrix(:,DispCol),Gradient);
            % Gradient2 = gradient(Gradient);
            plot(Gradient,'-x');
        end

        Gradient = gradient(Current_Matrix(:,DispCol));
        Recommended_StartPoint = find(0<Gradient & Gradient<0.1,1); % Finds the first point for which the displacement is first increasing by 0.1 units per row, this is to counteract if it goes reverse.
        %Recommended_StartPoint = find(Current_Matrix(:,LoadCol)>0.06,1); % Finds the point for which the load is first above 0.06 mN.
        hold on
        StartPoint_Plot = plot(Current_Matrix(Recommended_StartPoint,DispCol),Current_Matrix(Recommended_StartPoint,LoadCol),'rx','MarkerSize',20);
        % datatip(LoadDisp,'DataIndex',Recommended_StartPoint)

        Question = 'Want to use the recommended origin point?';
        Question_title = 'Clipping The Data';
        UseAutoClipON = questdlg(Question,Question_title,'Yes','Manually Choose','Leave Alone','Yes');

    %     if strcmp(UseAutoClipON,'Manually Choose') == true
    %         [x_point,~] = ginput(1);
    %         [~,Recommended_StartPoint] = min(abs( x_point - Current_Matrix(:,DispCol) ));
    %         disp(Recommended_StartPoint);
    %     end

        switch UseAutoClipON
            case 'Manually Choose'
                [x_point,~] = ginput(1);
                [~,Recommended_StartPoint] = min(abs( x_point - Current_Matrix(:,DispCol) ));
                %disp(Recommended_StartPoint);
                Rec_StartPoint_XY = [Current_Matrix(Recommended_StartPoint,1),Current_Matrix(Recommended_StartPoint,2)];
            case 'Leave Alone'
                Recommended_StartPoint = 1;
                Rec_StartPoint_XY = [0,0];
            case 'Yes'
                Rec_StartPoint_XY = [Current_Matrix(Recommended_StartPoint,1),Current_Matrix(Recommended_StartPoint,2)];
        end

        delete(LoadDisp);
        delete(StartPoint_Plot);

        Current_Matrix = Current_Matrix(Recommended_StartPoint:end,:);
        Current_Matrix(:,1) = Current_Matrix(:,1)-Rec_StartPoint_XY(1);
        Current_Matrix(:,2) = Current_Matrix(:,2)-Rec_StartPoint_XY(2);

        LoadDisp = plot(Current_Matrix(:,DispCol),Current_Matrix(:,LoadCol));
        hold on

        ylabel(Calibration_ColNames(LoadCol));
        xlabel(Calibration_ColNames(DispCol));
        title(sprintf('Current Sample: %s',CurrIndentName));

        ValueData = Current_Matrix;
        ErrorData = nan(size(Current_Matrix));
        w = 0;
        ErrorPlotMode = 'Standard deviation';
        varNames = string(Calibration_ColNames);
        XDataCol = DispCol;
        method_name = 'Agilent-QS';

        % Saving Section
        [dataToSave] = NanoImport_Saving(debugON,ValueData,ErrorData,w,ErrorPlotMode,varNames,XDataCol,method_name,cd_init,cd_load); % dataToSave
        close(ImportingFigure);
    end

end
%%

fprintf('%s: Completed!\n\n',dlg_title);
end

%% InBuilt Functions

%% Development Plan

    % Things left to do
    % #1 Comment on what I have done
    % #1A Try find peaks to see if the last +ve peak will be reasonably
    % found and if that gives good results.
    % #2 Add in a feature so that it converts the data from the sheets into
    % Matlab table form and then those can be saved individually for each
    % indent.
    % Once that is done, have a feature so that the data can be analysed.
    % Like what Chris Magazzeni wanted and also for what I want to do
    % (obtain stiffness).
