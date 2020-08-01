%% NanoMeaner
% By Robert J Scales

function NanoMeaner(FileStuctures,figHandles,DataTypeList,PlotDataTypes,LOC_load,LOC_init)
    fprintf('NanoMeaner: Started!\n');
    
    NanoMeanerdDebugON = false;
    
    w = 0; 
    title = 'Nanoindentation Data Range Meaner';
    
    AmmendedDataTypeList = DataTypeList(PlotDataTypes(:));
    DataTypeToMean = ChooseDataToPlotAmmended(AmmendedDataTypeList,PlotDataTypes);
    
    NumberOfFiles = length(FileStuctures);
    
    figure(figHandles(DataTypeToMean));
    
    RangeSelectionMode = questdlg('Choose how to select the range to mean across',title,'Graphically','Typed','Typed');
    AimedRange = AimedRangeProducer(figHandles,DataTypeToMean,title,RangeSelectionMode);
    
    TotalNumOfSamples = 0;
    
    for FileNum = 1:NumberOfFiles
        CurrentIDName = FileStuctures{FileNum,1}.DataIDName;
        fprintf('Currently working on %s\n',CurrentIDName);
        ValueData = FileStuctures{FileNum,1}.ValueData;
        NumberOfSamples = size(ValueData,3);
        TotalNumOfSamples = TotalNumOfSamples + NumberOfSamples;
        clear CurrentIDName NumberOfSamples NumberOfSamples
    end
    
    fprintf('Total number of samples = %d\n',TotalNumOfSamples);
    
    TableVarNames = {'Data ID Name','Sample Name','Depth Range Used (nm)'};
    TableVarNames = horzcat(TableVarNames,DataTypeList);
    TableVarTypes = {'string','string','string','string','string','string','string','string'};
    NanoMeanerTable = table('Size',[TotalNumOfSamples,length(TableVarNames)],'VariableTypes',TableVarTypes,'VariableNames',TableVarNames);
    
    TableVarTypes = {'string','string','string','double','double','double','double','double'};
    NanoMeanerTableValues = table('Size',[TotalNumOfSamples,length(TableVarNames)],'VariableTypes',TableVarTypes,'VariableNames',TableVarNames);
    NanoMeanerTableErrors = table('Size',[TotalNumOfSamples,length(TableVarNames)],'VariableTypes',TableVarTypes,'VariableNames',TableVarNames);
    
    CurrRowPosition = 1;
    for FileNum = 1:NumberOfFiles
        CurrentIDName = FileStuctures{FileNum,1}.DataIDName;
        fprintf('Currently working on %s\n',CurrentIDName);
        ValueData = FileStuctures{FileNum,1}.ValueData;
        ErrorData = FileStuctures{FileNum,1}.ErrorData;
        SampleNameList = FileStuctures{FileNum,1}.SampleNameList;
        NumberOfSamples = size(ValueData,3);
        for i=1:NumberOfSamples
            currSampleName = SampleNameList(i);
            currValueData = ValueData(:,:,i);
            currErrorData = ErrorData(:,:,i);
            [RangeUsedString,ValuesAndErrorsString,RangeMeanValues,RangeErrorValues] = processDataInAimedRange(AimedRange,currValueData,currErrorData,w,NanoMeanerdDebugON);
            NanoMeanerTable = AddingDataIntoTable(NanoMeanerTable,CurrRowPosition,CurrentIDName,currSampleName,RangeUsedString,ValuesAndErrorsString);
            NanoMeanerTableValues = AddingDataIntoTable(NanoMeanerTableValues,CurrRowPosition,CurrentIDName,currSampleName,RangeUsedString,RangeMeanValues);
            NanoMeanerTableErrors = AddingDataIntoTable(NanoMeanerTableErrors,CurrRowPosition,CurrentIDName,currSampleName,RangeUsedString,RangeErrorValues);
            CurrRowPosition = CurrRowPosition + 1;
        end
    end
    
    quest = {'Save the range mean table data?:'};
    [SavingLocYN,LOC_save] = NanoSaveFolderPref(quest,LOC_init);
    if ~strcmp(SavingLocYN,'do not save data')
        cd(LOC_save);
        fprintf('Range mean table will be auto-saved...\n');
        SaveTime = datestr(datetime('now'),'yyyy-mm-dd-HH-MM');
        DataIDName = string(inputdlg('Choose the ID for this range mean data (NO odd symbols!):',title,[1,50]));
        TableSaveName = sprintf('%s_RangeBoth_%s.xlsx',DataIDName,SaveTime);
        TableSaveNameValues = sprintf('%s_RangeValues_%s.xlsx',DataIDName,SaveTime);
        TableSaveNameErrors = sprintf('%s_RangeErrors_%s.xlsx',DataIDName,SaveTime);
        writetable(NanoMeanerTable,TableSaveName);
        writetable(NanoMeanerTableValues,TableSaveNameValues);
        writetable(NanoMeanerTableErrors,TableSaveNameErrors);
        fprintf('Auto-saved range mean tables!\n');
    else
        disp('You have chosen not to save the range mean table!');
    end
    

    
    fprintf('NanoMeaner: Complete!\n');
