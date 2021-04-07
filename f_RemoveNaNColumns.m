%% Remove NaN Columns
% By Robert J Scales 01/03/2021

function [output,output_XDataCol,idx] = f_RemoveNaNColumns(input,input_XDataCol)
    idx = find(all(isnan(input),1)); % https://uk.mathworks.com/matlabcentral/answers/341956-how-to-find-row-column-indices-having-all-values-nan
    output = input;
    output(:,idx) = [];
    fprintf('f_RemoveNaNColumns: Number of NaN columns found = %d\n', length(idx));
    if ~isempty(input_XDataCol)
        TF_array = nan(size(output,2),1);
        for i=1:size(output,2)
            TF_array(i) = all(output(:,i)==input(:,input_XDataCol));
        end
        output_XDataCol = find(TF_array, 1);
        if isempty(output_XDataCol)
            warning('Could not find matching XDataCol column. Empty value for "output_XDataCol" is given!');
        end
    else
        warning('"input_XDataCol" not inputted. Hence "output_XDataCol" will be empty.');
        output_XDataCol = [];
        TF_array = [];
    end
end