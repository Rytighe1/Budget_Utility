% =========================================================================
% 3. ANALYZE TRANSACTION FILE
% =========================================================================

function transData = analyzeTransactions(chosenFile)

    [~, ~, ext] = fileparts(chosenFile);

    if strcmpi(ext, '.csv')
        raw = readcell(filepath, 'Delimiter', '.csv');
    else
        raw = readcell(filepath);
    end

    headerRow = 1
    headers = raw(headerRow, :);
    headers    = cellfun(@(h) strtrim(string(h)), headers);   % clean strings

