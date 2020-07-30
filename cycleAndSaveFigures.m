% Saving Figures

function cycleAndSaveFigures(DataIDName,figHandles,ImageFormatType,SaveTime,SavingData,dlg_title)
    NumOfFigures = length(figHandles);
    for i = 1:NumOfFigures
        CurrentFigureHandle = figHandles(i);
        FigureName = CurrentFigureHandle.Name;
        fprintf('Currently on figure "%s"...\n',FigureName);
        switch SavingData
            case 'auto'
                FigureSaveName = sprintf('%s_%s_%s',DataIDName,FigureName,SaveTime);
                saveas(CurrentFigureHandle,FigureSaveName,ImageFormatType);
                fprintf('Auto-saved figure "%s"...\n',FigureName);
            case 'semi-auto'
                message = sprintf('Name of file for "%s", will be saved as a ".%s"',FigureName,ImageFormatType);
                FigureSaveName = string(inputdlg(message,dlg_title,[1,50]));
                saveas(CurrentFigureHandle,FigureSaveName,ImageFormatType);
                fprintf('Semi-auto-saved figure "%s"...\n',FigureName);
        end
    end
end

% function cycleAndSaveFigures2(DataIDName,figHandles,ImageFormatType,SaveTime,SavingData,dlg_title)
%     NumOfFigures = length(figHandles);
%     for i = 1:NumOfFigures
%         CurrentFigureHandle = figHandles(i);
%         FigureName = CurrentFigureHandle.Name;
%         fprintf('Currently on figure "%s"...\n',FigureName);
%         switch SavingData
%             case 'auto'
%                 FigureSaveName = sprintf('%s_%s_%s',DataIDName,FigureName,SaveTime);
%                 saveas(CurrentFigureHandle,FigureSaveName,ImageFormatType);
%                 fprintf('Auto-saved figure "%s"...\n',FigureName);
%             case 'semi-auto'
%                 message = sprintf('Name of file for "%s", will be saved as a ".%s"',FigureName,ImageFormatType);
%                 FigureSaveName = string(inputdlg(message,dlg_title,[1,50]));
%                 saveas(CurrentFigureHandle,FigureSaveName,ImageFormatType);
%                 fprintf('Semi-auto-saved figure "%s"...\n',FigureName);
%         end
%     end
% end