%% NanoMeaner
% By Robert J Scales

function DataIDName = NanoMeaner(FileStuctures,DataTypeList,PlotDataTypes,LOC_init,debugON,LOC_load)
    title = 'NanoMeaner';
    fprintf('%s: Started!\n',title);        
    
    % The below bit just warns the user what is used in this function.
    message = {'This function (NanoMeaner) uses the following settings:';'w = 0';'Error = standard deviation';'For QS means loading data and not unloading?'};
    NanoMeanerMemo = helpdlg(message,title);
    waitfor(NanoMeanerMemo);
    w = 0;
    
    % This is the ammended list, as there's no point choosing the range
    % for figures that were chosen not to plot by the user.
    AmmendedDataTypeList = DataTypeList(PlotDataTypes(:));
    
    NumOfYData = length(DataTypeList);
    
    % This chooses what figure to base the range on.
    DataTypeToMean = ChooseDataToPlotAmmended(AmmendedDataTypeList,PlotDataTypes);
    
    % Self explanatory
    NumberOfFiles = length(FileStuctures);
    
%     % This brings up the figure from which the range will be taken across
%     % by the user.
%     figure(figHandles(DataTypeToMean));
    
    % This pop up box is used in the function "AimedRangeProducer" in this
    % code which gives the precise range that the user clicked or typed as
    % an output.
    RangeSelectionMode = questdlg('Choose how to select the range to mean across',title,'Graphically','Typed','Typed');
    AimedRange = AimedRangeProducer(DataTypeToMean,title,RangeSelectionMode);
    
    % Initialises this variable
    TotalNumOfSamples = 0;
    
    % Cycles through each file loaded in NanoDataLoader and grabs the total
    % number of samples, which will be used to determine the number of rows
    %of the spreadsheet.
    for FileNum = 1:NumberOfFiles
        CurrentIDName = FileStuctures{FileNum,1}.DataIDName;
        if debugON == true
            fprintf('Currently working on %s\n',CurrentIDName);
        end
        ValueData = FileStuctures{FileNum,1}.ValueData;
        NumberOfSamples = size(ValueData,3);
        TotalNumOfSamples = TotalNumOfSamples + NumberOfSamples;
        clear CurrentIDName NumberOfSamples NumberOfSamples
    end
    
    if debugON == true
        fprintf('Total number of samples = %d\n',TotalNumOfSamples);
    end
    
    % This generates the table which shows the results as strings
    % containing the value and the error of the associated data.
    TableVarNames = {'Data ID Name','Sample Name','Depth Range Used (nm)'};
    TableVarNames = horzcat(TableVarNames,DataTypeList);
    ThreeStrings = {'string','string','string'};
    TableVarTypes_add    = cell(1,NumOfYData);
    TableVarTypes_add(:) = {'string'};
    TableVarTypes = horzcat(ThreeStrings,TableVarTypes_add{:});
    NanoMeanerTable = table('Size',[TotalNumOfSamples,length(TableVarNames)],'VariableTypes',TableVarTypes,'VariableNames',TableVarNames);
    
    % This creates two more tables which show the process data rather than
    % the abbreviated forms in the above in NanoMeanerTable.
    TableVarTypes_add    = cell(1,NumOfYData);
    TableVarTypes_add(:) = {'double'};
    TableVarTypes = horzcat(ThreeStrings,TableVarTypes_add);
    NanoMeanerTableValues = table('Size',[TotalNumOfSamples,length(TableVarNames)],'VariableTypes',TableVarTypes,'VariableNames',TableVarNames);
    NanoMeanerTableErrors = table('Size',[TotalNumOfSamples,length(TableVarNames)],'VariableTypes',TableVarTypes,'VariableNames',TableVarNames);
    
    CurrRowPosition = 1;
    % This cycles through each file and generates the tables.
    for FileNum = 1:NumberOfFiles
        CurrentIDName = FileStuctures{FileNum,1}.DataIDName;
        if debugON == true
            fprintf('Currently working on %s\n',CurrentIDName);
        end
        % Below grabs the information from each filem which contains
        % information about each sample.
        ValueData = FileStuctures{FileNum,1}.ValueData;
        ErrorData = FileStuctures{FileNum,1}.ErrorData;
        SampleNameList = FileStuctures{FileNum,1}.SampleNameList;
        NumberOfSamples = size(ValueData,3);
        % Cycles through each sample in the file.
        for i=1:NumberOfSamples
            % curr = current
            currSampleName = SampleNameList(i);
            currValueData = ValueData(:,:,i);
            currErrorData = ErrorData(:,:,i);
            % The below function obtains the data required for the tables.
            [RangeUsedString,ValuesAndErrorsString,RangeMeanValues,RangeErrorValues] = processDataInAimedRange(AimedRange,currValueData,currErrorData,w,debugON);
            % The below function uses the above function and fills in the
            % three tables in the row = CurrRowPosition.
            NanoMeanerTable = AddingDataIntoTable(NanoMeanerTable,CurrRowPosition,CurrentIDName,currSampleName,RangeUsedString,ValuesAndErrorsString);
            NanoMeanerTableValues = AddingDataIntoTable(NanoMeanerTableValues,CurrRowPosition,CurrentIDName,currSampleName,RangeUsedString,RangeMeanValues);
            NanoMeanerTableErrors = AddingDataIntoTable(NanoMeanerTableErrors,CurrRowPosition,CurrentIDName,currSampleName,RangeUsedString,RangeErrorValues);
            CurrRowPosition = CurrRowPosition + 1;
        end
    end
    
    quest = {'Save the range mean table data?:'};
    [SavingLocYN,LOC_save] = NanoSaveFolderPref(quest,LOC_init,LOC_load);
    if ~strcmp(SavingLocYN,'do not save data')
        % Change current directory to where the user selected to save the
        % data.
        cd(LOC_save);
        
        fprintf('Range mean table will be auto-saved...\n');
        SaveTime = datestr(datetime('now'),'yyyy-mm-dd-HH-MM');
        
        % Unique identifier for the data.
        DataIDName = string(inputdlg('Choose the ID for this range mean data (NO odd symbols!):',title,[1,50]));
        
        % TableSaveName is the name the file will be saved as, it is
        % automatic to save time and for clarity.
        TableSaveName = sprintf('%s_RangeMean_%s.xlsx',DataIDName,SaveTime);
        
        % Writes the tables into an Excel document named TableSaveName.
        writetable(NanoMeanerTable,TableSaveName,'Sheet','BothAsStrings');
        writetable(NanoMeanerTableValues,TableSaveName,'Sheet','ValuesAsDoubles');
        writetable(NanoMeanerTableErrors,TableSaveName,'Sheet','ErrorsAsDoubles');
        fprintf('Auto-saved range mean tables!\n');
    else
        disp('You have chosen not to save the range mean table!');
        % Setting DataIDName to nan will then make NanoDataSave ask for
        % DataIDName when it runs.
        DataIDName = '';
    end
    

    
    fprintf('%s: Completed!\n',title);
