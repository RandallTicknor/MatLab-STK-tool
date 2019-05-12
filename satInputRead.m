%Reads in information from constellation file

%INPUTS
%   satFile: file containing data

%OUTPUTS
%   UTC: time bounds of STK simulation in UTC
%   sats: Cell array of satellite inforamtion

function [UTC,sats] = satInputRead(satFile)

% ---------------------------------------
% LOAD DATA FROM SATELLITE INPUT FILE
fileID = fopen(satFile,'r');
%   Pull UTC start/end first
    utcFormat = '%s%s';
    utcData = textscan(fileID, utcFormat,1,'Delimiter',{','},'CommentStyle',{'%'},'HeaderLines',1,'MultipleDelimsAsOne',1); 
%   Pull satellite data
    satFormat = [repmat('%s',[1,4]),repmat('%f',[1,11]),repmat('%s',1),repmat('%f',1)];
    satData = textscan(fileID, satFormat,'Delimiter',{','},'CommentStyle',{'%'},'HeaderLines',1,'MultipleDelimsAsOne',1); 
fclose(fileID);

% ---------------------------------------
% FORMAT SATELLITE DATA
sats = cell(size(satData{1},1),1); 
for i = 1:size(satData{1},1)
    sats{i} = {cell(1,17)};
    for j = 1:17
        sats{i}{j} = satData{j}(i);
    end
end

% ---------------------------------------
% FORMAT UTC DATA
UTC = [utcData{1};utcData{2}];




