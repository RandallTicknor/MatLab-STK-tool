function [satNames, summary] = MakeSummaryOfSameSatFailures(satNames,failArr, ticksPerDay)
%MakeSummaryOfSameSatFailures:
    %makes a 3D array of all failures in a constellation

%inputs:
    %satNames: vector of satellite names
    %failArr: cell array of row format:
        %{<failure name>, <failure probability per day>, <severity>}
        %defines failure characteristics for entire class of satellites
    %ticksPerDay: number of time ticks in a day    
    
%outputs:
        %satNames: vector of satellite names
        %summary: 3D array of summary of failures constellation experiences
            %each data plane is for a the satellite of the corresponding
            %index in satNames (z index in summary corresponds to index in
            %satNames)
            %each plane shows all errors the satellite experiences
            %plane row format:
                %[<failure name>, <day (integer value)>, <day (double)>, <severity>]) 
            %Note that the ineger value is only a value, the data type is
            %still a double

%convert cell array of failures into numeric array
[failureNames, numFailArr] = convCellFailArr(failArr);

%make 3D array
summary = cell([length(failureNames), 4, length(satNames)]);
for i = 1:length(satNames)
    summary(:, :, i) = convFailArrtoCell(failureNames, MakeArrSatFailures(numFailArr, ticksPerDay));
end

end

function [failCellArr] = convFailArrtoCell(names, numFailArr)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

namesInOrder = names(numFailArr(:, 1));
failCellArr = [namesInOrder, num2cell(numFailArr(:, 2:4))];
end

function [names, numFailArr] = convCellFailArr(cellFailArr)
%convCellFailArr: converts a cell array of failure info into a vector of
%failure names and a failure array of doubles

%inputs:
    %cellFailArr: cell array of failure info with row format:
        %{<failure name>, <failure probability per day>, <severity>}
        
%outputs:
    %names: vector of cells of failure names
    %numFailArr: array of failures with all necessary information
        %row format: [<failure number>, <probability of failure per day>, <failure severity>]
        %failure number is the index of the failure name in names
        
names = cellFailArr(:, 1);
numFailArr = zeros(size(cellFailArr));
numFailArr(:, 1) = 1:length(names);
numFailArr(:, 2:3) = cell2mat(cellFailArr(:, 2:3));
end