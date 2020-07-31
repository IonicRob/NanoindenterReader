%% Saving Results


function [DataIDName,SaveTime,SavingData,LOC_save] = NanoDataSave(ImageFormatType,LoadingMode,LOC_init,dlg_title,fileNameList)
    fprintf('NanoDataSave: Started!\n');

    quest = {'Save the figures and file names?:'};
    [SavingLocYN,LOC_save] = NanoSaveFolderPref(quest,LOC_init);

    if ~strcmp(SavingLocYN,'do not save data')
        cd(LOC_save);
        
        DataIDName = string(inputdlg('Type the identifying name for this session (NO odd symbols!):',dlg_title,[1,50]));

        quest = {'Choose how to save the data?:'};
        pbnts = {'Auto','Semi-auto','Manual'};
        [SavingData,~] = uigetpref('Settings','AutoSaving',dlg_title,quest,pbnts);

        SaveTime = datestr(datetime('now'),'yyyy-mm-dd-HH-MM');
        figHandles = findobj('Type', 'figure');

        % To keep track of what files where used, this is automatically named
        % for easy back tracking!
        FileImportedListName = sprintf('Filenames_%s_%s.mat',DataIDName,SaveTime);
        
        if LoadingMode == true && strcmp(SavingData,'manual') == false
            save(FileImportedListName,'fileNameList','-mat');
        end

        switch SavingData
            case 'auto'
                disp('Data is being saved automatically');
                cycleAndSaveFiguresFunc(DataIDName,figHandles,ImageFormatType,SaveTime,SavingData,dlg_title);
            case 'semi-auto'
                disp('Data is being saved semi-automatically');
                cycleAndSaveFiguresFunc(DataIDName,figHandles,ImageFormatType,SaveTime,SavingData,dlg_title);
            case 'manual'
                commandwindow
                disp('You have to manually save the data');
        end
    else
        disp('You have chosen not to save data!');
        DataIDName = nan;
        SaveTime = nan;
        SavingData = nan;
        LOC_save = nan;
    end


    cd(LOC_init);
    fprintf('NanoDataSave: Complete!\n\n');
end

function cycleAndSaveFiguresFunc(DataIDName,figHandles,ImageFormatType,SaveTime,SavingData,dlg_title)
    NumOfFigures = length(figHandles);
    for i = 1:NumOfFigures
        CurrentFigureHandle = figHandles(i);
        FigureName = CurrentFigureHandle.Name;
        fprintf('Currently on figure "%s"...\n',FigureName);
        switch SavingData
            case 'auto'
                figure(CurrentFigureHandle);
                FigureSaveName = sprintf('%s_%s_%s',DataIDName,FigureName,SaveTime);
                saveas(CurrentFigureHandle,FigureSaveName,ImageFormatType);
                fprintf('Auto-saved figure "%s"...\n',FigureName);
            case 'semi-auto'
                figure(CurrentFigureHandle);
                message = sprintf('Name of file for "%s", will be saved as a ".%s"',FigureName,ImageFormatType);
                FigureSaveName = string(inputdlg(message,dlg_title,[1,50]));
                saveas(CurrentFigureHandle,FigureSaveName,ImageFormatType);
                fprintf('Semi-auto-saved figure "%s"...\n',FigureName);
        end
    end
    commandwindow
end

% function SaveData(ValueData,ErrorData,SampleNameList,DataIDName,SaveTime,SavingData)
%     dataToSave = struct('ValueData',ValueData,'ErrorData',ErrorData,'SampleNameList',SampleNameList,'DataIDName',DataIDName);
%     DataSaveName = sprintf('%s_%s_Data.mat',DataIDName,SaveTime);
%         switch SavingData
%             case 'auto'
%                 save(DataSaveName,'dataToSave','-mat');
%                 fprintf('Auto-saved "%s"...\n',DataIDName);
%             case 'semi-auto'
%                 uisave('dataToSave',DataSaveName);
%                 fprintf('Semi-auto-saved "%s"...\n',DataIDName);
%         end
% end