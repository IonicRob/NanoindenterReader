%% NanoImport_General
% By Robert J Scales

function NanoImport_General
%% Starting Up

% uisetpref('clearall');
SavingData = 'auto';

dlg_title = mfilename;
fprintf('%s: Started!\n\n',dlg_title);

[debugON,~] = ifcalled;

cd_init = cd; % Initial directory

filter = {'*.xlsx;*.xls','Agilent Files (*.xlsx, *.xls)';'*.txt','Bruker Files (*.txt)'};
% filter = {'*.xlsx;*.xls;*.txt','Valid Data Types (*.xlsx, *.xls, *.txt)';'*.xlsx;*.xls','Agilent Files (*.xlsx, *.xls)';'*.txt','Bruker Files (*.txt)'};

% This gets the file data for the sample.
[file,path,fileTypeIndex] = uigetfile(filter,'Select file(s) to import:','MultiSelect','on');
cd_load = path;
% Below uses the file and path data above and produces it into the correct
% format, along with producing other useful data.
[NoOfFiles,fileNameList,files] = getFileCompiler(debugON,path,file);
if isnan(NoOfFiles) == true
    return
end

%% Importing Data

% This gives the user the option of where to save the data or not to
% save the data at all.
[SavingLocYN,cd_save] = NanoSaveFolderPref('Imported files save location?:',cd_init,cd_load);

for CurrFileNum=1:NoOfFiles
    close all
    
    filename = fileNameList(CurrFileNum,2);

    switch fileTypeIndex
        case 1
            [SheetNames,NumOfIndentsInFile,Calibration_ColNames,ListOfSheets] = NanoImport_General_Agilent(filename);
        case 2
            [NumOfIndentsInFile,Calibration_ColNames] = NanoImport_General_Bruker(filename);
    end
    
    if CurrFileNum == 1
        firstColNames = Calibration_ColNames;
    end
    
    if CurrFileNum == 1 || isequal(Calibration_ColNames,firstColNames) == false
        % This only happens if it is the first file loaded, or the column
        % headers do not match with the first file.
        % This allows the user to select what columns the indent
        % displacement is working and the load too.
        PromptString = 'Select the indent displacement:';
        DispCol = listdlg('ListString',Calibration_ColNames,'PromptString',PromptString,'SelectionMode','single');
        PromptString = 'Select the y-variable to plot:';
        YVariable = listdlg('ListString',Calibration_ColNames,'PromptString',PromptString,'SelectionMode','single');
        fprintf('Calibrated importing data so the indent depth is col-%d, and y-variable is col-%d...\n',DispCol,YVariable);
    end

    for i = 1:NumOfIndentsInFile
        ImportingFigure = figure('Name','ImpFig','WindowState','Maximized');
        
        switch fileTypeIndex
            case 1
                % Agilent Method
                disp('Agilent Method Data Selected.');
                SheetNum = ListOfSheets(i);
                CurrIndentName = SheetNames(SheetNum);
                Current_Matrix = readmatrix(filename,'Sheet',SheetNum,'FileType','spreadsheet');
                titleText = sprintf('Current Sample: "%s" - %s',files(CurrFileNum),CurrIndentName);
            case 2
                % Bruker Method
                CurrIndentName = files(CurrFileNum);
                Current_Matrix = readmatrix(filename);
                titleText = sprintf('Current Sample: %s',files(CurrFileNum));
        end

        plotLabels(titleText,Calibration_ColNames(DispCol),Calibration_ColNames(YVariable));

        if isnan(Current_Matrix) == true
            DLG = warndlg(sprintf('This sheet called "%s" is empty, and hence will be skipped...',CurrIndentName));
            waitfor(DLG);
            close(ImportingFigure);
            break
        end
        

        LoadDisp = plot(Current_Matrix(:,DispCol),Current_Matrix(:,YVariable));
        hold on
        
        plotLabels(titleText,Calibration_ColNames(DispCol),Calibration_ColNames(YVariable));
        
        AnalyseIndentYN = questdlg('Do you want to analyse this indent?','Choosing Data','Yes','No','Yes');
        if strcmp(AnalyseIndentYN,'No') == true
            close(ImportingFigure);
            continue
        end


        PlotGradientsON = false;
        if PlotGradientsON == true
            % Gradient = gradient(Current_Matrix(:,DispCol),Current_Matrix(:,LoadCol));
            % plot(Current_Matrix(:,DispCol),Gradient);
            % Gradient2 = gradient(Gradient);
            plot(Gradient,'-x');
        end

        %% Post-Processing - Changing Origin Point
        
        Gradient = gradient(Current_Matrix(:,DispCol));
        Recommended_StartPoint = find(0<Gradient & Gradient<0.1,1); % Finds the first point for which the displacement is first increasing by 0.1 units per row, this is to counteract if it goes reverse.
        %Recommended_StartPoint = find(Current_Matrix(:,LoadCol)>0.06,1); % Finds the point for which the load is first above 0.06 mN.
        hold on
        StartPoint_Plot = plot(Current_Matrix(Recommended_StartPoint,DispCol),Current_Matrix(Recommended_StartPoint,YVariable),'rx','MarkerSize',20);
        % datatip(LoadDisp,'DataIndex',Recommended_StartPoint)

        Question = 'Want to use the recommended origin point?';
        Question_title = 'Clipping The Data';
        UseAutoClipON = questdlg(Question,Question_title,'Yes','Manually Choose','Leave Alone','Yes');

    %     if strcmp(UseAutoClipON,'Manually Choose') == true
    %         [x_point,~] = ginput(1);
    %         [~,Recommended_StartPoint] = min(abs( x_point - Current_Matrix(:,DispCol) ));
    %         disp(Recommended_StartPoint);
    %     end

        switch UseAutoClipON
            case 'Manually Choose'
                [x_point,~] = ginput(1);
                [~,Recommended_StartPoint] = min(abs( x_point - Current_Matrix(:,DispCol) ));
                %disp(Recommended_StartPoint);
                Rec_StartPoint_XY = [Current_Matrix(Recommended_StartPoint,1),Current_Matrix(Recommended_StartPoint,2)];
            case 'Leave Alone'
                Recommended_StartPoint = 1;
                Rec_StartPoint_XY = [0,0];
            case 'Yes'
                Rec_StartPoint_XY = [Current_Matrix(Recommended_StartPoint,1),Current_Matrix(Recommended_StartPoint,2)];
        end

        delete(LoadDisp);
        delete(StartPoint_Plot);

        Current_Matrix = Current_Matrix(Recommended_StartPoint:end,:);
        Current_Matrix(:,1) = Current_Matrix(:,1)-Rec_StartPoint_XY(1);
        Current_Matrix(:,2) = Current_Matrix(:,2)-Rec_StartPoint_XY(2);

        LoadDisp = plot(Current_Matrix(:,DispCol),Current_Matrix(:,YVariable));
        hold on

        plotLabels(titleText,Calibration_ColNames(DispCol),Calibration_ColNames(YVariable));

