%% Standard Deviation Weighting Mode

% This sets the weighting mode (w) to the appropriate numerical value based
% on the mode chosen. For more information look up the standard deviation
% Matlab documentation. Typically it is 'N-1' I believe i.e. w = 0.
function w = wGenerator(StdDevWeightingMode)

    switch StdDevWeightingMode
        case 'N-1'
            w = 0;
        case 'N'
            w = 1;
        case 'Using bin errors'
            w = 0; % Need to update this!!
        case ''
            w = 0;
    end
    
end