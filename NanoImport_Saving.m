%% NanoImport_Saving

function [dataToSave] = NanoImport_Saving(debugON,ValueData,ErrorData,w,ErrorPlotMode,varNames,XDataCol,cd_init,cd_save)
    
    dlg_title = 'NanoImport_Saving';

    % This is the name the whole file will be known as in terms of ID.
    FileIDName = string(inputdlg('Type in the name of the meaned data (e.g. the material name):',dlg_title,[1,50]));
    
    % This is the time the data was saved at, thus allows for tracking of files
    % with the same FileIDName.
    SaveTime = datestr(datetime('now'),'yyyy-mm-dd-HH-MM');

    % This is the structure containing the data to save.
    dataToSave = struct('ValueData',ValueData,'ErrorData',ErrorData,'SampleNameList',FileIDName,'DataIDName',FileIDName,'w',w,'ErrorPlotMode',ErrorPlotMode,'varNames',string(varNames),'XDataCol',XDataCol);

    if debugON == true
        fields = fieldnames(dataToSave);
        for i = 1:length(fields)
            if i == 1
                fprintf('dataToSave has fields named\t"%s"\n',fields{i});
            else
                fprintf('\t\t\t\t\t\t\t"%s"\n',fields{i});
            end
        end
    end
    
    quest = sprintf('Choose how to save the data for %s?:',FileIDName);
    pbnts = {'Auto','Semi-auto','Manual'};
    [SavingData,~] = uigetpref('Settings','AutoSaving',dlg_title,quest,pbnts);

    DataSaveName = sprintf('%s_%s_Data.mat',FileIDName,SaveTime);
    fprintf('Default save destination = "%s"\n',cd_save);
    cd(cd_save);
    switch SavingData
        case 'auto'
            disp('Saving the processed nanoindentation data');
            save(DataSaveName,'dataToSave','-mat');
            fprintf('Auto-saved "%s" as "%s"\n',FileIDName,DataSaveName);
        case 'semi-auto'
            disp('Saving the processed nanoindentation data');
            % uisave brings up a dialogue box for saving the data, it allows
            % the option to change the name that the data is saved as.
            uisave('dataToSave',DataSaveName);
            fprintf('Semi-auto-saved "%s" as "%s"\n',FileIDName,DataSaveName);
        case 'manual'
            disp('YOU have to manually save the data!');
    end
    cd(cd_init);



end