%% NanoMachineImport_first_stage

function [w,ProgressBar,waitTime,IDName] = NanoMachineImport_first_stage(title,StdDevWeightingMode,file)
    
    fprintf('%s: Started!\n',title);
        
    switch StdDevWeightingMode
        case 'N-1'
            w = 0;
        case 'N'
            w = 1;
        case 'Using bin errors'
            w = 0; % Need to update this!!
        case ''
            w = 0;
    end
    
    HeadingName = sprintf('Enter name for nanoindentation data titled "%s":',file);
    IDName = string(inputdlg({HeadingName},'Type sample name here:',[1,100]));
    if strcmp(IDName,"")
        errordlg('No sample ID name entered! Code will terminate!')
        return
    end
    
    message = sprintf('%s: Setting up',IDName);
    ProgressBar = waitbar(0,message);
    
    waitTime = 1;
    
end