%         wait(0.5);
        %% Post-Processing - Removing Bad/Un-needed Data
        XDataCol = DispCol;
        varNames = string(Calibration_ColNames);
        w = 0;
        ErrorPlotMode = 'Standard deviation';
        method_name = 'Agilent-QS';

        % Removing Columns with NaN
        NumColumns = size(Current_Matrix,2);
        New_Current_Matrix = Current_Matrix;
        for m = 1:NumColumns
            AllNaN = sum(all(isnan(Current_Matrix(:,m))));
            if AllNaN == true
                New_Current_Matrix(:,m) = [];
                varNames(m) = [];
                if m < XDataCol
                    XDataCol = XDataCol-1;
                    fprintf('XDataCol = %d',XDataCol);
                end
            end
%             A = isoutlier(New_Current_Matrix(:,m));
        end
        disp('Removed columns of just NaN...');
        
        [row, ~] = find(isnan(New_Current_Matrix));
        RowsContainingNaN = unique(row);
        New_Current_Matrix(RowsContainingNaN,:) = [];
        disp('Removed rows containing a NaN...');
       
        [row, ~] = find(abs(New_Current_Matrix) > 10^10);
        RowsOfTooBigMag = unique(row);
        New_Current_Matrix(RowsOfTooBigMag,:) = [];
        disp('Removed rows with magnitudes > 10^10...');

        Current_Matrix = New_Current_Matrix;

        ValueData = Current_Matrix;
        ErrorData = nan(size(Current_Matrix));
        
        
        % Saving Section
        [dataToSave] = NanoImport_Saving(debugON,ValueData,ErrorData,w,ErrorPlotMode,varNames,XDataCol,method_name,cd_init,SavingLocYN,cd_save,SavingData); % dataToSave
        close(ImportingFigure);
    end

end
%%

fprintf('%s: Completed!\n\n',dlg_title);
end

%% InBuilt Functions

function plotLabels(titleLabel,xLabel,yLabel)

title(titleLabel);
xlabel(xLabel);
ylabel(yLabel);

end

%% Development Plan

    % Things left to do
    % #1 Comment on what I have done
    % #1A Try find peaks to see if the last +ve peak will be reasonably
    % found and if that gives good results.
    % #2 Add in a feature so that it converts the data from the sheets into
    % Matlab table form and then those can be saved individually for each
    % indent.
    % Once that is done, have a feature so that the data can be analysed.
    % Like what Chris Magazzeni wanted and also for what I want to do
    % (obtain stiffness).
