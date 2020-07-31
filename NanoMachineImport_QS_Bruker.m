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
    
    
    % This fills in fileNameList
    for i =1:NumberOfIndents
        HeadingName = sprintf('Enter name for nanoindentation data titled "%s":',file{i});
        CurrName = inputdlg({HeadingName},'Type sample name here:',[1,100]);
        if ~isempty(CurrName)
            filename = fullfile(path,file{i});
            opts = detectImportOptions(filename,'VariableNamesLine',6,'Encoding','windows-1252','ExpectedNumVariables',5,'PreserveVariableNames',true);
            T = readtable(filename,opts);
        else
            errordlg('No name entered! Code will terminate!')
            return
        end
    end
    
    cd(LOC_init)
    fprintf('NanoMachineImport_QS_Bruker: Complete!\n');
end