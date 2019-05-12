%Makes a table and export file of the results of the coverage reports into
%a csv

%INPUTS
    %coveragePercent: A nx1 vector containg the coverage percent for each
    %report [100,...,0]
    %dates: A nx1 vector with the UTC start of each report
    %minimum: minimum percent forcoverage to satify requiremetns, between 100
    %and 0
    %filename: name of output file including path

%OUTPUT
    %generates a file with the following format
    
    %Coverage failed on <date>, x%, y% required
    %
    %<Date>,x%, <Satified/Not Satisfied>
        %date format: mm-dd-yyyy

function [] = coverage_satisfied_report(coveragePercent,dates,minimum,filename)

%find point where coverage requirement is no longer satisfied

%loop over data
n = length(coveragePercent);
index = -1;
for i = 1:n
    if coveragePercent(i) < minimum
        index = i;
        break;
    end
end

%write output file
fileID = fopen(filename, 'wt');


% utcdates = datetime(dates, 'ConvertFrom', 'posixtime');
% utcdatestr = datestr(utcdates, 'dd mmm yyyy hh:MM:ss');

utcdatestr = extractBetween(dates,1,11);

%write first two lines
%fprintf(fileID, 'Coverage failed on %d, %d%%, %d%% required\n\n', dates(index), coveragePercent(index), minimum);
%commented out lines have date still as utc seconds

if(index ~= -1)
    fprintf(fileID, 'Coverage failed on %s, %d%%, %.2f%% required\n\n', utcdatestr(index), coveragePercent(index), minimum);
else
    fprintf(fileID, 'Coverage Never failed ,,%.2f%% required\n\n',minimum);
end


%write rest of the file
for j = 1:n
    if (j < index || index == -1)
        %fprintf(fileID, '%d,%d%%, Satisfied\n', dates(j), coveragePercent(j));
        fprintf(fileID, '%s,%.2f%%, Satisfied\n', utcdatestr(j), coveragePercent(j));
    else
        %fprintf(fileID, '%d,%d%%, Not Satisfied\n', dates(j), coveragePercent(j));
        fprintf(fileID, '%s,%.2f%%, Not Satisfied\n', utcdatestr(j), coveragePercent(j));
    end
end

%close file
fclose('all');

end

