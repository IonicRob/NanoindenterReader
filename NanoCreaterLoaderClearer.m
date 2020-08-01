%% NanoCreaterLoaderClearer

function NanoCreaterLoaderClearer(ClearVariablesONOFF,ClearPreferencesONOFF)
    InitialSettingsList = {'dlg_title','debugON','PlotAesthetics','DefaultDlg','USS','ImageFormatType'};
    InitialSettingsList2 = {'ImportNewYS','SettingsDone','bins','FormatAnswer','StdDevWeightingMode','ErrorPlotMode'};
    InitialSettingsList = horzcat(InitialSettingsList,InitialSettingsList2);
    
    if ClearVariablesONOFF == true
        % Clears all variables in Workspace apart from those in the cell
        % array.
        clearvars('-except',InitialSettingsList{:});
    end
    
    if ClearPreferencesONOFF == true
        % Clears all preferences in uipref dialogue pop-ups.
        % uisetpref('clearall');
    end
end