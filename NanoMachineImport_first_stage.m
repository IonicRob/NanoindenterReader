%% NanoMachineImport_first_stage

function [ProgressBar,IDName] = NanoMachineImport_first_stage(title,file)
    
    fprintf('%s: Started!\n',title);
    
%     HeadingName = sprintf('Enter name for nanoindentation data titled "%s":',file);
%     IDName = string(inputdlg({HeadingName},'Type data name here:',[1,100]));
%     if strcmp(IDName,"")
%         errordlg('No sample ID name entered! Code will terminate!')
%         return
%     end
    IDName = file;
    
    message = sprintf('%s: Setting up',IDName);
    ProgressBar = waitbar(0,message);
    
end