%% NanoImport_Agilent_General
% By Robert J Scales
% Because the Agilent data is exported as Excel spreadsheets which have
% multiple indent data stored in them. Then in order to mean across
% multiple arrays of indents made you have to load the data from multiple
% files. Bruker has the data from each indent as a singular file. Hence,
% this process is not needed.

function NanoImport_QS_Agilent(debugON,bins,w,ErrorPlotMode,mode)
%% Starting Up
dlg_title = 'NanoImport_Agilent_General';
fprintf('%s: Started!\n\n',dlg_title);

testTF = true;

if testTF == true
    clc;
    WARN = warndlg('Currently in testing mode for NanoImport_Agilent_General!!');
    waitfor(WARN);
    debugON = true;
    bins = 100;
    w = 0; % 'N-1' weighting for stdev
    ErrorPlotMode = 'Standard deviation';
    mode = 'qs'; % Testing mode is defined in here
    clearvars('-except','dlg_title','debugON','bins','w','ErrorPlotMode','mode');
end

cd_init = cd; % Initial directory
waitTime = 2; % The time spent on each figure.

% Configs the code based on whether the data to import is CSM or QS
switch mode
    case 'qs'
        NoYCols = 7-1;
        XDataCol = 2;
        varNames = {'Depth (nm)','Time (s)','Load (uN)','X Pos (um)','Y Pos (um)','Raw Displacement (nm)','Raw Load (mN)'};
    otherwise
        DLG = errordlg('Unknown case for "mode" chosen for "%s"\n Value will be printed below...\n',dlg_title);
        waitfor(DLG);
        return
end


% This gets the file data for the sample.
[file,path] = uigetfile({'*.xlsx;*.xls'},'Select QS Agilent nanoindentation Excel file to import:','MultiSelect','off');

% Below uses the file and path data above and produces it into the correct
% format, along with producing other useful data.
[NoOfSamples,fileNameList,file] = getFileCompiler(debugON,path,file);
if isnan(NoOfSamples) == true
    return
end

%% Importing Data 01

filename = fileNameList(1,2);

% This is a list of all of the sheet names for that spreadsheet file.
SheetNames = sheetnames(filename);

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
NumOfTests = length(ListOfSheets);

SheetNum = ListOfSheets(1);
%Table_Sheet = readmatrix(filename,'Sheet',SheetName,'FileType','spreadsheet','Range',SheetRange,'NumHeaderLines',2,'OutputType','double','ExpectedNumVariables',NoColsOfData);
% Calibration_Sheet = readtable(filename,'Sheet',SheetNum,'FileType','spreadsheet');
Calibration_ColNames = detectImportOptions(filename,'Sheet',SheetNum,'FileType','spreadsheet').VariableNames;
PromptString = 'Select the indent displacement:';
DispCol = listdlg('ListString',Calibration_ColNames,'PromptString',PromptString,'SelectionMode','single');
PromptString = 'Select the indent load:';
LoadCol = listdlg('ListString',Calibration_ColNames,'PromptString',PromptString,'SelectionMode','single');

for i = 1:length(ListOfSheets)
    SheetNum = ListOfSheets(i);
    Current_Matrix = readmatrix(filename,'Sheet',SheetNum,'FileType','spreadsheet');

    if isnan(Current_Matrix) == true
        DLG = warndlg(sprintf('This sheet called "%s" is "tagged", and hence will be skipped...',SheetNames(SheetNum)));
        waitfor(DLG);
        break
    end
    
    LoadDisp = plot(Current_Matrix(:,DispCol),Current_Matrix(:,LoadCol));
    hold on
    % Gradient = gradient(Current_Matrix(:,DispCol),Current_Matrix(:,LoadCol));
    % plot(Current_Matrix(:,DispCol),Gradient);
    Gradient = gradient(Current_Matrix(:,DispCol));
    % Gradient2 = gradient(Gradient);
    plot(Gradient,'-x');

    Recommended_StartPoint = find(0<Gradient & Gradient<0.1,1); % Finds the first point for which the displacement is first increasing by 0.1 units per row, this is to counteract if it goes reverse.
    %Recommended_StartPoint = find(Current_Matrix(:,LoadCol)>0.06,1); % Finds the point for which the load is first above 0.06 mN.
    hold on
    StartPoint_Plot = plot(Current_Matrix(Recommended_StartPoint,DispCol),Current_Matrix(Recommended_StartPoint,LoadCol),'rx','MarkerSize',20);
    % datatip(LoadDisp,'DataIndex',Recommended_StartPoint)

    Question = 'Want to use the recommended origin point?';
    Question_title = 'Clipping The Data';
    UseAutoClipON = questdlg(Question,Question_title,'Yes','No','Yes');

    if strcmp(UseAutoClipON,'No') == true
        [x_point,~] = ginput(1);
        [~,Recommended_StartPoint] = min(abs( x_point - Current_Matrix(:,DispCol) ));
        disp(Recommended_StartPoint);
    end
    
    delete(LoadDisp);
    delete(StartPoint_Plot);
    
    Rec_StartPoint_XY = [Current_Matrix(Recommended_StartPoint,1),Current_Matrix(Recommended_StartPoint,2)];
    Current_Matrix = Current_Matrix(Recommended_StartPoint:end,:);
    Current_Matrix(:,1) = Current_Matrix(:,1)-Rec_StartPoint_XY(1);
    Current_Matrix(:,2) = Current_Matrix(:,2)-Rec_StartPoint_XY(2);
    
    LoadDisp = plot(Current_Matrix(:,DispCol),Current_Matrix(:,LoadCol));
    hold on
    
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
    
end
%%

fprintf('%s: Completed!\n\n',dlg_title);
end

%% InBuilt Functions


