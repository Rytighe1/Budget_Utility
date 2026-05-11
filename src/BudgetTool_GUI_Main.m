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

    fig = uifigure( ...
        'Name',     'Budget_Utility', ...
        'Position', [100 100 420 254], ...
        'Resize',   'off', ...
        'Color',    [0.15 0.15 0.15] ...
    );

    % Assign fig to handles immediately so all button callbacks that close 
    % over handles can reference handles.fig immediately. 

    handles.fig = fig;
    handles.budgetFiles = {};
    handles.outputDir = '';
    handles.analysisResults = [];

    % ---------------------------------------------------------------------
    % Layout Constants
    % ---------------------------------------------------------------------

    LEFT =          20;     % Left Margin
    WIDTH =         380;    % Button Width
    BUTTON_H =      42;     % Button Height
    FIELD_H =       36;     % Height of Output Directory field
    GAP =           12;     % Gap between buttons
    TOP_MARGIN =    20;     % Spacing from top of figure


