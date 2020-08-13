%% changeBinBoundaries

function [DepthLimit,bin_boundaries,binWidth] = changeBinBoundaries(DepthLimit,binWidth,bins)

    if strcmp(mode,'qs') == true
        message = sprintf('Change depth limit?\nCurrent depth limit = %3.dnm & bin width = %3.dnm',DepthLimit, binWidth);
        ManualBoundaries = questdlg(message,title,'Yes','No','No');
        switch ManualBoundaries
            case 'Yes'
                disp('Boundaries are being changed manually!');
                [DepthLimit,bin_boundaries,binWidth] = changeBinBoundaries_Main(DepthLimit,binWidth,bins);
            case 'No'
                disp('Boundaries are unchanged from standard...');
        end
    end

end
%% Nested Functions
function [new_DepthLimit,new_bin_boundaries,new_binWidth] = changeBinBoundaries_Main(DepthLimit,binWidth,bins)
    title = 'Changing maximum bin depth limit';
    Row1 = sprintf('Enter new depth limit \n(old limit = %3.dnm  ... Num of bins = %d)',DepthLimit,bins);
    Row2 = sprintf('OR Enter bin width \n(old width = %3.dnm ... Num of bins = %d)',binWidth,bins);
    newDL = inputdlg({Row1,Row2},title,[1,70;1,70]);
    if isempty(newDL) == true
        errordlg('No new depth limit or bin widthchosen!');
        new_DepthLimit = nan; new_bin_boundaries= nan; new_binWidth = nan;
        return
    elseif isempty(newDL{1}) == false
        new_DepthLimit = str2double(string(newDL{1}));
        new_binWidth = new_DepthLimit/bins;
        new_bin_boundaries = transpose(linspace(0,new_DepthLimit,bins+1));
        message = sprintf('New depth limit = %3.dnm ... New bin width = %3.dnm)',new_DepthLimit,new_binWidth);
        DLG = helpdlg(message);
    elseif isempty(newDL{1}) == true && isempty(newDL{2}) == false
        new_binWidth = str2double(string(newDL{2}));
        new_DepthLimit = new_binWidth*bins;
        new_bin_boundaries = transpose(linspace(0,new_DepthLimit,bins+1));
        message = sprintf('New depth limit = %3.dnm ... New bin width = %3.dnm)',new_DepthLimit,new_binWidth);
        DLG = helpdlg(message);
    else
        errordlg()
    end
    waitfor(DLG);
end