%% NanoMachineImport_first_stage

function [ProgressBar,IDName] = NanoMachineImport_first_stage(file)
    
    IDName = file; % This becomes the ID for the loaded sample.
    
    message = sprintf('%s: Setting up',IDName);
    ProgressBar = waitbar(0,message); % Creates the progress bar.
    
end