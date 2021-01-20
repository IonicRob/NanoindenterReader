%% NanoAnalyse_PentagonalCantileverStressStrain
% By Robert J Scales 10/12/2020

function NanoAnalyse_PentagonalCantileverStressStrain
    %% Starting

    clc;
    close all
    
    [debugON,~] = ifcalled;
    if debugON == true
        clearvars('-except','debugON');
    end
    
    
    dlg_title = mfilename;
    fprintf('%s: Started!\n\n',dlg_title);
    cd_init = cd;
    
    
    
%     loadForceDispTF = true;
%     
%     if loadForceDispTF == true
%         % This loads the ".mat" files produced by NanoDataCreater which the user
%         % wishes to plot on the same figure.
%         [FileStuctures,~,cd_load] = LoadingFilesFunc(debugON,'on');
%         passTF = checkImportFileCompat(debugON,FileStuctures);
%         [Values_disps,Values_loads] = obtainDispLoad(FileStuctures);
%     else
%         Values_disps = [0,1,2,3,4,5,8,12,17]*10^-9;
%         Values_loads = [0,2,4,6,8,10,11,12,12.5]*10^-6;
%     end


    % This loads the ".mat" files produced by NanoDataCreater which the user
    % wishes to plot on the same figure.
    [FileStuctures,~,cd_load] = LoadingFilesFunc(debugON,'on');
    passTF = checkImportFileCompat(debugON,FileStuctures);

    
    LoadDispFig = figure('Name','Load-Displacement');
    StressStrainFig = figure('Name','Stress-Strain');
    
    %% Main Section
   for i=1:length(FileStuctures)
        fprintf('Currently working on "%s"...\n',FileStuctures{i}.DataIDName);
        if i ==1
        [DispCol,DispPower,LoadCol,LoadPower] = obtainDispLoad(FileStuctures{i});
        end
        Data = FileStuctures{i}.ValueData;
        Values_disps = Data(:,DispCol)*DispPower;
        Values_loads = Data(:,LoadCol)*LoadPower;
   
        [scale_disp,Unit_disp] = f_scaleunits(Values_disps,'m');
        [scale_load,Unit_load] = f_scaleunits(Values_loads,'N');
        figure(LoadDispFig);
        plot(Values_disps/scale_disp,Values_loads/scale_load);
        xlabel(sprintf('Displacement (%s)',Unit_disp));
        ylabel(sprintf('Load (%s)',Unit_load));
        hold on

        %% Data Input

        loadDimsTF = true;

        if loadDimsTF == true

            InputLabels = {'Cross-section Square Height (um):';
                           'Cross-section Triangle Height (um):';
                           'Cross-section Width (um):';
                           'Loading Distance from Base (um):';
                           'Total Length of Cantilever (um):'};
            UserInputs = inputdlg(InputLabels,'PentagonalCantileverStressStrain');

            HEIGHT_SQUARE = str2double(UserInputs(1))*10^-6; % Height of square bit
            HEIGHT_TRI = str2double(UserInputs(2))*10^-6; % Height of triangle
            WIDTH = str2double(UserInputs(3))*10^-6; % Width of square bit
            LENGTH_load = str2double(UserInputs(4))*10^-6; % Distance from edge of cantilever where the point force was actually applied
            LENGTH_max = str2double(UserInputs(5))*10^-6; % Max Length of cantilever

        else
            HEIGHT_SQUARE = 1.042143252*10^-6; % Height of square bit
            HEIGHT_TRI = 1.296654267*10^-6; % Height of triangle
            WIDTH = 4.287*10^-6; % Width of square bit
            LENGTH_load = (18.519-1.255)*10^-6; % Distance from edge of cantilever where the point force was actually applied
            LENGTH_max = 18.519*10^-6; % Max Length of cantilever
        end


    %     figure();
    %     plot(Values_disps,Values_loads);
    %     ylabel('Loads (N)'); xlabel('Disps (m)');

    %     figure();
    %     plot(Values_disps/10^-9,Values_loads/10^-6);
    %     ylabel('Loads (\muN)'); xlabel('Disps (nm)');




        %% With Strain

        syms P sigma L ybar I epsilon delta_max
        syms h1 h2 B
        syms a L_max E

        ybar = (h1.^2 + h2.*(h1+h2./3))/(2*h1 + h2);
        Equations.ybar = latex(ybar);
        I = ( (B.*h1.^3)/12 + (B.*h1).*(ybar - h1./2).^2 ) + ( (B.*h2.^3)/36 + ((B.*h2)./2).*(ybar + h2/3 + h1).^2 );
        Equations.I = latex(I);
        E = (P.*(L.^2).*(3*L_max-L))./(delta_max.*6*I);
        Equations.E = latex(E);
        sigma = P.*L.*ybar./I;
        Equations.sigma = latex(sigma);
        epsilon = sigma./E;


    %     new_epsilon = subs(epsilon,[P,delta_max,L,L_max,h1,h2,B,E],[FORCE,DISPS,LENGTH_load,LENGTH_max,HEIGHT_SQUARE,HEIGHT_TRI,WIDTH,YM]);
    %     new_sigma = subs(sigma,[P,L,L_max,h1,h2,B],[FORCE,LENGTH_load,LENGTH_max,HEIGHT_SQUARE,HEIGHT_TRI,WIDTH]);

        YoungModulus = symfun(E,[B,h1,h2,P,L,L_max,delta_max]);
        try YoungModulus(WIDTH,HEIGHT_SQUARE,HEIGHT_TRI,Values_loads(1:end),LENGTH_load,LENGTH_max,Values_disps(1:end));
            YMs = YoungModulus(WIDTH,HEIGHT_SQUARE,HEIGHT_TRI,Values_loads(1:end),LENGTH_load,LENGTH_max,Values_disps(1:end));
            try disp(double(YMs));
                disp('YMs Worked')
            catch
                disp('YMs No Worked')
            end
        catch
            disp('YMs divided by zero displacment at one point most likely.');
        end



        new_sigma = symfun(sigma,[P,L,L_max,h1,h2,B]);
        new_epsilon = symfun(epsilon,[delta_max,L,L_max,h1,h2]);

        try disp(double(new_epsilon));
            disp('new_epsilon Worked')
        catch
            disp('new_epsilon No Worked')
        end

        try disp(double(new_sigma));
            disp('new_sigma Worked')
        catch
            disp('new_sigma No Worked')
        end



        Strains = new_epsilon(Values_disps,LENGTH_load,LENGTH_max,HEIGHT_SQUARE,HEIGHT_TRI);
        Stresses = new_sigma(Values_loads,LENGTH_load,LENGTH_max,HEIGHT_SQUARE,HEIGHT_TRI,WIDTH);

    %     figure();
    %     fplot(new_epsilon(delta_max,LENGTH_load,LENGTH_max,HEIGHT_SQUARE,HEIGHT_TRI),[min(Values_disps),max(Values_disps)]);
    %     ylabel('Strain'); xlabel('Disp');
    %     figure();
    %     fplot(new_sigma(P,LENGTH_load,LENGTH_max,HEIGHT_SQUARE,HEIGHT_TRI,WIDTH),[min(Values_loads),max(Values_loads)]);
    %     ylabel('Stress'); xlabel('Load');

        Strains = double(Strains);
        Stresses = double(Stresses);

        [scale_Stress,Unit_Stress] = f_scaleunits(Stresses,'Pa');
        figure(StressStrainFig);
        plot(Strains*100,Stresses/scale_Stress);
        xlabel('Strain (%)');
        ylabel(sprintf('Stress (%s)',Unit_Stress));
        hold on

        %% Saving

    %     [SavingLocYN,cd_save] = NanoSaveFolderPref('Analysed data save location?:',cd_init,cd_load);

        ValueData = [Strains;Stresses];
        ErrorData = nan(size(ValueData));
        w = 0;
        ErrorPlotMode = 'Standard deviation';
        varNames = {'Strain (%)',sprintf('Stress (%s)',Unit_Stress)};
        XDataCol = 1;
        method_name = 'NanoAnalyse_PentagonalCantileverStressStrain';
        SavingData = 'auto';

    %     [dataToSave] = NanoImport_Saving(debugON,ValueData,ErrorData,w,ErrorPlotMode,varNames,XDataCol,method_name,cd_init,SavingLocYN,cd_save,SavingData); % dataToSave
    %     
   end
