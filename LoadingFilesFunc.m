%% LoadingFilesFunc by R J Scales

function [FileStuctures,fileNameList,LOC_load] = LoadingFilesFunc(debugON,MultiselectONOFF)

    % This allows to get the file name and location information for
    % multiple files.
    [file,path] = uigetfile('*.mat','Select nanoindentation "mat" files made by "NanoImport" to plot (must all be in one folder):','MultiSelect',MultiselectONOFF);

    % If no file is selected then the output of the above is an empty
    % double.
    if isa(file,'double') == true
        errordlg('No files selected! Code will terminate!')
        return
    end
    
    % The loading path is specified by where the files are loaded from.
    LOC_load = path;
    
    % If one file is chosen its file type will be char and not cell, hence
    % this makes it into a 1x1 cell if true.
    if isa(file,'char') == true
        file = cellstr(file);
    end
    
    % This calculates the number of samples the user has chosen based on
    % the number of files chosen.
    NumberOfFiles = length(file);

    if debugON == true
        fprintf('Loading files from "%s"...\n',LOC_load);
        fprintf('Number of files detected = %d\n',NumberOfFiles);
    end
    
    % This prepares a string array to be filled in with the full filenames
    % and the name the user wished to label the data with.
    fileNameList = strings(NumberOfFiles,2);
    FileStuctures = cell(NumberOfFiles,1);
    
    % This fills in fileNameList
    for i =1:NumberOfFiles
        filename = fullfile(path,file{i});
        fileNameList(i,1) = file{i};
        fileNameList(i,2) = filename;
        FileStucturesProto = load(filename,'-mat');
        FileStuctures{i} = FileStucturesProto.dataToSave;
        if debugON == true
            fprintf('Loaded file named "%s"\n',file{i});
        end
    end
end