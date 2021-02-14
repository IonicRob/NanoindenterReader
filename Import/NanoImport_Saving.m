%% NanoImport_Saving

function [dataToSave] = NanoImport_Saving(debugON,ValueData,ErrorData,w,ErrorPlotMode,varNames,XDataCol,method_name,cd_init,SavingLocYN,cd_save,SavingData,FileIDName)

    dlg_title = 'NanoImport_Saving';

    % This is the name the whole file will be known as in terms of ID.
    if ~exist('FileIDName','var')
        disp('FileIDName does not exist')
        FileIDName = string(inputdlg('Type in ID of the data:',dlg_title,[1,50]));
    else
        disp('FileIDName does exist')
    end
%     FileIDName = string(inputdlg('Type in ID of the data:',dlg_title,[1,50]));
    
    % This is the time the data was saved at, thus allows for tracking of files
    % with the same FileIDName.
    SaveTime = datestr(datetime('now'),'yyyy-mm-dd-HH-MM');

    % This is the structure containing the data to save.
    dataToSave = struct('ValueData',ValueData,'ErrorData',ErrorData,'SampleNameList',FileIDName,'DataIDName',FileIDName,'w',w,'ErrorPlotMode',ErrorPlotMode,'varNames',string(varNames),'XDataCol',XDataCol,'method_name',method_name);

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

    % This is an automatically generated unique name for this data.
    DataSaveName = sprintf('%s__%s.mat',FileIDName,SaveTime);
    
    if strcmp(SavingLocYN,'do not save data') == false
        % This occurs when the user says they want to save data.
        fprintf('Save destination = "%s"\n',cd_save);
        cd(cd_save); % Changed current directory to the save location.
%         quest = sprintf('Choose how to save the data for %s?:',FileIDName);
%         pbnts = {'Auto','Semi-auto','Manual'};
%         [SavingData,~] = uigetpref('Settings','AutoSaving',dlg_title,quest,pbnts);
        switch SavingData
            case 'auto'
                disp('AUTOMATICALLY Saving the processed nanoindentation data');
                save(DataSaveName,'dataToSave','-mat');
                fprintf('Auto-saved "%s" as "%s"\n',FileIDName,DataSaveName);
            case 'semi-auto'
                disp('Saving the processed nanoindentation data');
                % uisave brings up a dialogue box for saving the data, it allows
                % the option to change the name that the data is saved as.
                uisave('dataToSave',DataSaveName);
                fprintf('Semi-auto-saved "%s"\n',FileIDName);
            case 'manual'
                disp('YOU have to manually save the data!');
        end
        cd(cd_init); % Changed current directory back to the original one.
    else
        % This occurs when the user says they DO NOT want to save data.
        disp('You have chosen not to save the data, hence YOU have to manually save the data!');
    end
    clear FileIDName
end