%% f_scaleunits

function [scale,Unit] = f_scaleunits(InputData,BaseUnit)

    Input = mean(InputData);

    if Input <= 10^-9
        % pico
        scale = 10^-12;
        Unit = sprintf('p%s',BaseUnit);
    elseif (10^-9 < Input) && (Input <= 10^-6)
        % nano
        scale = 10^-9;
        Unit = sprintf('n%s',BaseUnit);
    elseif (10^-6 < Input) && (Input <= 10^-3)
        % micro
        scale = 10^-6;
        Unit = sprintf('u%s',BaseUnit);
    elseif (10^-3 < Input) && (Input <= 10^0)
        % milli
        scale = 10^-3;
        Unit = sprintf('m%s',BaseUnit);
    elseif (10^0 < Input) && (Input <= 10^3)
        % unit
        scale = 10^0;
        Unit = sprintf('%s',BaseUnit);
    elseif (10^3 < Input) && (Input <= 10^6)
        % kilo
        scale = 10^3;
        Unit = sprintf('k%s',BaseUnit);
    elseif (10^6 < Input) && (Input <= 10^9)
        % mega
        scale = 10^6;
        Unit = sprintf('M%s',BaseUnit);
    elseif (10^9 < Input) && (Input <= 10^12)
        % giga
        scale = 10^9;
        Unit = sprintf('G%s',BaseUnit);
    elseif (Input < 10^12)
        % terra
        scale = 10^12;
        Unit = sprintf('T%s',BaseUnit);
    end

%     if max(double(Stresses))<=10^3
%         scale = 10^3;
%         Unit = 'kPa';
%     elseif max(double(Stresses))<=10^6
%         scale = 10^6;
%         Unit = 'MPa';
%     elseif max(double(Stresses))<=10^9
%         scale = 10^9;
%         Unit = 'GPa';
%     else
%         scale = 1;
%         Unit = 'Pa';    
%     end

end