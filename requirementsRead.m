%Reads in data from requirements file
%INPUTS
%   requirementsFile: file with consteliation requirements

%OUTPUTS
%   requirements: cell array of requirements

function [requirements] = requirementsRead(requirementsFile)
% LOAD DATA FROM REQUIREMENTS INPUT FILE

fileID = fopen(requirementsFile,'r');
format = [repmat('%s',1),repmat('%f',[1,2])];
requirements = textscan(fileID, format, 'Delimiter',{','},'CommentStyle',{'%'},'HeaderLines',1,'MultipleDelimsAsOne',1); 
fclose(fileID);

% assign data to parameters

end