%% IfCalled Function
% Written by Robert J Scales

function [SelfTF,STLength] = ifcalled
    % dbstack() describes what functions are being called.
    ST = dbstack();
    STLength = length(ST);
    if STLength > 2
        % The below happens if this is being called from another function.
%         PopUp = helpdlg('Function is detected as NOT running by itself.');
%         waitfor(PopUp);
%         disp('Being called by func.')
        SelfTF =  false;
    else
        % The below happens if this function is being run by itself.
        PopUp = helpdlg('Function is detected as running by itself.');
        waitfor(PopUp);
        SelfTF = true;
    end
end