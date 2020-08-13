%% getFileCompiler

function [NoOfSamples,fileNameList,file] = getFileCompiler(debugON,path,file)

    filename = string(fullfile(path,file));

    if isa(file,'double') == true
        PopUp = errordlg('No file selected! Code terminated!');
        NoOfSamples = nan; fileNameList = nan;
        waitfor(PopUp);
        return
    end

    % If one file is chosen its file type will be char and not cell, hence
    % this makes it into a 1x1 cell if true.
    if isa(file,'char') == true
        file = cellstr(file);
    end

    file = string(file);
    NoOfSamples = size(file,2);

    % This prepares a string array to be filled in with the full filenames
    % and the name the user wished to label the data with.
    fileNameList = strings(NoOfSamples,2);
    fileNameList(:,2) = transpose(string(filename));

    if debugON == true
        fprintf("Loading from '%s'\n",path);
        fprintf('Number of files loaded = %d\n',NoOfSamples);
        disp('function getFileCompiler completed...');
    end

end