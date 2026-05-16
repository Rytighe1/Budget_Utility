% =========================================================================
% This script defines the GUI for the Budget_Utility script. 
% GUI to prompt user to:
%   1. Specify an output directory for a summary results file. 
%   2. Specify an input CSV file. 
%   3. Generate a summary report. 
% =========================================================================

function handles = BudgetTool_GUI_Main()

    % ---------------------------------------------------------------------
    % Initialize the GUI parent figure. 
    % ---------------------------------------------------------------------

    fig = uifigure( ...e
        'Name',     'Budget_Utility', ...
        'Position', [100 100 420 340], ...
        'Resize',   'off', ...
        'Color',    [0.15 0.15 0.15] ...
    );

    % Assign fig to handles immediately so all button callbacks that close 
    % over handles can reference handles.fig immediately. 

    handles.fig = fig;
    handles.transactionFiles = {};
    handles.outputDir = '';
    handles.analyzeTransactions = [];

    % ---------------------------------------------------------------------
    % Layout Constants
    % ---------------------------------------------------------------------

    LEFT =          20;     % Left Margin
    WIDTH =         380;    % Button Width
    BUTTON_H =      42;     % Button Height
    FIELD_H =       36;     % Height of Output Directory field
    GAP =           12;     % Gap between buttons
    TOP_MARGIN =    20;     % Spacing from top of figure
    FIG_H =         340;    % Pixel height of overall figure

    % Building top to bottom - set constants for current y

    curY = FIG_H - TOP_MARGIN;

    % Helper function to align next set of congrols down by a control
    % height followed by a constant gap (GAP = 12 set above). 

    function y = nextY(controlH)
        
        curY = curY - controlH - GAP;
        y = curY;

    end

    % ---------------------------------------------------------------------
    % Section Label Helper Function
    % Sets consistent labels with input text at position y. 
    % ------------------------------------------------------------------
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
    % Un-Editable display field + user select button side-by-side top GUI
    % ---------------------------------------------------------------------

    makeLabel('Output Directory',nextY(18));

    fieldW =    240;
    btnW2 =     130;  
    spacing =   10;

    handles.outputDirField = uitextarea(fig, ...
        'Position',         [LEFT, nextY(FIELD_H), fieldW, FIELD_H], ...
        'Value',            'No Output Directory Selected', ...
        'Editable',         'off', ...
        'FontSize',         11, ...
        'FontColor',        [0.85 0.85 0.85], ...
        'BackgroundColor',  [0.22 0.22 0.22] ...
    );

    % Set output directory button next to text area field. 

    fieldY = curY;  %Same row

    handles.btnOutputDir = uibutton(fig, ...
        'Text',             'Specify Output Directory', ...
        'Position',         [LEFT + fieldW + spacing, fieldY, btnW2, FIELD_H], ...
        'FontSize',         10, ...
        'FontWeight',       'bold', ...
        'BackgroundColor',  [0.20 0.45 0.75], ...
        'FontColor',        [1 1 1], ...
        'ButtonPushedFcn',  @(btn,evt) cb_selectOutputDir(handles) ...
     );

    % ---------------------------------------------------------------------
    % Divider
    % ---------------------------------------------------------------------

    makeLabel('________________________________', nextY(14) - 4);

    % ---------------------------------------------------------------------
    % 2. BUTTON TO LOAD TRANSACTION FILE
    % ---------------------------------------------------------------------
    
    makeLabel('Load Transaction File', nextY(14) - 4);

    handles.btnLoadTransactions = uibutton(fig, ...
        'Text',             'Load Transaction File', ...
        'Position',         [LEFT, nextY(BUTTON_H), WIDTH, BUTTON_H], ...
        'FontSize',         13, ...
        'FontWeight',       'bold', ...
        'BackgroundColor',  [0.18 0.52 0.35], ...
        'FontColor',        [ 1 1 1], ...
        'ButtonPushedFcn',  @(btn,evt) cb_loadTransactionFile(handles) ...
    );

    % ---------------------------------------------------------------------
    % Divider Label
    % ---------------------------------------------------------------------

    makeLabel('______________________________', nextY(14) - 4);

    % ---------------------------------------------------------------------
    % 3. RUN ANALYSIS
    % ---------------------------------------------------------------------

    makeLabel('Analyze Transactions', nextY(14) + 4);

    handles.btnRunAnalysis = uibutton(fig, ...
        'Text',             'Analyze Transactions', ...
        'Position',         [LEFT, nextY(BUTTON_H), WIDTH, BUTTON_H], ...
        'FontSize',         13, ...
        'FontWeight',       'bold', ...
        'BackgroundColor',  [0.18 0.52 0.35], ...
        'FontColor',        [1 1 1], ...
        'ButtonPushedFcn',  @(btn,evt) cb_analyzeTransactions(handles) ...
    );

    % =========================================================================
    % CALLBACKS for Button Events
    % =========================================================================
            
    function cb_selectOutputDir(handles)
        % Call helper script - opens the folder picker and tereturn the
        % path or '' if user cancelled. 

        chosenDir = selectOutputDir();

        if isempty(chosenDir)
            % user hit cancel - leave everything as it was. 
            return;
        end
        
        % Save to the shared whiteboard so cb_analyzeTransactions can read
        % it later. 
        setappdata(fig, 'outputDir', chosenDir);

        % Update text area to display file path
        handles.outputDirField.Value = chosenDir;

        fprintf('[cb_selectOutputDir] set to: %s\n', chosenDir)

        drawnow;
        figure(fig);

    end

    function cb_loadTransactionFile(handles)
        % Call helper script - opens the file picker, returns full path
        % or '' on cancel. 

        chosenFile = loadTransactionFile();

        if isempty(chosenFile)
            return; % user cancelled - do nothing. 
        end

        % Pin the path to the shared 'whiteboard.' 
        setappdata(fig, 'transactionFile', chosenFile);

        % Give visual feedback: flash the button text to show the filename. 
        [~, fname, ext] = fileparts(chosenFile); % split path / folder / name/ .ext
        handles.btnLoadTransactions.Text = ['Loaded: ',fname, ext]; 

        fprintf('[cb_loadTrnsactionFile] File set to: %s\n', chosenFile);

    end % cb_loadTransactionFile



    function cb_analyzeTransactions(handles)
        % TODO - Define Callback
        disp('[cb_analyzeTransactions not yet defined.')
    end

end % Budget_Tool_GUI_Main






