% =========================================================================
% BudgetTool_GUI_Main.m
% Builds the GUI window and wires up all three button callbacks.
% =========================================================================

function handles = BudgetTool_GUI_Main()

    % ---------------------------------------------------------------------
    % Initialize the GUI parent figure.
    % ---------------------------------------------------------------------

    fig = uifigure( ...
        'Name',     'Budget_Utility', ...
        'Position', [100 100 420 340], ...
        'Resize',   'off', ...
        'Color',    [0.15 0.15 0.15] ...
    );

    % Initialize shared state on the figure "whiteboard."
    % Every callback reads/writes here via getappdata/setappdata.
    % We set both keys to empty now so they always exist before any
    % callback runs.
    setappdata(fig, 'outputDir',       '');
    setappdata(fig, 'transactionFile', '');

    handles.fig = fig;

    % ---------------------------------------------------------------------
    % Layout Constants
    % ---------------------------------------------------------------------

    LEFT        = 20;
    WIDTH       = 380;
    BUTTON_H    = 42;
    FIELD_H     = 36;
    GAP         = 12;
    TOP_MARGIN  = 20;
    FIG_H       = 340;

    curY = FIG_H - TOP_MARGIN;

    % Moves layout cursor down by one control height + gap, returns new Y.
    function y = nextY(controlH)
        curY = curY - controlH - GAP;
        y    = curY;
    end

    % Consistent dim section label.
    function makeLabel(txt, y)
        uilabel(fig, ...
            'Text',             txt, ...
            'Position',         [LEFT, y, WIDTH, 18], ...
            'FontSize',         10, ...
            'FontColor',        [0.65 0.65 0.65], ...
            'FontWeight',       'bold', ...
            'BackgroundColor',  [0.15 0.15 0.15] ...
        );
    end

    % ---------------------------------------------------------------------
    % 1. OUTPUT DIRECTORY
    % ---------------------------------------------------------------------

    makeLabel('Output Directory', nextY(18));

    fieldW  = 240;
    btnW2   = 130;
    spacing = 10;

    handles.outputDirField = uitextarea(fig, ...
        'Position',         [LEFT, nextY(FIELD_H), fieldW, FIELD_H], ...
        'Value',            'No Output Directory Selected', ...
        'Editable',         'off', ...
        'FontSize',         11, ...
        'FontColor',        [0.85 0.85 0.85], ...
        'BackgroundColor',  [0.22 0.22 0.22] ...
    );

    fieldY = curY;  % capture Y so the button sits on the same row

    handles.btnOutputDir = uibutton(fig, ...
        'Text',             'Specify Output Directory', ...
        'Position',         [LEFT + fieldW + spacing, fieldY, btnW2, FIELD_H], ...
        'FontSize',         10, ...
        'FontWeight',       'bold', ...
        'BackgroundColor',  [0.20 0.45 0.75], ...
        'FontColor',        [1 1 1], ...
        'ButtonPushedFcn',  @(btn,evt) cb_selectOutputDir() ...
    );

    % ---------------------------------------------------------------------
    % Divider
    % ---------------------------------------------------------------------

    makeLabel('________________________________', nextY(14) - 4);

    % ---------------------------------------------------------------------
    % 2. LOAD TRANSACTION FILE
    % ---------------------------------------------------------------------

    makeLabel('Load Transaction File', nextY(14) - 4);

    handles.btnLoadTransactions = uibutton(fig, ...
        'Text',             'Load Transaction File', ...
        'Position',         [LEFT, nextY(BUTTON_H), WIDTH, BUTTON_H], ...
        'FontSize',         13, ...
        'FontWeight',       'bold', ...
        'BackgroundColor',  [0.18 0.52 0.35], ...
        'FontColor',        [1 1 1], ...
        'ButtonPushedFcn',  @(btn,evt) cb_loadTransactionFile() ...
    );

    % ---------------------------------------------------------------------
    % Divider
    % ---------------------------------------------------------------------

    makeLabel('______________________________', nextY(14) - 4);

    % ---------------------------------------------------------------------
    % 3. ANALYZE TRANSACTIONS
    % ---------------------------------------------------------------------

    makeLabel('Analyze Transactions', nextY(14) + 4);

    handles.btnRunAnalysis = uibutton(fig, ...
        'Text',             'Analyze Transactions', ...
        'Position',         [LEFT, nextY(BUTTON_H), WIDTH, BUTTON_H], ...
        'FontSize',         13, ...
        'FontWeight',       'bold', ...
        'BackgroundColor',  [0.18 0.52 0.35], ...
        'FontColor',        [1 1 1], ...
        'ButtonPushedFcn',  @(btn,evt) cb_analyzeTransactions() ...
    );


    % =====================================================================
    % NESTED CALLBACKS
    % These live INSIDE BudgetTool_GUI_Main, so they automatically see
    % 'fig' and 'handles' without needing them passed as arguments.
    % =====================================================================

    function cb_selectOutputDir()

        chosenDir = selectOutputDir();

        if isempty(chosenDir)
            return;  % user cancelled — leave everything as it was
        end

        setappdata(fig, 'outputDir', chosenDir);
        handles.outputDirField.Value = chosenDir;

        fprintf('[cb_selectOutputDir] Output directory set to: %s\n', chosenDir);

        drawnow;
        figure(fig);

    end % cb_selectOutputDir


    function cb_loadTransactionFile()

        chosenFile = loadTransactionFile();

        if isempty(chosenFile)
            return;  % user cancelled — do nothing
        end

        setappdata(fig, 'transactionFile', chosenFile);

        % Show just the filename on the button (not the full path)
        [~, fname, ext] = fileparts(chosenFile);
        handles.btnLoadTransactions.Text = ['Loaded: ' fname ext];

        fprintf('[cb_loadTransactionFile] File set to: %s\n', chosenFile);

        drawnow;
        figure(fig);

    end % cb_loadTransactionFile


    function cb_analyzeTransactions()

        % Read both values off the shared whiteboard
        transactionFile = getappdata(fig, 'transactionFile');
        outputDir       = getappdata(fig, 'outputDir');

        % Guard: don't proceed if either is missing
        if isempty(transactionFile)
            uialert(fig, ...
                'Please load a transaction file before running analysis.', ...
                'Missing File');
            return;
        end

        if isempty(outputDir)
            uialert(fig, ...
                'Please specify an output directory before running analysis.', ...
                'Missing Directory');
            return;
        end

        fprintf('[cb_analyzeTransactions] Running analysis...\n');
        analyzeTransactions(transactionFile, outputDir);

        drawnow;
        figure(fig);

    end % cb_analyzeTransactions


end % BudgetTool_GUI_Main






