%% NanoAnalyse_Cantilever_Stiffness
% By Robert J Scales

function [FileStuctures] = NanoAnalyse_Cantilever_Stiffness(debugON,PlotAesthetics,DfltImgFmtType)
%% Set-up and Loading
code_title = 'NanoAnalyse_Cantilever_Stiffness';
fprintf('%s: Started...\n\n',code_title);
cd_init = cd;
waitTime = 2; % The time spent on each figure.
    % This sets the font size for all text in all of the figures!
    set(0,'defaultAxesFontSize',20);
    % This sets the marker size for all text in all of the figures!
    set(0,'defaultLineMarkerSize',12);

testTF = false;
if testTF == true
    clc;
    WARN = warndlg(sprintf('Currently in testing mode for %s!!',code_title));
    waitfor(WARN);
    debugON = true;
    PlotAesthetics = struct('capsize',0,'linewidth',1,'facealpha',0.25);
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

figure('Name','Main','WindowState','Maximized');

Question = sprintf('Do you want to plot on the same figure?\n(WARNING choose only if x-y units for all data!)');
Question_title = 'Stacking Data';
StackOnSameFig = questdlg(Question,Question_title,'Yes','No','No');

NumOfFiles = length(FileStuctures);

ExportPreStruct = cell(1,NumOfFiles);

for i = 1:NumOfFiles
    
    fprintf('\n\n%s: Working on file "%s"...\n%s\n',code_title,FileStuctures{i}.DataIDName,'----------------------------------');
    curr_FileStuctures = FileStuctures{i};
    curr_varNames = curr_FileStuctures.varNames;
    curr_VarData = curr_FileStuctures.ValueData;
    curr_DataIDName = curr_FileStuctures.DataIDName;
    
    DispCol = listdlg('ListString',curr_varNames,'PromptString','Select the indent displacement:','SelectionMode','single');
    LoadCol = listdlg('ListString',curr_varNames,'PromptString','Select the indent load:','SelectionMode','single');
    fprintf('Calibrated importing data so the indent depth is col-%d, and indent load is col-%d...\n',DispCol,LoadCol);
    
    if i>1 && strcmp(StackOnSameFig,'No')
        figure('Name',curr_DataIDName,'WindowState','Maximized');
    end
    
    LoadDispPlot = plot(curr_VarData(:,DispCol),curr_VarData(:,LoadCol),'x','DisplayName',curr_DataIDName,'LineWidth',PlotAesthetics.linewidth);
    legend('Location','NorthWest');
    hold on
    OutputStruct = GradientObtainer(curr_VarData(:,DispCol),curr_VarData(:,LoadCol),curr_DataIDName,false,[0.2,0.05]);
    
%     [DataTypeList,PlotDataTypes,figHandles] = NanoPlotter_main(debugON,curr_FileStuctures,PlotAesthetics,FormatAnswer);
% 
%     if debugON == true
%         disp('Post figure handles are:');
%         disp(figHandles);
%     end

    LineColor = LoadDispPlot.Color;
    FitWidth = PlotAesthetics.linewidth + 1;

    PositiveSlopePlot = plot(OutputStruct.LinFit_Pos.fit,'-');
    uistack(PositiveSlopePlot,'bottom');
    PositiveSlopePlot.Color = LineColor;
    PositiveSlopePlot.LineWidth = FitWidth;
    Pos_GradAndError = sprintf('a = %.2e +- %.2e ',OutputStruct.LinFit_Pos.a,OutputStruct.LinFit_Pos.a_StdDev);
    Pos_YIntAndError = sprintf('b = %.2e +- %.2e ',OutputStruct.LinFit_Pos.b,OutputStruct.LinFit_Pos.b_StdDev);
    PositiveSlopePlot.DisplayName = sprintf('%s- +ve Slope\n%s\n%s',curr_DataIDName,Pos_GradAndError,Pos_YIntAndError);
    clear Pos_GradAndError Pos_YIntAndError

    NegativeSlopePlot = plot(OutputStruct.LinFit_Neg.fit,'--');
    uistack(NegativeSlopePlot,'bottom');
    NegativeSlopePlot.Color = LineColor;
    NegativeSlopePlot.LineWidth = FitWidth;
    Neg_GradAndError = sprintf('a = %.2e +- %.2e ',OutputStruct.LinFit_Neg.a,OutputStruct.LinFit_Neg.a_StdDev);
    Neg_YIntAndError = sprintf('b = %.2e +- %.2e ',OutputStruct.LinFit_Neg.b,OutputStruct.LinFit_Neg.b_StdDev);
    NegativeSlopePlot.DisplayName = sprintf('%s- +ve Slope\n%s\n%s',curr_DataIDName,Neg_GradAndError,Neg_YIntAndError);
    clear Neg_GradAndError Neg_YIntAndError

    xlabel(curr_varNames(DispCol));
    ylabel(curr_varNames(LoadCol));
    if strcmp(StackOnSameFig,'No')
        title(sprintf('Stiffness Analysis for %s',curr_DataIDName));
    else
        title(sprintf('Stiffness Analysis'));
        set(gcf,'name','StiffnessAnalysis')
    end
    legend('Location','NorthWest');
    
    XUnit = split(curr_varNames(DispCol),' ');
    XUnit = XUnit(2);
    OutputStruct.XUnit = XUnit;
    
    YUnit = split(curr_varNames(LoadCol),' ');
    YUnit = YUnit(2);
    OutputStruct.YUnit = YUnit;
    
    OutputStruct.GradUnit = sprintf('%s/%s',YUnit,XUnit);
    
    OutputStruct.Name = curr_DataIDName;
    ExportPreStruct{i} = OutputStruct;
    
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

