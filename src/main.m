% =========================================================================
% main.m
% Entry point for the Budget Utility Tool.
% Run this file in MATLAB to launch the application.
%
% All project files must be in the same folder:
%   main.m
%   BudgetTool_GUI_Main.m
%   selectOutputDir.m
%   loadTransactionFile.m
%   analyzeTransactions.m
%   formatSummary.py
% =========================================================================

% Add the folder this file lives in to MATLAB's search path so all the
% helper scripts can find each other regardless of what your current
% working directory is.
scriptDir = fileparts(mfilename('fullpath'));
addpath(scriptDir);

% Launch the GUI
BudgetTool_GUI_Main();