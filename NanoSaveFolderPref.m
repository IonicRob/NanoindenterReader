%% NanoSaveFolderPref

function [SavingLocYN,LOC_save] = NanoSaveFolderPref(quest,LOC_init,LOC_load)
    title = 'NanoSaveFolderPref';
    % This next bit checks to see if 'SettingsDone' exists, if not then the
    % code hasn't been run before and so not previous settings exist.
    pbnts = {'Yes + New Folder','Yes + Loading Folder','Do Not Save Data'};

    [SavingLocYN,~] = uigetpref('Settings','SaveYN',title,quest,pbnts);

    if strcmp(SavingLocYN,'yes + new folder')
        % Selects a new folder
        LOC_save = uigetdir(LOC_init,'Select the folder for save the data in');
        fprintf('Saving in new folder...\n..."%s"\n',LOC_save);
    elseif strcmp(SavingLocYN,'yes + loading folder')
        % By same folder it means the loading location.
        LOC_save = LOC_load;
        fprintf('Saving in same folder as the code...\n..."%s"\n',LOC_save);
    else
        % This should happen if "do not save data" was chosen
        LOC_save = LOC_init;
        fprintf('Not saving data!!\n');
    end
end