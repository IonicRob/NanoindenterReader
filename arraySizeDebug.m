function arraySizeDebug(array,name)
%     NumOfDims = ndims(array);
    [A1,A2,A3] = size(array);
    fprintf('%s size = %d x %d x %d\n',name,A1,A2,A3);
end