%% UnitSelector

function [EngineeringPower,PowerSymbol] = f_UnitSelector(SinglevarName)
        InputLabels = {'10^-12 (pico)';
                       '10^-9 (nano):';
                       '10^-6 (micro):';
                       '10^-3 (milli):';
                       '10^0 (unit):';
                       '10^3 (kilo):';
                       '10^6 (mega):';
                       '10^9 (giga):';
                       '10^12 (tera):'};
                   
        PowerSymbols = ['p','n','u','m','','k','M','G','T'];
        Powers = [10^-12,10^-9,10^-6,10^-3,10^0,10^3,10^6,10^9,10^12];
        
        PromptString = {'Choose the unit associated with:';SinglevarName};
        Choice = listdlg('ListString',InputLabels,'PromptString',PromptString,'SelectionMode','single');
        EngineeringPower = Powers(Choice);
        PowerSymbol = PowerSymbols(Choice);
end