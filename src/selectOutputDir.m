% =====================================
% 1. LOAD OUTPUT DIRECTORY
% =====================================

function selectedDir = selectOutputDir()

    selectedDir = uigetdir(pwd, 'Select Output Directory');

    % uigetdir returns 0 (a number, not a string) if the user hits Cancel.
    % Convert that to '' so callers always get a string back. 

    if isequal (selectedDir, 0)
        selectedDir = ''; %User canceled. 
    end
    

end


