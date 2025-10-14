% Custom MATLAB function written for MFE-Jr MADE script. 
% Last Update: May 16, 2025

function [result, subID] = extractSubjectID(filepath)
% EXTRACTSUBJECTID Extracts the subject ID from a filepath and returns the filepath without it
%
% Inputs:
%   filepath - A string containing a filepath with a subject ID in the format '/sub-XXXXXXX/'
%
% Outputs:
%   result - The filepath with the subject ID removed
%   subID - The extracted subject ID
%
% Example:
%   [result, subID] = extractSubjectID('/sub-3700001/sub-3700001_all_eeg_s1_r1_e1.vhdr')
%   % result = 'sub-3700001_all_eeg_s1_r1_e1.vhdr'
%   % subID = 'sub-3700001'

% Find the subject ID pattern using regular expressions
% This looks for patterns like '/sub-XXXXXXX/' where X can be any digit
[startIndex, endIndex, tokens] = regexp(filepath, '\/([^\/]+)\/', 'start', 'end', 'tokens');

% If no match found, return the original filepath
if isempty(startIndex)
    result = filepath;
    subID = '';
    fprintf('No subject ID found in the pattern "/sub-XXXXXXX/"\n');
    return;
end

% Extract the first match (in case there are multiple matches)
subID = tokens{1}{1};

% Remove the subject ID folder path from the filepath
result = filepath;
result(startIndex:endIndex-1) = [];

% Remove the leading forward slash if it exists
if ~isempty(result) && result(1) == '/'
    result = result(2:end);
end

% Print results for verification
fprintf('Original filepath: %s\n', filepath);
fprintf('Extracted subject ID: %s\n', subID);
fprintf('Modified filepath: %s\n', result);
end