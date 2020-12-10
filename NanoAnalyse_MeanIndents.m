%% NanoAnalyse_MeanIndents
% By Robert J Scales 10/12/2020

function NanoAnalyse_MeanIndents


    clc;
    dlg_title = mfilename;
    fprintf('%s: Started!\n\n',dlg_title);
    cd_init = cd;
    
    DLG = errordlg('Analysis method is still in development!');
    waitfor(DLG);
    return
    
%{
    [debugON,~] = ifcalled;
    
    % This loads the ".mat" files produced by NanoDataCreater which the user
    % wishes to plot on the same figure.
    [FileStuctures,~,cd_load] = LoadingFilesFunc(debugON,'on');
    
    
    passTF = checkImportFileCompat(debugON,FileStuctures);

%}
end