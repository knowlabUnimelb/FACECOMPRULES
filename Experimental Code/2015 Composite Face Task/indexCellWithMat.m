function idx = indexCellWithMat(cellMatrix, index)
idx = cellfun(@isequal, cellMatrix, mat2cell(repmat(index, size(cellMatrix,1), 1), ones(size(cellMatrix, 1), 1), 1));