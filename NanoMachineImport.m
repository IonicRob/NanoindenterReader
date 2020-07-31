%% NanoMachineImport
% By Robert J Scales
% The objective of this code is to choose which machine the data you want
% to import is from. If it is produced from the Aglient software (e.g. XP
% or G200) then no changes will be made. However, if it is from another
% known machine it will convert it into a spreadsheet file of the correct
% format for NanaoDataCreater.

% Quasistandard trapezoid method

function OutPut = NanoMachineImport(bins,StdDevWeightingMode,debugON)
    
    title = 'NanoMachineImport';

    ValidMethodList = {'CSM Agilent','QS Bruker','Other','Help'};
    PromptString = {'Select the type method/system to import:','Only one type can be selected at a time.'};
    [ChosenMethod,~] = listdlg('PromptString',PromptString,'SelectionMode','single','ListString',ValidMethodList);
    if isempty(ChosenMethod) == false
        ChosenMethod = ValidMethodList{ChosenMethod};
    else
        msg = {'No method/system was chosen!','Code will terminate!'};
        PopUpMsg(msg,title,'Error','Exit')
    end
    
    if strcmp(ChosenMethod,'Help')
        msg = {'Method selection list legend:','CSM = Continuous Stiffness Measurement','QS = Quasi-standard Trapezoid'};
        PopUpMsg(msg,title,'Help','Restart')
    elseif strcmp(ChosenMethod,'Other')
        msg = {'Sorry but this method/system is not yet supported by this code!','Help contribute to the this code GitHub to add support for your method/system!'};
        PopUpMsg(msg,title,'Error','Exit')
    else
        disp('Code will continue...')
    end
    
    switch ChosenMethod
        case 'CSM Agilent'
            OutPut = NanoMachineImport_CSM_Agilent(bins,StdDevWeightingMode,debugON);
        case 'QS Bruker'
            OutPut = NanoMachineImport_QS_Bruker(bins,StdDevWeightingMode,debugON);
    end
    
end

%% Functions

function PopUpMsg(msg,title,ErrorOrHelp,ExitOrRestart)
    switch ErrorOrHelp
        case 'Error'
            PopUp = errordlg(msg,title);
        case 'Help'
            PopUp = helpdlg(msg,title);
    end
    switch ExitOrRestart
        case 'Exit'
            waitfor(PopUp);
            return
        case 'Restart'
            waitfor(PopUp);
            NanoMachineImport
    end
end