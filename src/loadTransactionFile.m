% ======================================
% 2. USER SELECTS TRANSACTION CSV FILE
% ======================================

function selectedFile = loadTransactionFile()
    filterspec = {'*.csv;*.xlsx','CSV/Excel Files (*.csv/*.xlsx)'};

    [fname, fpath] = uigetfile (filterspec, 'Select Transaction File');

    if isequal(fname, 0)
        return; % User canceled
    end

    selectedFile = fullfile(fpath, fname);

end



