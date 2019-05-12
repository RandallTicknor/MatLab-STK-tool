%Helper fnction that generates a constelation from a single satellite input
%with walker information

%INPUTS
%   File: file name with information
%   Path: path to file

function [] = Input_Helper(File,Path)

% ------------Read in file
%[UTC,sats] = satInputRead(File);

fileID = fopen([Path,File],'r');
%   Pull UTC start/end first
    utcFormat = '%s%s';
    utcData = textscan(fileID, utcFormat,1,'Delimiter',{','},'CommentStyle',{'%'},'HeaderLines',1,'MultipleDelimsAsOne',1);
    UTC = [utcData{1};utcData{2}];
%   Pull satellite data
    satFormat = [repmat('%s',[1,4]),repmat('%f',[1,11]),repmat('%s',1),repmat('%f',1)];
    satData = textscan(fileID, satFormat,1,'Delimiter',{','},'CommentStyle',{'%'},'HeaderLines',1,'MultipleDelimsAsOne',1);
    % ---------------------------------------
    % FORMAT SATELLITE DATA
    sats = cell(size(satData{1},1),1); 
    for i = 1:size(satData{1},1)
        sats{i} = {cell(1,17)};
        for j = 1:17
            sats{i}{j} = satData{j}(i);
        end
    end
%   Pull waker information
    walkerFormat = [repmat('%s',1),repmat('%f',[1,3])];
    walkerData = textscan(fileID, walkerFormat,1,'Delimiter',{','},'CommentStyle',{'%'},'HeaderLines',1,'MultipleDelimsAsOne',1);
    %-------------------
    %get walker information
    Type = string(walkerData(1));
    numSatsPerPlane = cell2mat(walkerData(2));
    numPlanes = cell2mat(walkerData(3));
    interplaneSpacing = cell2mat(walkerData(4));
%----------

TotalSats = numSatsPerPlane*numPlanes;

con_cell = cell(TotalSats, length(sats));

satName = sats{1,1}; % {1,_} ensures 1st row 
satName = string(satName(1));

% Name of all satellites - append _(i) to satellite name
% con_cell(:,1) = 
for i = 1:TotalSats
    newName = strcat(satName,'-', num2str(i));
    con_cell(i,1) = {newName};
end

% Each satellite will have same start and end time
con_cell(:,2) = sats{1}(2); % UTC start
con_cell(:,3) = sats{1}(3); % UTC end
con_cell(:,4) = sats{1}(4); % Body around
con_cell(:,5) = sats{1}(5); % semi-major
con_cell(:,6) = sats{1}(6); % eccentricity
con_cell(:,7) = sats{1}(7); % inclination

con_cell(:,8) = sats{1}(8); % Arg of paragee


% RAAN - planes - depends on star or delta -
% column 9
% star - 360/   delta - 180/
if Type == 'delta'
    for i = 1:numPlanes 
        for j = 1:numSatsPerPlane
            con_cell(numSatsPerPlane*(i-1)+(j),9) = {mod(cell2mat(sats{1}(9))+(i-1)*(180/(numPlanes)),360)};
        end
    end
end
if Type == 'star' 
    for i = 1:numPlanes 
        for j = 1:numSatsPerPlane
            con_cell(numSatsPerPlane*(i-1)+(j),9) = {mod(cell2mat(sats{1}(9))+(i-1)*(360/(numPlanes)),360)};
        end
    end
end

% true anomaly - sats per plane - column 10 

for i = 1:numPlanes
    for j = 1:numSatsPerPlane
        spacing = 360/(numSatsPerPlane+interplaneSpacing*numSatsPerPlane);
        offset = spacing/numPlanes;
        con_cell((i-1)*numSatsPerPlane+j,10) = {mod(cell2mat(sats{1}(10))+2*(j-1)*spacing+2*(i-1)*offset,360)};
    end
end

con_cell(:,11) = sats{1}(11); % freq
con_cell(:,12) = sats{1}(12);
con_cell(:,13) = sats{1}(13);
con_cell(:,14) = sats{1}(14);
con_cell(:,15) = sats{1}(15);
con_cell(:,16) = sats{1}(16);
con_cell(:,17) = sats{1}(17);

%T = cell2table(con_cell);
%T.Properties.VariableNames = ['%Sat Name','%Sat Time Start','%Sat Time End','% Body Around','%Semi-Major','% Eccentricity','% Inclination','% Arg. of Perigee','%Raan','% True Anomaly','% Frequency','% Beamwdith','% Diameter','% Main-Lobe Gain','% Efficiency','% Type','%Failure type'];
%writetable(T,[Path,'Constellation.csv'])

fID = fopen([Path,'Constellation.csv'],'w');
headerStr = '%Constilation built by Input_Helper.m';
fprintf(fID,'%s\n',headerStr);
fprintf(fID,'%s,%s\n',string(UTC(1)),string(UTC(2)));
header2 = ["%Sat Name","%Sat Time Start","%Sat Time End","% Body Around","%Semi-Major","% Eccentricity","% Inclination","% Arg. of Perigee","%Raan","% True Anomaly","% Frequency","% Beamwdith","% Diameter","% Main-Lobe Gain","% Efficiency","% Type","%Failure type"];
fprintf(fID,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n',header2);
for i = 1:TotalSats
    fprintf(fID,'%s,%s,%s,%s,',string(con_cell{i,1}),string(con_cell{i,2}),string(con_cell{i,3}),string(con_cell{i,4}));
    for j = 5:15
        fprintf(fID,'%f,',con_cell{i,j});
    end
    fprintf(fID,'%s,',string(con_cell{i,16}));
    fprintf(fID,'%f\n',con_cell{i,17});
end
fclose(fID);
end