end

%% Functions



function [DispCol,DispPower,LoadCol,LoadPower] = obtainDispLoad(FileStuctures)
    VarNames = FileStuctures.varNames;
    
    PromptString = 'Select the displacement column:';
    DispCol = listdlg('ListString',VarNames,'PromptString',PromptString,'SelectionMode','single');
    [DispPower,~] = f_UnitSelector(VarNames(DispCol));
    PromptString = 'Select the load column:';
    LoadCol = listdlg('ListString',VarNames,'PromptString',PromptString,'SelectionMode','single');
    [LoadPower,~] = f_UnitSelector(VarNames(LoadCol));
    fprintf('Calibrated importing data so the displacement is col-%d, and load is col-%d...\n',DispCol,LoadCol);
    
    
end

%% Old Code
    
%     HEIGHT_SQUARE = 5*10^-6; % Height of square bit
%     WIDTH = 6*10^-6; % Width of square bit
%     HEIGHT_TRI = 3*10^-6; % Height of triangle
%     LENGTH_max = 10*10^-6; % Max Length of cantilever
%     LENGTH_load = 1*10^-6; % Distance from edge of cantilever where the point force was actually applied
%     FORCE = 10*10^-6; % The magnitude of the point force applied
%     YM = 200*10^9; % The Young's modulus of the material.
%     
%     
%     
%     syms P sigma L ybar I
%     syms h1 h2 B
%     syms a L_max E
%     
% %     sigma = P.*L.*ybar./I;
% %     Equations.sigma = latex(sigma);
% %     delta_max = -1.*P.*(L.^2).*(3*L_max-L)./(6*E.*I);
% %     Equations.delta_max = latex(delta_max);
% %     I = ( (B.*h1.^3)/12 + (B.*h1).*(ybar - h1./2).^2 ) + ( (B.*h2.^3)/36 + ((B.*h2)./2).*(ybar + h2/3 + h1).^2 );
% %     Equations.I = latex(I);
% %     ybar = (h1.^2 + h2.*(h1+h2./3))/(2*h1 + h2);
% %     Equations.ybar = latex(ybar);
%     
%     ybar = (h1.^2 + h2.*(h1+h2./3))/(2*h1 + h2);
%     Equations2.ybar = latex(ybar);
%     I = ( (B.*h1.^3)/12 + (B.*h1).*(ybar - h1./2).^2 ) + ( (B.*h2.^3)/36 + ((B.*h2)./2).*(ybar + h2/3 + h1).^2 );
%     Equations2.I = latex(I);
%     delta_max = -1.*P.*(L.^2).*(3*L_max-L)./(6*E.*I);
%     Equations2.delta_max = latex(delta_max);
%     sigma = P.*L.*ybar./I;
%     Equations2.sigma = latex(sigma);
% 
% 
% %     new_ybar = subs(ybar,[h1,h2],[A,C]);
% %     disp(double(new_ybar));
% %     new_I = subs(I,[B,h1,h2,ybar],[WIDTH,A,C,new_ybar]);
% %     disp(double(new_I));
% %     new_delta_max = subs(delta_max,[P,L,L_max,E,I],[FORCE,Y,D,YM,new_I]);
% %     disp(double(new_delta_max));
% %     new_sigma = subs(sigma,[P,L,ybar,I],[FORCE,Y,new_ybar,new_I]);
% %     disp(double(new_sigma));
%     
% %     new_delta_max = subs(delta_max,[P,L,L_max,h1,h2,B,E],[FORCE,LENGTH_load,LENGTH_max,HEIGHT_SQUARE,HEIGHT_TRI,WIDTH,YM]);
% %     disp(double(new_delta_max));
% %     new_sigma = subs(sigma,[P,L,L_max,h1,h2,B],[FORCE,LENGTH_load,LENGTH_max,HEIGHT_SQUARE,HEIGHT_TRI,WIDTH]);
% %     disp(double(new_sigma));
%     
%     new_delta_max = subs(delta_max,[L,L_max,h1,h2,B,E],[LENGTH_load,LENGTH_max,HEIGHT_SQUARE,HEIGHT_TRI,WIDTH,YM]);
%     new_sigma = subs(sigma,[L,L_max,h1,h2,B],[LENGTH_load,LENGTH_max,HEIGHT_SQUARE,HEIGHT_TRI,WIDTH]);
%     
%     try disp(double(new_delta_max));
%         disp('Worked')
%     catch
%         disp('No Worked')
%     end
%     
%     try disp(double(new_sigma));
%         disp('Worked')
%     catch
%         disp('No Worked')
%     end
%     
%     close all
% %     fplot(new_delta_max,[0,20]*10^-6)
% %     figure();
% %     fplot(new_sigma,[0,20]*10^-6);
%     figure();
%     fplot(new_delta_max,new_sigma,[0,20]*10^-6);
    