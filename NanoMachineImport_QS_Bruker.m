%% NanoMachineImport_QS_Bruker
% By Robert J Scales

function NanoMachineImport_QS_Bruker
%%
    fprintf('NanoMachineImport_QS_Bruker: Started!\n');
    LOC_init = cd;
    title = 'NanoMachineImport_QS_Bruker';
    
    % This allows to get the file name and location information for
    % multiple files, starting from the load location.
    msg = 'Select the ".txt" files for each of the indents to be imported';
    PopUp = helpdlg(msg,title);
    waitfor(PopUp);
    [file,path] = uigetfile({'*.txt'},'Select nanoindentation txt files for all the indents to import:','MultiSelect','on');
    
    if isa(file,'double') == true
        errordlg('No files selected! Code will terminate!')
        return
    end
    
%     LOC_load = path;
    
    % If one file is chosen its file type will be char and not cell, hence
    % this makes it into a 1x1 cell if true.
    if isa(file,'char') == true
        file = cellstr(file);
    end
    
    % This calculates the number of samples the user has chosen based on
    % the number of files chosen.
    NumberOfIndents = length(file);
    
    MaxIndentDepth = nan;
    
    MasterTable = cell(NumberOfIndents,1);
    
    % This fills in fileNameList
    for i =1:NumberOfIndents
        fprintf('Current file loaded = %s\n',file{i});
        filename = fullfile(path,file{i});
        opts = detectImportOptions(filename,'VariableNamesLine',6,'Encoding','windows-1252','ExpectedNumVariables',5,'PreserveVariableNames',true);
%         currTable = readtable(filename,opts);
        currMatrix = readmatrix(filename,opts);
        NumOfRows = size(currMatrix,1);
        Depth = currMatrix(:,1); % Depth in nm which is good.
        Load = currMatrix(:,2)*1000; % Load is converted from uN to mN!
        Time = currMatrix(:,3); % Time in s which is good.
        HCS = nan(NumOfRows,1); % Fake HCS column.
        H = nan(NumOfRows,1); % Fake hardness column.
        E = nan(NumOfRows,1); % Fake Youngs modulus column.
        currMaxIndentDepth = max(Depth);
        fprintf('\tMax depth in file loaded = %gnm\n',currMaxIndentDepth);
        MaxIndentDepth = max([currMaxIndentDepth,MaxIndentDepth]);
        OutputTable = MakeTableForIndent(Depth,Load,Time,HCS,E);
        MasterTable{i} = OutputTable;
    end
    
    cd(LOC_init)
    fprintf('NanoMachineImport_QS_Bruker: Complete!\n');
end

%% Functions

function OutputTable = MakeTableForIndent(Depth,Load,Time,HCS,E)
    OutputTable = table(Depth,Load,Time,HCS,E);
    OutputTable
end