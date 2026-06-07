% =========================================================================
% analyzeTransactions.m
%
% Reads a credit card transaction CSV, filters out payments, groups
% transactions by person and month, and writes a formatted Excel summary.
%
% Inputs:
%   transactionFile  - full path to the CSV file (string)
%   outputDir        - full path to the output folder (string)
%
% Output:
%   An Excel file written to outputDir named:
%   BudgetSummary_<YYYYMMDD_HHMMSS>.xlsx
%   One sheet per person, rows = months, columns = Total + each category.
% =========================================================================

function analyzeTransactions(transactionFile, outputDir)

    % ------------------------------------------------------------------
    % Guard: make sure both inputs were actually provided
    % ------------------------------------------------------------------
    if isempty(transactionFile)
        uialert(gcf, 'No transaction file selected.', 'Missing Input');
        return;
    end
    if isempty(outputDir)
        uialert(gcf, 'No output directory selected.', 'Missing Input');
        return;
    end

    fprintf('Loading: %s\n', transactionFile);

    % ------------------------------------------------------------------
    % HARD-CODED PERSON NAMES
    % Edit these to match the exact strings in your CSV "Card Member" column.
    % The key   = exactly what appears in the CSV
    % The value = the display name you want in the Excel output
    % ------------------------------------------------------------------
    personMap = containers.Map( ...
        {'PERSON1',    'PERSON 2'}, ...
        {'John Smith', 'Jane Smith'} ...
    );

    % ------------------------------------------------------------------
    % PAYMENT FILTER
    % Any row whose "Extended Details" column contains this phrase
    % (case-insensitive) will be excluded from all totals.
    % ------------------------------------------------------------------
    PAYMENT_PHRASE = 'MOBILE PAYMENT-THANK YOU';

    % ------------------------------------------------------------------
    % Load the CSV into a MATLAB table
    % readtable() reads every column header as a variable name.
    % ------------------------------------------------------------------
    opts = detectImportOptions(transactionFile);

    % Force Date column to come in as text so we can parse it ourselves.
    % (Auto-detection sometimes mangles MM/DD/YY formats.)
    opts = setvartype(opts, 'Date', 'char');
    opts = setvartype(opts, 'Amount', 'double');

    T = readtable(transactionFile, opts);

    % ------------------------------------------------------------------
    % Parse the Date column into MATLAB datetime
    % The CSV uses M/D/YY format (e.g. "6/4/26").
    % ------------------------------------------------------------------
    T.Date = datetime(T.Date, 'InputFormat', 'M/d/yy');

    % ------------------------------------------------------------------
    % Filter out payment rows
    % strcmpi = case-insensitive string compare; strtrim removes whitespace
    % ------------------------------------------------------------------
    isPayment = strcmpi(strtrim(T.ExtendedDetails), PAYMENT_PHRASE);
    T = T(~isPayment, :);   % keep only NON-payment rows

    fprintf('Rows after filtering payments: %d\n', height(T));

    % ------------------------------------------------------------------
    % Discover all unique months in the data, sorted oldest → newest
    % We extract Year and Month numbers, then sort on both.
    % ------------------------------------------------------------------
    T.Year  = year(T.Date);
    T.Month = month(T.Date);

    monthTable = unique(T(:, {'Year','Month'}), 'rows');
    monthTable = sortrows(monthTable, {'Year','Month'});   % oldest first

    numMonths = height(monthTable);

    % ------------------------------------------------------------------
    % Discover all unique categories (drop blanks — those are payments
    % we already filtered, but just in case)
    % ------------------------------------------------------------------
    allCategories = unique(T.Category(~cellfun(@isempty, T.Category)));
    allCategories = sort(allCategories);   % alphabetical
    numCats = numel(allCategories);

    % ------------------------------------------------------------------
    % Build the Excel workbook — one sheet per person
    % ------------------------------------------------------------------
    timestamp  = datestr(now, 'yyyymmdd_HHMMSS');
    outputFile = fullfile(outputDir, ['BudgetSummary_' timestamp '.xlsx']);

    csvPersons = keys(personMap);   % CSV name strings

    for p = 1 : numel(csvPersons)

        csvName     = csvPersons{p};
        displayName = personMap(csvName);

        % Filter table to just this person's rows
        personRows = strcmpi(strtrim(T.CardMember), csvName);
        Tp = T(personRows, :);

        % --------------------------------------------------------------
        % Build the summary matrix
        % Rows = months, Columns = [Total, cat1, cat2, ...]
        % --------------------------------------------------------------

        % Column headers for Excel
        colHeaders = [{'Month', 'Total'}, allCategories'];

        % Pre-allocate a numeric matrix of zeros (months × categories+1)
        % We'll fill it row by row.
        dataMatrix = zeros(numMonths, 1 + numCats);

        for m = 1 : numMonths

            yr  = monthTable.Year(m);
            mo  = monthTable.Month(m);

            % Rows for this person in this month
            monthRows = (Tp.Year == yr) & (Tp.Month == mo);
            Tpm = Tp(monthRows, :);

            % Column 1: grand total for the month
            dataMatrix(m, 1) = sum(Tpm.Amount);

            % Columns 2..end: sum per category
            for c = 1 : numCats
                catRows = strcmpi(strtrim(Tpm.Category), allCategories{c});
                dataMatrix(m, 1 + c) = sum(Tpm.Amount(catRows));
            end

        end

        % Build the month label column (e.g. "June 2026")
        monthLabels = cell(numMonths, 1);
        for m = 1 : numMonths
            monthLabels{m} = datestr( ...
                datetime(monthTable.Year(m), monthTable.Month(m), 1), ...
                'mmmm yyyy');
        end

        % Combine labels + numbers into a cell array for writing
        outputCell = [colHeaders; ...
                      [monthLabels, num2cell(dataMatrix)]];

        % --------------------------------------------------------------
        % Write to Excel
        % writecell() writes a cell array to a sheet.
        % The sheet name is the display name of the person.
        % --------------------------------------------------------------
        writecell(outputCell, outputFile, 'Sheet', displayName);

        fprintf('  Written sheet: %s\n', displayName);

    end

    % ------------------------------------------------------------------
    % Apply formatting via a Python helper script (see below)
    % This adds bold headers, currency formatting, and column widths.
    % ------------------------------------------------------------------
    formatScript = fullfile(fileparts(transactionFile), '');  % same folder
    pyScript = fullfile(fileparts(which('analyzeTransactions')), 'formatSummary.py');

    if isfile(pyScript)
        cmd = sprintf('python "%s" "%s"', pyScript, outputFile);
        [status, result] = system(cmd);
        if status ~= 0
            fprintf('Formatting note: %s\n', result);
        else
            fprintf('Formatting applied.\n');
        end
    end

    % ------------------------------------------------------------------
    % Done — alert the user
    % ------------------------------------------------------------------
    fprintf('Summary saved to: %s\n', outputFile);
    uialert(gcf, ...
        ['Summary saved to:' newline outputFile], ...
        'Analysis Complete');

end