end

%% Functions

% Self explanatory
function DataTypeToMean = ChooseDataToPlotAmmended(DataTypeList,PlotDataTypes)
    PromptString = {'Select what data to find depth range values:','Only one can be selected at once.'};
    [DataTypeToMean,~] = listdlg('PromptString',PromptString,'SelectionMode','single','ListString',DataTypeList);
    DataTypeToMean = PlotDataTypes(DataTypeToMean); % Gives the column number (/figure number) for the data to mean.
end

% This allows the user to choose a range over which the data will be aimed
% to mean across as close to the range as possible.
function AimedRange = AimedRangeProducer(DataTypeToMean,title,RangeSelectionMode)
    % Opens up the figure to choose the range with
    figure(DataTypeToMean);
    
    message1 = string(["Select the lower bound","Select the upper bound"]);
    message2 = string(["Type the lower bound","Type the upper bound"]);
    ExactX = nan(1,2);
    for i = 1:2
        switch RangeSelectionMode
            case 'Graphically'
                % This dialogue box helps the user choose the correct lower
                % or upper bound range values.
                GraphicalDiaglogue = helpdlg(message1(i),title);
                % Once the above message is closed the code continues.
                waitfor(GraphicalDiaglogue);
                % This allows the user to click and gets an x (depth)
                % value.
                [ExactX(i),~] = ginput(1);
            case 'Typed'
                % Allows the user to type in a value, which is a cell
                % that is converted into a double.
                ExactX(i) = str2double(inputdlg(message2(i),title,[1,50]));
            otherwise
                errordlg('No selection made for "RangeSelectionMode"!')
                return
        end
    end
    % The array of ExactX gets then set as the AimedRange
    AimedRange = ExactX;
