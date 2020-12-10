%% NanoImport_General_Bruker
% By Robert J Scales
%
% Currently this code only takes bins up to the maximum indent depth (i.e.
% the loading up path, and not the unloading stage; as this give me a
% headache trying to sort it out for both directions).
%
% Attempting to make it do loading and unloading

function [NumOfIndentsInFile,Calibration_ColNames] = NanoImport_General_Bruker(filename)
%% Testing Initialisation
dlg_title = mfilename;
fprintf('%s: Started!\n\n',dlg_title);

[SelfTF,STLength] = ifcalled;

if SelfTF == true
    debugON = true;
    disp(STLength);
else
    debugON = false;
end

currMatrix = readtable(filename,'VariableNamingRule','preserve');
Calibration_ColNames = currMatrix.Properties.VariableNames;
NumOfIndentsInFile = 1;

end