% GradUnitList = strings(1,NumOfFiles);
% for i = 1:NumOfFiles
%     CurrentStuct = ExportPreStruct{i};
%     GradUnitList(i) = CurrentStuct.GradUnit;
% end

% RowNameList = strings(1,NumOfFiles*4);
% for i = 1:NumOfFiles
%     CurrentStuct = ExportPreStruct{i};
%     FirstRowNum = (4*(i-1))+1;
%     RowNameList(FirstRowNum) = sprintf('%s Stiffness (%s)',CurrentStuct.Name,CurrentStuct.GradUnit);
%     RowNameList(FirstRowNum+1) = sprintf('%s Stiffness StdDev (%s)',CurrentStuct.Name,CurrentStuct.GradUnit);
%     RowNameList(FirstRowNum+2) = sprintf('%s Y-Intercept (%s)',CurrentStuct.Name,CurrentStuct.YUnit);
%     RowNameList(FirstRowNum+3) = sprintf('%s Y-Intercept StdDev (%s)',CurrentStuct.Name,CurrentStuct.YUnit);
% end


quest = sprintf('Export this data to an Excel spreadsheet?:');
[SavingLocYN,cd_save] = NanoSaveFolderPref(quest,cd_init,cd_load);
if ~strcmp(SavingLocYN,'do not save data')
    
    IDName = string(inputdlg('Type in the name of this session:','Choosing IDName value'));
    
    NameList = strings(1,NumOfFiles*2);
    for i=1:NumOfFiles
        Num = (2*i)-1;
        CurrentStuct = ExportPreStruct{i};
        NameList(Num) = sprintf('%s - Loading',CurrentStuct.Name);
        NameList(Num+1) = sprintf('%s - UnLoading',CurrentStuct.Name);
    end
    
    RowNameList = {'Stiffness (mN/nm)','Stiffness StdDev (mN/nm)','y-intercept (mN)','y-intercept StdDev (mN)'};
    
    varNames = horzcat("Fit Parameter",NameList);
    varTypes = cell(1,(NumOfFiles*2)+1);
    varTypes(1) = {'string'};
    varTypes(2:end) = {'double'};
    ExportTable = table('Size',[length(RowNameList),length(varNames)],'VariableTypes',varTypes,'VariableNames',varNames);
    
    ExportTable(1,1) = table(RowNameList(1));
    ExportTable(2,1) = table(RowNameList(2));
    ExportTable(3,1) = table(RowNameList(3));
    ExportTable(4,1) = table(RowNameList(4));
    
    for i = 1:NumOfFiles
        Num = (2*i);
        CurrentStuct = ExportPreStruct{i};
        ExportTable(1,Num) = table(CurrentStuct.LinFit_Pos.a);
        ExportTable(2,Num) = table(CurrentStuct.LinFit_Pos.a_StdDev);
        ExportTable(3,Num) = table(CurrentStuct.LinFit_Pos.b);
        ExportTable(4,Num) = table(CurrentStuct.LinFit_Pos.b_StdDev);
        ExportTable(1,Num+1) = table(CurrentStuct.LinFit_Neg.a);
        ExportTable(2,Num+1) = table(CurrentStuct.LinFit_Neg.a_StdDev);
        ExportTable(3,Num+1) = table(CurrentStuct.LinFit_Neg.b);
        ExportTable(4,Num+1) = table(CurrentStuct.LinFit_Neg.b_StdDev);
    end
    

    cd(cd_save);
    SaveTime = datestr(datetime('now'),'yyyy-mm-dd-HH-MM');
    SpreadSheetSaveName = sprintf('%s_%s_Export_Cantilever_Stiffness.xlsx',IDName,SaveTime);
    writetable(ExportTable,SpreadSheetSaveName,'Sheet','StiffnessData');
    fprintf('Auto-exported "%s"!\n',IDName);
    cd(cd_init)
