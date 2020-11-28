%% NanoImport_QS_Bruker
% By Robert J Scales
%
% Currently this code only takes bins up to the maximum indent depth (i.e.
% the loading up path, and not the unloading stage; as this give me a
% headache trying to sort it out for both directions).
%
% Attempting to make it do loading and unloading

function [SheetNames,NumOfIndentsInFile,Calibration_ColNames,ListOfSheets] = NanoImport_General_QS(filename)
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

LoadedFile = readtable()
end

%% Functions

function [SelfTF,STLength] = ifcalled
    % dbstack() describes what functions are being called.
    ST = dbstack();
    STLength = length(ST);
    if STLength > 2
        % The below happens if this is being called from another function.
        PopUp = helpdlg('Function is detected as NOT running by itself.');
        waitfor(PopUp);
        SelfTF =  false;
    else
        % The below happens if this function is being run by itself.
        PopUp = helpdlg('Function is detected as running by itself.');
        waitfor(PopUp);
        SelfTF = true;
    end
end