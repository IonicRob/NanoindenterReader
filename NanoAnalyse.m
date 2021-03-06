%% NanoAnalyse
% By Robert J Scales Nov 2020

function NanoAnalyse(debugON,PlotAesthetics,DfltImgFmtType)
code_title = 'NanoAnalyse';

ListOfFunctions = {'NanoAnalyse_Cantilever_Stiffness','Exit'}; 
PromptString = 'What analysis method do you want to do?';
FunctionToUse = listdlg('ListString',ListOfFunctions,'PromptString',PromptString,'SelectionMode','single','Name',code_title);

if isempty(FunctionToUse) == true
    PopUp = warndlg('You have not chosen an action, hence the code will terminate.',code_title);
    waitfor(PopUp)
    return
end

FunctionToUse = ListOfFunctions{FunctionToUse};

switch FunctionToUse
    case 'NanoAnalyse_Cantilever_Stiffness'
        FormatAnswer = 'Line';
        NanoAnalyse_Cantilever_Stiffness(debugON,PlotAesthetics,FormatAnswer,DfltImgFmtType)
    otherwise
        errordlg('No action was chosen! Code will terminate...')
        return
end

end