%% NanoMachineImport_first_stage

function [w,ProgressBar,waitTime] = NanoMachineImport_first_stage(title,StdDevWeightingMode,IDName)
    
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
    
    message = sprintf('%s: Setting up',IDName);
    ProgressBar = waitbar(0,message);
    
    waitTime = 1;
    
end