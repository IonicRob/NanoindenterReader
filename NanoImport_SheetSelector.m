%% NanoImport_SheetSelector
% By Robert J Scales 2020

function ListOfSheets = NanoImport_SheetSelector(SheetNames)
%%
fprintf('Started: NanoImport_SheetSelector\n');
code_title = 'NanoImport_SheetSelector';

ListOfSheets = listdlg('ListString',cellstr(SheetNames),'PromptString',PromptString,'SelectionMode','multiple','Name',code_title);
ListOfSheets = SheetNames{ListOfSheets};
fprintf('Finished: NanoImport_SheetSelector\n');
end
