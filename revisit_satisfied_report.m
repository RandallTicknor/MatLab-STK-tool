%Makes a table and export file of the results of the revisit reports into
%a csv

%INPUTS
    %coveragePercent: A nx1 vector containg the percent of coverage area with revist time met for each
    %report [100,...,0]
    %dates: A nx1 vector with the UTC start of each report (dd mmm yyyy hh:MM:ss)
    %maximum: maxium revist time in coverage defintion
    %filename: name of output file including path

%OUTPUT
    %generates a file with the following format
    
    %Revisit failed on <date>, x% of coverage area satisfied, y hours maxiumum required
    %
    %<Date>,x%, <Satified/Not Satisfied>
            %date format: dd mmm yyyy

function [] = revisit_satisfied_report(revisitPercent,dates,maximum,filename)
n = length(revisitPercent);
index = -1;
for i = 1:n
    if revisitPercent(i) < 100
        index = i;
        break;
    end
end

utcdatestr = extractBetween(dates,1,11);

fileID = fopen(filename, 'wt');

if(index ~= -1)
    fprintf(fileID, 'Revisit Time failed on %s, %.2f%% of coverage meet requirements, %.2f hours maximum required\n\n', utcdatestr(index), revisitPercent(index), maximum);
else
    fprintf(fileID, 'Coverage Never failed ,,%.2f hours maximum required\n\n',maximum);
end

%write rest of the file
for j = 1:n
    if (j < index || index == -1)
        %fprintf(fileID, '%d,%d%%, Satisfied\n', dates(j), coveragePercent(j));
        fprintf(fileID, '%s,%.2f%%, Satisfied\n', utcdatestr(j), revisitPercent(j));
    else
        %fprintf(fileID, '%d,%d%%, Not Satisfied\n', dates(j), coveragePercent(j));
        fprintf(fileID, '%s,%.2f%%, Not Satisfied\n', utcdatestr(j), revisitPercent(j));
    end
end

%close file
fclose('all');
end

