%% NanoImport_General_Agilent
% By Robert J Scales

function [SheetNames,NumOfIndentsInFile,Calibration_ColNames,ListOfSheets] = NanoImport_General_Agilent(filename)
%% Starting Up
dlg_title = mfilename;
fprintf('%s: Started!\n\n',dlg_title);

[SelfTF,STLength] = ifcalled;
if SelfTF == true
    debugON = true;
    disp(STLength)
else
    debugON = false;
end

%% Main Part

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

NumOfIndentsInFile = length(ListOfSheets);

SheetNum = ListOfSheets(1);
%Table_Sheet = readmatrix(filename,'Sheet',SheetName,'FileType','spreadsheet','Range',SheetRange,'NumHeaderLines',2,'OutputType','double','ExpectedNumVariables',NoColsOfData);
%  Calibration_Sheet = readtable(filename,'Sheet',SheetNum,'FileType','spreadsheet');
Calibration_ColNamesA = detectImportOptions(filename,'Sheet',SheetNum,'FileType','spreadsheet','NumHeaderLines',0).VariableNames;
Calibration_ColNamesB = detectImportOptions(filename,'Sheet',SheetNum,'FileType','spreadsheet','NumHeaderLines',1).VariableNames;
Calibration_ColNames = join([Calibration_ColNamesA;Calibration_ColNamesB],1);
if debugON == false
    clear Calibration_ColNamesA Calibration_ColNamesB
end

fprintf('%s: Completed!\n\n',dlg_title);
end
