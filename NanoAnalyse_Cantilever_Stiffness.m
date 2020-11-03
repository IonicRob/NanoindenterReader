%% NanoAnalyse_Cantilever_Stiffness
% By Robert J Scales

function [FileStuctures] = NanoAnalyse_Cantilever_Stiffness(debugON,PlotAesthetics,FormatAnswer,DfltImgFmtType)
%% Set-up and Loading
code_title = 'NanoAnalyse_Cantilever_Stiffness';
fprintf('%s: Started...\n\n',code_title);
cd_init = cd;
waitTime = 2; % The time spent on each figure.
    % This sets the font size for all text in all of the figures!
    set(0,'defaultAxesFontSize',20);
    % This sets the marker size for all text in all of the figures!
    set(0,'defaultLineMarkerSize',12);

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

%% Plotting

% Found a bug when trying to work on more than two files and automatically
% plot it by using this function just once. I think it's because of the
% set-up for the code before the file loop is the issue. Individually this
% has no problem, hence I will set it up in a loop for each file at the
% moment.

close all

figure('Name','FigCanAna','WindowState','Maximized');

for i = 1:length(FileStuctures)
    fprintf('\n\n%s: Working on file "%s"...\n%s\n',code_title,FileStuctures{i}.DataIDName,'----------------------------------');
    curr_FileStuctures = FileStuctures{i};
    curr_varNames = curr_FileStuctures.varNames;
    curr_VarData = curr_FileStuctures.ValueData;
    curr_DataIDName = curr_FileStuctures.DataIDName;
    
    DispCol = listdlg('ListString',curr_varNames,'PromptString','Select the indent displacement:','SelectionMode','single');
    LoadCol = listdlg('ListString',curr_varNames,'PromptString','Select the indent load:','SelectionMode','single');
    fprintf('Calibrated importing data so the indent depth is col-%d, and indent load is col-%d...\n',DispCol,LoadCol);
    
    LoadDispPlot = plot(curr_VarData(:,DispCol),curr_VarData(:,LoadCol),'-x','DisplayName',curr_DataIDName);
    legend('Location','NorthWest');
    hold on
    GradInRangeData = GradientObtainer(curr_VarData(:,DispCol),curr_VarData(:,LoadCol),curr_DataIDName,true,20/100);
%     [DataTypeList,PlotDataTypes,figHandles] = NanoPlotter_main(debugON,curr_FileStuctures,PlotAesthetics,FormatAnswer);
% 
%     if debugON == true
%         disp('Post figure handles are:');
%         disp(figHandles);
%     end

    xlabel(curr_varNames(DispCol));
    ylabel(curr_varNames(LoadCol));
    legend('Location','NorthWest');
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

%% Internal Function

function [GradInRangeData] = GradientObtainer(Disp,Load,Name,DebugON,PrcntCutOff)
    LoadGrad1 = gradient(Load,Disp);
    [LoadGrad1_max_disp,LoadGrad1_max_disp_index] = max(Disp);
    
    [~,LoadGrad1_Cut_max_pos] = min(abs( Disp(1:LoadGrad1_max_disp_index) - LoadGrad1_max_disp*(1-PrcntCutOff) ));
    [~,LoadGrad1_Cut_min_pos] = min(abs( Disp(1:LoadGrad1_max_disp_index) - LoadGrad1_max_disp*(PrcntCutOff) ));
    
