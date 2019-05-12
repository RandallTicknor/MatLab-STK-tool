%Reads in the failure inputs
%INPUTS
%   failFile: fial containing the failure inputs

%OUTPUTS
%   failModes: cell array of failures

function [failModes] = failInputRead(failFile)

% ---------------------------------------
% LOAD DATA FROM FAILURE INPUT FILE
fileID = fopen(failFile,'r');
format = ['%s',repmat('%f',[1,2])];
data = textscan(fileID, format,'Delimiter',{','},'CommentStyle',{'%'},'HeaderLines',1,'MultipleDelimsAsOne',1); 
fclose(fileID);

% ---------------------------------------
% FORMAT FAILURE MODES
failModes = cell(size(data{1},1),1); 
for i = 1:size(data{1},1)
    failModes{i} = {cell(1,3)};
    for j = 1:3
        failModes{i}{j} = data{j}(i);
    end
end





