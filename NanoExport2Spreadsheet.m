%% NanoExport2Spreadsheet by Robert R J Scales
% "Export" is an option to convert the information stored in the structures
% from "import" into an Excel spreadsheet. This can allow one to do other
% analysis that is not currently available to the current version of the
% code, OR send the code to someone without Matlab (or who lacks the
% knowledge) so that they can work on it. 
% It stores the relevent details on the analysis on the first page so that
% the user knows how the data was treated.

function NanoExport2Spreadsheet(debugON)
%%
    title = 'NanoExport2Spreadsheet';
    fprintf('%s: Started!\n',title); 
    cd_init = cd; % Initial directory
    
    
    [FileStuctures,~,cd_load] = LoadingFilesFunc(debugON,'off');
    IDName = FileStuctures{1}.DataIDName;
    ValueData = FileStuctures{1}.ValueData;
    ErrorData = FileStuctures{1}.ErrorData;
    varNames = FileStuctures{1}.varNames;
    w = FileStuctures{1}.w;
    ErrorUsed = FileStuctures{1}.ErrorPlotMode;
    method_name = FileStuctures{1}.method_name;
    
    varTypes    = cell(1,size(ValueData,2));
    varTypes(:) = {'double'};
    VETemplateTable = table('Size',size(ValueData),'VariableTypes',varTypes,'VariableNames',varNames);
    
    ValueTable = VEFillFunc(VETemplateTable,ValueData);
    ErrorTable = VEFillFunc(VETemplateTable,ErrorData);
    
    detailsTableNames = {'method_name','DataIDName','w (stdev weighting)','ErrorUsed'};
    detailsTableTypes = {'string','string','double','string'};
    detailsTable = table('Size',[1,length(detailsTableNames)],'VariableTypes',detailsTableTypes,'VariableNames',detailsTableNames);
    detailsTable(:,1) = table(method_name);
    detailsTable(:,2) = table(IDName);
    detailsTable(:,3) = table(w);
    detailsTable(:,4) = table(string(ErrorUsed));
    
    quest = sprintf('Export the data for "%s" as an Excel spreadsheet?:',IDName);
    [SavingLocYN,cd_save] = NanoSaveFolderPref(quest,cd_init,cd_load);
    if ~strcmp(SavingLocYN,'do not save data')
        cd(cd_save);
        SaveTime = datestr(datetime('now'),'yyyy-mm-dd-HH-MM');
        SpreadSheetSaveName = sprintf('%s_%s_Export.xlsx',IDName,SaveTime);
        writetable(detailsTable,SpreadSheetSaveName,'Sheet','Details');
        writetable(ValueTable,SpreadSheetSaveName,'Sheet','ValuesAsDoubles');
        writetable(ErrorTable,SpreadSheetSaveName,'Sheet','ErrorsAsDoubles');
        fprintf('Auto-exported "%s"!\n',IDName);
        cd(cd_init)
    else
        fprintf('The data for "%s" was not exported!\n',IDName);
    end
    
    fprintf('%s: Completed!\n',title);  
end

%%
function OutTable = VEFillFunc(InTable,InData)
    for i = 1:size(InData,2)
        InTable(:,i) = table(InData(:,i));
    end
    OutTable = InTable;
end