%     [~,LoadGrad1_Cut_max_neg] = min(abs( Disp(LoadGrad1_max_disp_index:end) - Disp(LoadGrad1_Cut_max_pos) ));
%     [~,LoadGrad1_Cut_min_neg] = min(abs( Disp(LoadGrad1_max_disp_index:end) - Disp(LoadGrad1_Cut_min_pos) ));
%     disp([LoadGrad1_Cut_min_neg,LoadGrad1_Cut_max_neg]);
%     NumOfUnLoadingPoints = length(Disp(LoadGrad1_max_disp_index:end));
%     LoadGrad1_Cut_max_neg = LoadGrad1_max_disp_index + (NumOfUnLoadingPoints-LoadGrad1_Cut_max_neg);
%     LoadGrad1_Cut_min_neg = LoadGrad1_max_disp_index + (NumOfUnLoadingPoints-LoadGrad1_Cut_min_neg);
    
    Range_Pos = [LoadGrad1_Cut_min_pos,LoadGrad1_Cut_max_pos];
    PosData = [Disp(Range_Pos(1):Range_Pos(2)),LoadGrad1(Range_Pos(1):Range_Pos(2))];
    GradInRangeData.Pos = PosData;
    
%     Range_Neg = [LoadGrad1_Cut_min_neg,LoadGrad1_Cut_max_neg];
%     disp(Range_Neg);
%     NegData = [Disp(Range_Neg(1):Range_Neg(2)),LoadGrad1(Range_Neg(1):Range_Neg(2))];
%     GradInRangeData.Neg = NegData;
%     GradInRangeData.Disp = Disp(LoadGrad1_max_disp_index:end);
    
    GradInRangeData.LinFit_Pos = LinearFitting(Disp(Range_Pos(1):Range_Pos(2)),Load(Range_Pos(1):Range_Pos(2)));
%   GradInRangeData.LinFit_Neg = LinearFitting(Disp,LoadGrad1,LoadGrad1_Cut_Range_Neg);
        
    if DebugON == true
        hold on
        
        yyaxis right
%         plot(Disp,LoadGrad1,'DisplayName',sprintf('grad(%s)',Name));
%         ylabel('Gradient (mN/nm typically)');
%         ylim(ExpectedRange);
%         plot(PosData(:,1),PosData(:,2),'-gx');
%         plot(NegData(:,1),NegData(:,2),'-cx');
        
        yyaxis left
        PositiveSlopePlot = plot(GradInRangeData.LinFit_Pos.fit,'-g');
        Pos_GradAndError = sprintf('a = %.2e +- %.2e ',GradInRangeData.LinFit_Pos.a,GradInRangeData.LinFit_Pos.a_StdDev);
        Pos_YIntAndError = sprintf('b = %.2e +- %.2e ',GradInRangeData.LinFit_Pos.b,GradInRangeData.LinFit_Pos.b_StdDev);
        PositiveSlopePlot.DisplayName = sprintf('%s- +ve Slope\n%s\n%s',Name,Pos_GradAndError,Pos_YIntAndError);
    end
end


function LinFit = LinearFitting(X,Y)
    
    % Better alternative to get the fit but this produces actual error values in the fitting parameters unlike above
    [LinFit.fit,LinFit.gof,LinFit.opt] = fit(X,Y,'poly1');
    LinFit.coeff = coeffvalues(LinFit.fit);
    LinFit.a = LinFit.coeff(1);
    LinFit.b = LinFit.coeff(2);
    if LinFit.opt.numobs>2 % This basically checks if more than two points are used in the linear fit
        LinFit.confint = confint(LinFit.fit,0.6826); % 68.26% is equivalent to 2 standard deviations in total width, 95% is 4 standard deviations
        LinFit.a_StdDev = (LinFit.confint(2,1) - LinFit.confint(1,1))/2; % Works out the standard deviation for the gradient
        LinFit.b_StdDev = (LinFit.confint(2,2) - LinFit.confint(1,2))/2; % Works out the standard deviation for the y-intercept
    else
        LinFit.a_StdDev = 0; % If two or less points are used in the fit then the standard deviation must be zero
        LinFit.b_StdDev = 0; % If two or less points are used in the fit then the standard deviation must be zero
    end
    LinFit.a_StdError = (LinFit.a_StdDev)/((LinFit.opt.numobs)^0.5); % Works out the standard error of the gradient
    LinFit.b_StdError = (LinFit.b_StdDev)/((LinFit.opt.numobs)^0.5); % Works out the standard error of the gradient
    
end