end

%% Functions

function DataTypeToMean = ChooseDataToPlotAmmended(DataTypeList,PlotDataTypes)
    PromptString = {'Select what data to find depth range values:','Only one can be selected at once.'};
    [DataTypeToMean,~] = listdlg('PromptString',PromptString,'SelectionMode','single','ListString',DataTypeList);
    DataTypeToMean = PlotDataTypes(DataTypeToMean);
end

function AimedRange = AimedRangeProducer(figHandles,DataTypeToMean,title,RangeSelectionMode)
    figure(figHandles(DataTypeToMean));
    message1 = string(["Select the lower bound","Select the upper bound"]);
    message2 = string(["Type the lower bound","Type the upper bound"]);
    ExactX = nan(1,2);
    for i = 1:2
        switch RangeSelectionMode
            case 'Graphically'
                GraphicalDiaglogue = helpdlg(message1(i),title);
                waitfor(GraphicalDiaglogue);
                [ExactX(i),~] = ginput(1);
            case 'Typed'
                ExactX(i) = str2double(inputdlg(message2(i),title,[1,50]));
            otherwise
                errordlg({'Issue with "AimedRangeProducer"!';'No selection made for "RangeSelectionMode"!'})
                return
        end
    end
    AimedRange = ExactX;
end

% function AimedRange = GraphicalSelection(figHandles,DataTypeToMean,title)
%     figure(figHandles(DataTypeToMean));
%     message = string(["Select the lower bound","Select the upper bound"]);
%     ExactX = nan(1,2);
%     for i = 1:2
%         GraphicalDiaglogue = helpdlg(message(i),title);
%         waitfor(GraphicalDiaglogue);
%         [ExactX(i),~] = ginput(1);
%     end
%     AimedRange = ExactX;
% end
% 
% function AimedRange = TypedRangeSelection(figHandles,DataTypeToMean,title)
%     figure(figHandles(DataTypeToMean));
%     message = string(["Type the lower bound","Type the upper bound"]);
%     ExactX = nan(1,2);
%     for i = 1:2
%         ExactX(i) = str2double(inputdlg(message(i),title,[1,50]));
%     end
%     AimedRange = ExactX;
% end

function [RangeUsedString,ValuesAndErrorsString,RangeMeanValues,RangeErrorValues] = processDataInAimedRange(AimedRange,currValueData,~,w,NanoMeanerdDebugON)
    % Before w is currErrorData
    XData = currValueData(:,1);
    ClosestIndices = nan(2,1);
    UsedRange = nan(2,1);
    for i = 1:2
        [~,ClosestIndices(i)] = min(abs(XData(:)-AimedRange(i)));
        UsedRange(i) = XData(ClosestIndices(i));
    end
    UsedRange = sort(UsedRange,'ascend');
    ClosestIndices = sort(ClosestIndices,'ascend');
    DataToMean = currValueData(ClosestIndices(1):ClosestIndices(2),2:end);
    BasicMeanOfValuesInRange = mean(DataToMean,1,'omitnan');
    BasicStdDevOfValuesInRange = std(DataToMean,w,1,'omitnan');
    
    RangeMeanValues = BasicMeanOfValuesInRange;
    RangeErrorValues = BasicStdDevOfValuesInRange;
    
    RangeUsedString = string(sprintf('%d-%d',UsedRange(1),UsedRange(2)));
    ValuesAndErrorsString = ValuesAndErrors2String(RangeMeanValues,RangeErrorValues);
    if NanoMeanerdDebugON
        fprintf('AimedRange = "%d-%d"\n',AimedRange(1),AimedRange(2));
        fprintf('RangeUsedString = "%s"\n',RangeUsedString);
        fprintf('ValuesAndErrorsString = "%s"\n',ValuesAndErrorsString);
    end
end

function ValuesAndErrorsString = ValuesAndErrors2String(RangeMeanValues,RangeErrorValues)
    Dimensions = size(RangeMeanValues);
    ValuesAndErrorsString = strings(Dimensions(1),Dimensions(2));
    for i = 1:Dimensions(2)
        ValuesAndErrorsString(i) = string(sprintf('%.3g+-%.3g',RangeMeanValues(i),RangeErrorValues(i)));
    end
end

function NanoMeanerTable = AddingDataIntoTable(NanoMeanerTable,CurrRowPosition,CurrentIDName,currSampleName,RangeUsedString,ValuesAndErrorsString)
    NanoMeanerTable(CurrRowPosition,1) = table(CurrentIDName);
    NanoMeanerTable(CurrRowPosition,2) = table(currSampleName);
    NanoMeanerTable(CurrRowPosition,3) = table(RangeUsedString);
    NanoMeanerTable(CurrRowPosition,4) = table(ValuesAndErrorsString(1));
    NanoMeanerTable(CurrRowPosition,5) = table(ValuesAndErrorsString(2));
    NanoMeanerTable(CurrRowPosition,6) = table(ValuesAndErrorsString(3));
    NanoMeanerTable(CurrRowPosition,7) = table(ValuesAndErrorsString(4));
    NanoMeanerTable(CurrRowPosition,8) = table(ValuesAndErrorsString(5));
end