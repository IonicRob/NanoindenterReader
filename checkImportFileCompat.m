% Following on from above, the if this check is not done then we are
% mixing data with different error analysis.
% The variable names is dependent on the method and machine, and this
% check is done because currently the code is limited with capability.
% May impliment an advanced plotter which the user has to select the
% column for a specific data type to plot.
function passTF = checkImportFileCompat(debugON,FileStuctures)
    NumLoaded = length(FileStuctures);

    if debugON == true
        fprintf('FileStuctures has length of %d...\n',NumLoaded);
    end
        
    varNames_all_same = true;
    first_varNames = FileStuctures{1}.varNames;
    
    for i = 1:NumLoaded
        current_varNames = FileStuctures{i}.varNames;
        if strcmp(char(current_varNames),char(first_varNames)) == false
            varNames_all_same = false;
        end
    end
    
    if (varNames_all_same == false)
        Message = cell(3,1);
        Message{1} = sprintf('The files loaded have something not the same (i.e. "false"): \n');
        Message{2} = sprintf(' - variable names (varNames) = %s \n', logical2String(varNames_all_same));
        DLG = warndlg(Message);
        waitfor(DLG);
        passTF = false;
%         return
    else
        passTF = true;
    end
    
end