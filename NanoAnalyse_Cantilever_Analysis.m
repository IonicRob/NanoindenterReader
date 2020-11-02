%% NanoAnalyse_Cantilever_Analysis
% By Robert J Scales

function [FileStuctures] = NanoAnalyse_Cantilever_Analysis(debugON,PlotAesthetics,FormatAnswer,DfltImgFmtType)

code_title = 'NanoAnalyse_Cantilever_Analysis';
fprintf('%s: Started...\n\n',code_title);
cd_init = cd;
waitTime = 2; % The time spent on each figure.

testTF = true;
if testTF == true
    clc;
    WARN = warndlg(sprintf('Currently in testing mode for %s!!',code_title));
    waitfor(WARN);
    debugON = true;
    PlotAesthetics = struct('capsize',0,'linewidth',2,'facealpha',0.25);
    FormatAnswer = 'Line';
    DfltImgFmtType = 'png'; % 'tiffn'
end

% This loads the ".mat" files produced by NanoDataCreater which the user
% wishes to plot on the same figure.
[FileStuctures,~,cd_load] = LoadingFilesFunc(debugON,'on');

[~,~,figHandles] = NanoPlotter_main(debugON,FileStuctures,PlotAesthetics,FormatAnswer);

if debugON == true
    disp('Post figure handles are:');
    disp(figHandles);
end

%% Saving Results

% Loading mode is true as we are not importing data.
LoadingMode = true;
cd(cd_init);

% Setting DataIDName to nan will then make NanoDataSave ask for
% DataIDName when it runs.
DataIDName = '';

% The output data is mainly useful for NanoDataCreater but not for this.
NanoPlotterFigureSaver(debugON,DfltImgFmtType,LoadingMode,cd_init,DataIDName,cd_load);


fprintf('%s: Completed!\n\n',code_title);

end