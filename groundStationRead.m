%Reads in ground stations from file

function [groundStations] = groundStationRead(groundFile)
fileID = fopen(groundFile,'r');
format = [repmat('%s',1),repmat('%f',[1,2])];
groundStations = textscan(fileID, format, 'Delimiter',{','},'CommentStyle',{'%'},'HeaderLines',1,'MultipleDelimsAsOne',1); 
fclose(fileID);
end

