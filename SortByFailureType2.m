function [failTable] = SortByFailureType2(eventlog, header, filename,satData)
%Sorts the eventlog by failure type, returns a matrix, and writes a csv of
%the matrix
%Note: the header does not need a newline or column headers
        %The filename should end with .csv
        
%INPUTS
    %eventLog: log of failures
    %header: header line for output file
    %filename: name of output file
    %satData: cell array of satellite data
    
%OUTPUTS
    %failTable: table of failures by type

%sort with selection sort (due to ease of implementation)
%preserves order of each failure type
indexes = zeros(size(eventlog, 1), 1);
for i = 1:(size(eventlog, 1))
   
   %find starting minimum (can't be a previous minimum)
   for h = 1:size(eventlog, 1)
       if ~ismember(h, indexes)
           min = h;
           break;
       end
   end
   
   for j = 1:size(eventlog, 1)
      
       %find minimum index
       if CompareCells(eventlog{min, 2}, eventlog{j, 2}) > 0 && ~ismember(j,indexes) 
           
           min = j;
           
       end
       
   end
   
   indexes(i) = min;
   
end


temp1 = eventlog(indexes, :);

%tally number of failures and starting index of each type of failure
%row format: [<index of 1st failure>, <number of failures>]
tally = [1, 1];
ind = 1;
for k = 2:size(temp1, 1)
    if CompareCells(temp1{k, 2},temp1{tally(ind, 1), 2}) == 0
        tally(ind, 2) = tally(ind, 2) + 1;
        temp1{k, 2} = '';
        
    else
        tally = [tally;
                k, 1];
        ind = ind + 1;
    end
end

temp2 = cell(size(temp1, 1), 4);

temp2(:, [1, 3, 4]) = temp1(:, [2, 1, 3]);
temp2(tally(:, 1), 2) = num2cell(tally(:, 2)); 

failTable = cell(size(temp2) + [size(tally, 1) - 1, 0]);

%make a space between each section of table
for m = 1:(size(tally, 1) - 1)
    
    failTable((tally(m, 1) + m-1):(tally(m + 1, 1) + m-2), :) = temp2(tally(m, 1):(tally(m + 1, 1) - 1), :);
    
end
failTable((tally(end, 1) + size(tally, 1) - 1):end, :) = temp2(tally(end, 1):end, :);

%write output csv file
fileID = fopen(filename, 'wt');
fprintf(fileID, [header,'\n']);
fprintf(fileID, 'Failure, Number of Failures, Satellite, Day\n');
formatSpec = '%s,%d,%s,%f\n';
nrows = size(failTable, 1);
for row = 1:nrows
    index = failTable{row,3};
    if isempty(index)
        name = "";
    else
        name = string(satData{index}{1});
    end
    type = string(failTable{row,1});
    if isempty(type)
        type = "";
    end
    fprintf(fileID,formatSpec,type,failTable{row,2},name,failTable{row,4});
end
fclose(fileID);

end

function [val] = CompareCells(a, b)
%Compares two strings
%comparison is elementwise comparison of ASCII values of characters
%   returns -1 if a < b
%   returns 1 if a > b
%   returns 0 if a == b

if string(a) < string(b)

    val = -1;
    
elseif string(b) < string(a)
    
    val = 1;
    
else
    
    val = 0;
    
end

end
