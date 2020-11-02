%% Nanoindentation Data Creater
% Written by Robert J Scales

function NanoImport(debugON,DefaultDlg,USS)
    %% Basic Set-up

    % This is the title for notifications.
    dlg_title = 'NanoImport';
    fprintf('%s: Started!\n\n',dlg_title);

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
            [bins,w,ErrorPlotMode] = FormattingChoosing(DefaultDlg,USS);
            % This creates 'SettingsDone' i.e. settings have been chosen.
            SettingsDone = true;
        case 'use scipt settings'
            % To alter these alter the values in USS in NanoMainCode.
            bins = USS.bins;
            w = USS.w;
            ErrorPlotMode = USS.ErrorPlotMode;
            SettingsDone = true;
        case 'Use Previously Used Settings'
            disp('Using previously used settings!');
        otherwise
            PopUpMsg('Unexpected SettingsViaDialogueYN error!!',dlg_title,'Error','Exit')
            return
    end

    if debugON
        disp('DEBUG ON');
        fprintf('bins = %s\n',string(bins));
        fprintf('w = %d\n',w);
        fprintf('ErrorPlotMode = %s\n',string(ErrorPlotMode));
        fprintf('SettingsDone = %s\n',string(SettingsDone));
    end


    %% Main Data Processing Section
        MethodList = {'CSM Agilent','QS Agilent','QS Bruker','Other','Help'};
        PromptString = {'Select the type method/system to import:','Only one type can be selected at a time.'};
        [ChosenMethod,~] = listdlg('PromptString',PromptString,'SelectionMode','single','ListString',MethodList);
        if isempty(ChosenMethod) == false
            ChosenMethod = MethodList{ChosenMethod};
        else
            msg = {'No method/system was chosen!','Code will terminate!'};
            PopUpMsg(msg,dlg_title,'Error','Exit')
            return
        end

        if strcmp(ChosenMethod,'Help')
            msg = {'Method selection list legend:','CSM = Continuous Stiffness Measurement','QS = Quasi-standard Trapezoid'};
            PopUpMsg(msg,dlg_title,'Help','Exit')
        elseif strcmp(ChosenMethod,'Other')
            msg = {'Sorry but this method/system is not yet supported by this code!','Help contribute to the this code GitHub to add support for your method/system!'};
            PopUpMsg(msg,dlg_title,'Error','Exit')
        else
            fprintf('Valid method chosen!\n\n');
        end

        clear MethodList PromptString
        
        switch ChosenMethod
            case 'CSM Agilent'
                mode = 'csm';
                NanoImport_Agilent_General(debugON,bins,w,ErrorPlotMode,mode)
            case 'QS Agilent'
                mode = 'qs';
                NanoImport_QS_Agilent(debugON,bins,w,ErrorPlotMode,mode)
            case 'QS Bruker'
                NanoImport_QS_Bruker(debugON,bins,w,ErrorPlotMode)
        end

end





%% InBuilt Functions


% This allows the user to choose the settings via dialogue boxes.
function [bins,w,ErrorPlotMode] = FormattingChoosing(DefaultDlg,USS)
    dlg_title = 'FormattingChoosing';
    
    % This is the number of bins which it will group the data along the
    % x-axis with.
    bins = str2double(inputdlg({'How many bins do you want to use'},dlg_title,[1,50]));
    
    if isempty(bins) == true
        bins = USS.bins;
        PopUpMsg(sprintf('No bin input was made, hence the default value of %d was chosen!',bins),dlg_title,'Warn','Nothing');
    end

    % This is chosen for all other inputs apart from if no input is
    % chosen, as the data could then be later analysed and it
    % would be useful to have these settings chosen.

    % This is the weighting mode to do for the standard deviation
    % and standard error, see Matlab documentation on std.
    ErrorPlotMode = questdlg('Choose to show standard error or standard deviation:',dlg_title,'Standard error','Standard deviation',DefaultDlg.ErrorPlotMode);

    if strcmp(ErrorPlotMode,'') == true
        ErrorPlotMode = USS.ErrorPlotMode;
        PopUpMsg(sprintf('No error choice was made, hence default of "%s" was chosen!',ErrorPlotMode),dlg_title,'Warn','Nothing');
    end
    
    % This chooses whether the standard deviation or standard error
    % will be plotted as the y-uncertainties in the graphs.
    StdDevWeightingMode = questdlg('Choose the standard deviation weighting to use:',dlg_title,'N-1','N','Using bin errors',DefaultDlg.StdDevWeightingMode);

    if strcmp(StdDevWeightingMode,'') == true
        w = USS.w;
        PopUpMsg(sprintf('No weighting choice was made, hence default of %d was chosen!',w),dlg_title,'Warn','Nothing');
    else
        % This is the standard deviation weighting mode.
        w = wGenerator(StdDevWeightingMode);
    end
    

end

function PopUpMsg(msg,title,ErrorOrHelp,ExitOrRestart)
    switch ErrorOrHelp
        case 'Error'
            PopUp = errordlg(msg,title);
        case 'Help'
            PopUp = helpdlg(msg,title);
        case 'Warn'
            PopUp = warndlg(msg,title);
    end
    switch ExitOrRestart
        case 'Exit'
            waitfor(PopUp);
            return
        case 'Restart'
            waitfor(PopUp);
            NanoImport % This doesn't save the data known previously!
        case 'Nothing'
            waitfor(PopUp);
    end
end