else
    fprintf('The data for session was not exported!\n');

end

fprintf('%s: Completed!\n\n',code_title);

end










%% Internal Function

function OutputStruct = GradientObtainer(Disp,Load,Name,DebugON,PrcntCutOff)
% PrcntCutOff has the first and second values in the array being the amount to reduce
% off the LHS and the RHS of the plot respectivelu. This is so you can
% remove like 20% of the LHS and 5% off the RHS.
    LoadGrad1 = gradient(Load,Disp);
    
    [LoadGrad1_max_disp,LoadGrad1_max_disp_index] = max(Disp);
    
    CutOffBoundaries = [LoadGrad1_max_disp*(PrcntCutOff(1)),LoadGrad1_max_disp*(1-PrcntCutOff(2))];
    
    [~,LoadGrad1_Cut_max_pos] = min(abs( Disp(1:LoadGrad1_max_disp_index) - CutOffBoundaries(2) ));
    [~,LoadGrad1_Cut_min_pos] = min(abs( Disp(1:LoadGrad1_max_disp_index) - CutOffBoundaries(1) ));
    
    hold on
    UnloadingData = flipud([Disp(LoadGrad1_max_disp_index:end),Load(LoadGrad1_max_disp_index:end)]);
    [~,LoadGrad1_Cut_max_neg] = min(abs( UnloadingData(:,1) - CutOffBoundaries(2) ));
    [~,LoadGrad1_Cut_min_neg] = min(abs( UnloadingData(:,1) - CutOffBoundaries(1) ));
    
%     plot(UnloadingData(:,1),UnloadingData(:,2),'m^');
    
    Range_Pos = [LoadGrad1_Cut_min_pos,LoadGrad1_Cut_max_pos];
    PosData = [Disp(Range_Pos(1):Range_Pos(2)),Load(Range_Pos(1):Range_Pos(2))];
    
    Range_Neg = [LoadGrad1_Cut_min_neg,LoadGrad1_Cut_max_neg];
    disp(Range_Neg);
    NegData = [UnloadingData(Range_Neg(1):Range_Neg(2),1),UnloadingData(Range_Neg(1):Range_Neg(2),2)];
    
    OutputStruct.LinFit_Pos = LinearFitting(PosData(:,1),PosData(:,2));
    OutputStruct.LinFit_Neg = LinearFitting(NegData(:,1),NegData(:,2));
        
    if DebugON == true
        OutputStruct.UnloadingData = UnloadingData;
        OutputStruct.PosData = PosData;
        OutputStruct.NegData = NegData;

        hold on
        
        yyaxis right
        plot(Disp,LoadGrad1,'DisplayName',sprintf('grad(%s)',Name));
        ylabel('Gradient (mN/nm typically)');
        ylim(ExpectedRange);
        plot(PosData(:,1),PosData(:,2),'-gx');
        plot(NegData(:,1),NegData(:,2),'-cx');
        
        yyaxis left
        
        xline(Disp(LoadGrad1_Cut_max_pos),'k','DisplayName','Loading-Max');
        xline(Disp(LoadGrad1_Cut_min_pos),'--k','DisplayName','Loading-Min');
        xline(UnloadingData(LoadGrad1_Cut_max_neg,1),'r','DisplayName','UnLoading-Max');
        xline(UnloadingData(LoadGrad1_Cut_min_neg,1),'--r','DisplayName','UnLoading-Min');
    end
    
end


function LinFit = LinearFitting(X,Y)

    if length(X)>=2
        fprintf('LinearFitting: Number of points being used = %d\n',length(X));
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
    else
        warndlg('Less than two data points inputted!');
        LinFit = nan;
    end
    
end

%% Old Code

%     disp([LoadGrad1_Cut_min_neg,LoadGrad1_Cut_max_neg]);
%     NumOfUnLoadingPoints = length(Disp(LoadGrad1_max_disp_index:end));
%     LoadGrad1_Cut_max_neg = LoadGrad1_max_disp_index + (NumOfUnLoadingPoints-LoadGrad1_Cut_max_neg);
%     LoadGrad1_Cut_min_neg = LoadGrad1_max_disp_index + (NumOfUnLoadingPoints-LoadGrad1_Cut_min_neg);
