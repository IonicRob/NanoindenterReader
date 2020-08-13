%% Nanoindentation Data Creater
% Written by Robert J Scales

function NanoImport(debugON,DefaultDlg,USS)
    %% Basic Set-up

    % This is the title for notifications.
    dlg_title = 'NanoImport';
    fprintf('%s: Started!\n\n',dlg_title);
    

    % The below gives the option to clear white list the clearing of certain
    % variables and/or clear all preferences.
    NanoCreaterLoaderClearer(false,false);


    %% Settings

    % This next bit checks to see if 'SettingsDone' exists, if not then the
    % code hasn't been run before and so not previous settings exist.
    quest = {'Choose the settings choice mode:'};
    if logical(exist('SettingsDone','var'))
        pbnts = {'Dialogue Boxes','Use Scipt Settings','Use Previously Used Settings'};
    else
        pbnts = {'Dialogue Boxes','Use Scipt Settings'};
    end

    % The following chooses between using the USS settings in NanoMainCode or
    % whether you want to specify the settings via dialogue boxes.
    [SettingsViaDialogueYN,~] = uigetpref('Settings','Dialogue',dlg_title,quest,pbnts);
    switch SettingsViaDialogueYN
        case 'dialogue boxes'
            % The below function is used to make the main script shorter.
            [bins,w,ErrorPlotMode] = FormattingChoosing(DefaultDlg);
            % This creates 'SettingsDone' i.e. settings have been chosen.
            SettingsDone = true;
        case 'use scipt settings'
            % To alter these alter the values in USS in NanoMainCode.
            bins = USS.bins; w = USS.w; ErrorPlotMode = USS.ErrorPlotMode;
            SettingsDone = true;
        case 'Use Previously Used Settings'
            disp('Using previously used settings!');
    end

    if debugON
        disp('DEBUG ON');
        fprintf('bins = %s\n',string(bins));
        fprintf('w = %d\n',w);
        fprintf('ErrorPlotMode = %s\n',string(ErrorPlotMode));
        fprintf('SettingsDone = %s\n',string(SettingsDone));
    end


    %% Main Data Processing Section

        ValidMethodList = {'CSM Agilent','QS Agilent','QS Bruker','Other','Help'};
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
            fprintf('Valid method chosen!\n\n');
        end

        switch ChosenMethod
            case 'CSM Agilent'
                NanoImport_Agilent_CSM(debugON,bins,w,ErrorPlotMode)
            case 'QS Bruker'
                disp('NOT READY YET');
                return
            case 'QS Agilent'
                NanoImport_Agilent_QS(debugON,bins,w,ErrorPlotMode)
        end

end





%% Functions


% This allows the user to choose the settings via dialogue boxes.
function [bins,w,ErrorPlotMode] = FormattingChoosing(DefaultDlg)
    dlg_title = 'FormattingChoosing';
    
    % This is the number of bins which it will group the data along the
    % x-axis with.
    bins = str2double(inputdlg({'How many bins do you want to use'},dlg_title,[1,50]));

    % This is chosen for all other inputs apart from if no input is
    % chosen, as the data could then be later analysed and it
    % would be useful to have these settings chosen.

    % This is the weighting mode to do for the standard deviation
    % and standard error, see Matlab documentation on std.
    ErrorPlotMode = questdlg('Choose to show standard error or standard deviation:',dlg_title,'Standard error','Standard deviation',DefaultDlg.ErrorPlotMode);

    % This chooses whether the standard deviation or standard error
    % will be plotted as the y-uncertainties in the graphs.
    StdDevWeightingMode = questdlg('Choose the standard deviation weighting to use:',dlg_title,'N-1','N','Using bin errors',DefaultDlg.StdDevWeightingMode);
    % This is the standard deviation weighting mode.
    w = wGenerator(StdDevWeightingMode);

    if strcmp(ErrorPlotMode,'') == true
        warndlg('No error choice was made, hence default will be shown!');
    end
    if strcmp(StdDevWeightingMode,'') == true
        warndlg('No weighting choice was made, hence default will be chosen!');
    end
end

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




