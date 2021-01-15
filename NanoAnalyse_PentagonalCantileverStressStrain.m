%% NanoAnalyse_PentagonalCantileverStressStrain
% By Robert J Scales 10/12/2020

function NanoAnalyse_PentagonalCantileverStressStrain
    %% Starting

    clc;
    close all
    dlg_title = mfilename;
    fprintf('%s: Started!\n\n',dlg_title);
    cd_init = cd;
    
    [debugON,~] = ifcalled;
    
    % This loads the ".mat" files produced by NanoDataCreater which the user
    % wishes to plot on the same figure.
    [FileStuctures,~,cd_load] = LoadingFilesFunc(debugON,'on');
    passTF = checkImportFileCompat(debugON,FileStuctures);

    %% Data Input
    
%     UserInputs = inputdlg({},'PentagonalCantileverStressStrain');

    %%
    
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
    
    
 
    %% With Strain
    clear
    clc
    close all
    HEIGHT_SQUARE = 10*10^-6; % Height of square bit
    WIDTH = 6*10^-6; % Width of square bit
    HEIGHT_TRI = 3*10^-6; % Height of triangle
    LENGTH_max = 10*10^-6; % Max Length of cantilever
    LENGTH_load = 1*10^-6; % Distance from edge of cantilever where the point force was actually applied
    FORCE = 10*10^-6; % The magnitude of the point force applied
    YM = 200*10^9; % The Young's modulus of the material.
    DISPS = 1*10^-6;
    
    Values_disps = [0,1,2,3,4,5,8,12,17]*10^-9;
    Values_loads = [0,2,4,6,8,10,11,12,12.5]*10^-6;
    
    syms P sigma L ybar I epsilon delta_max
    syms h1 h2 B
    syms a L_max E
    
    ybar = (h1.^2 + h2.*(h1+h2./3))/(2*h1 + h2);
    Equations2.ybar = latex(ybar);
    I = ( (B.*h1.^3)/12 + (B.*h1).*(ybar - h1./2).^2 ) + ( (B.*h2.^3)/36 + ((B.*h2)./2).*(ybar + h2/3 + h1).^2 );
    Equations2.I = latex(I);
    E = (P.*(L.^2).*(3*L_max-L))./(delta_max.*6*I);
    Equations2.delta_max = latex(delta_max);
    sigma = P.*L.*ybar./I;
    Equations2.sigma = latex(sigma);
    epsilon = sigma./E;

    
%     new_epsilon = subs(epsilon,[P,delta_max,L,L_max,h1,h2,B,E],[FORCE,DISPS,LENGTH_load,LENGTH_max,HEIGHT_SQUARE,HEIGHT_TRI,WIDTH,YM]);
%     new_sigma = subs(sigma,[P,L,L_max,h1,h2,B],[FORCE,LENGTH_load,LENGTH_max,HEIGHT_SQUARE,HEIGHT_TRI,WIDTH]);
    
    YoungModulus = symfun(E,[B,h1,h2,P,L,L_max,delta_max]);
    YMs = YoungModulus(WIDTH,HEIGHT_SQUARE,HEIGHT_TRI,Values_loads(2:end),LENGTH_load,LENGTH_max,Values_disps(2:end));
    
    try disp(double(YMs));
        disp('YMs Worked')
    catch
        disp('YMs No Worked')
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
    
    close all
%     figure();
%     fplot(new_epsilon(delta_max,LENGTH_load,LENGTH_max,HEIGHT_SQUARE,HEIGHT_TRI),[min(Values_disps),max(Values_disps)]);
%     ylabel('Strain'); xlabel('Disp');
%     figure();
%     fplot(new_sigma(P,LENGTH_load,LENGTH_max,HEIGHT_SQUARE,HEIGHT_TRI,WIDTH),[min(Values_loads),max(Values_loads)]);
%     ylabel('Stress'); xlabel('Load');
    figure();
    plot(Values_disps/10^-9,Values_loads/10^-6);
    ylabel('Loads (\muN)'); xlabel('Disps (nm)');
    figure();
    [scale,units] = yscaleunits(Stresses);
    plot(double(Strains)*100,double(Stresses)/scale);
    ylabel(sprintf('Stress (%s)',units)); xlabel('Strain (%)');
    
    %%
    
%     fplot(stress/10^6,[c_bottom,c_top]);
%     xlabel('Distance from cantilever centroid (m)');
%     ylabel('Stress (MPa)');
% 
%     figure;
%     fplot(strain/100,stress/10^6,[c_bottom,c_top]);
%     ylabel('Stress (MPa)');
%     xlabel('Strain (%)');
%     hold on
%     xline(0);
%     yline(0);
%     
%     stress_top = M.*c_top./I_x;
%     stress_bottom = -M.*c_bottom./I_x;
    

    

end


function [scale,units] = yscaleunits(Stresses)

    if max(double(Stresses))<=10^3
        scale = 10^3;
        units = 'kPa';
    elseif max(double(Stresses))<=10^6
        scale = 10^6;
        units = 'MPa';
    elseif max(double(Stresses))<=10^9
        scale = 10^9;
        units = 'GPa';
    else
        scale = 1;
        units = 'Pa';    
    end

end