end

function [RangeUsedString,ValuesAndErrorsString,RangeMeanValues,RangeErrorValues] = processDataInAimedRange(AimedRange,currValueData,~,w,NanoMeanerdDebugON)
%%%%%%%%%%%%%%%%%%%%%%%%%%% IMPORTANT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Before w is currErrorData it is set to ~ as the code currently
    % ignores the uncertainty in the input data!
    
    % XData is the bin midpoints.
    XData = currValueData(:,1);
    ClosestIndices = nan(2,1);
    UsedRange = nan(2,1);
    for i = 1:2
        % Below finds the indices closest to the aimed range and then
        % gets the nearest bin midpoints to use as the actual range.
        [~,ClosestIndices(i)] = min(abs(XData(:)-AimedRange(i)));
        UsedRange(i) = XData(ClosestIndices(i));
    end
    
    % The below two lines rearrange the data in ascending order, in case
    % the user clicked the upper and lower bounds in the incorrect order.
    UsedRange = sort(UsedRange,'ascend');
    ClosestIndices = sort(ClosestIndices,'ascend');
    
    % Using the closest indicices we get the data (excluding the bin
    % midpoints) which will be processed.
    DataToMean = currValueData(ClosestIndices(1):ClosestIndices(2),2:end);
    % The 1 in the two variables below means to mean and standard deviates
    % across the columns in DataToMean.
    BasicMeanOfValuesInRange = mean(DataToMean,1,'omitnan');
    BasicStdDevOfValuesInRange = std(DataToMean,w,1,'omitnan');
    
    % The below is set in case another method to obtain the values is made,
    % and then that can be switched e.g. using standard error rather than
    % standard deviation.
    RangeMeanValues = BasicMeanOfValuesInRange;
    RangeErrorValues = BasicStdDevOfValuesInRange;
    
    % The below generates strings to show what range was used in the end
    % and for what the values and their associated errors were.
    RangeUsedString = string(sprintf('%d-%d',UsedRange(1),UsedRange(2)));
    ValuesAndErrorsString = ValuesAndErrors2String(RangeMeanValues,RangeErrorValues);
    if NanoMeanerdDebugON
        fprintf('AimedRange = "%d-%d"\n',AimedRange(1),AimedRange(2));
        fprintf('RangeUsedString = "%s"\n',RangeUsedString);
        fprintf('ValuesAndErrorsString = "%s"\n',ValuesAndErrorsString);
    end
end

% This generates the sting which puts the values and errors for each sample
% into the format of "value+-error"
function ValuesAndErrorsString = ValuesAndErrors2String(RangeMeanValues,RangeErrorValues)
    Dimensions = size(RangeMeanValues);
    ValuesAndErrorsString = strings(Dimensions(1),Dimensions(2));
    for i = 1:Dimensions(2)
        ValuesAndErrorsString(i) = string(sprintf('%.3g+-%.3g',RangeMeanValues(i),RangeErrorValues(i)));
    end
end

% This updates the table named "Table" with the the data
function Table = AddingDataIntoTable(Table,CurrRowPosition,CurrentIDName,currSampleName,RangeUsedString,ValuesAndErrors)
    Table(CurrRowPosition,1) = table(CurrentIDName);
    Table(CurrRowPosition,2) = table(currSampleName);
    Table(CurrRowPosition,3) = table(RangeUsedString);
    for i = 1:length(ValuesAndErrors)
        Table(CurrRowPosition,3+i) = table(ValuesAndErrors(i));
    end
end