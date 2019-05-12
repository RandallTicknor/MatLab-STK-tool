function [eventlog] = MakeEventLog(satIdex, failArr, ticksPerDay, filename, header, satData)
%Makes an event log (both csv and cell array) of failures of satellites in
%a constellation

%inputs:
    %satIdex: vector of satellite indicies
    %failArr: cell array of row format:
        %{<failure name>, <failure probability per day>, <severity>}
        %defines failure characteristics for entire class of satellites
    %ticksPerDay: number of time ticks in a day
    %filename: name of output file (includes filepath and file type)
    %satData: cell array of satellite information, needed to match names to
    %indicies
    
%outputs:
    %eventlog: 2D cell array of events in chronological order
        %row format: [<sat name>, <failure>, <day (int)>, <day (double)>,
            %<severity>]
    %also makes a (presumed csv) file of the matrix with name filename

[names, summary] = MakeSummaryOfSameSatFailures(satIdex, failArr, ticksPerDay);

%make empty array of events
%row format: [<sat name>, <failure>, <day (int)>, <day (double)>,
%<severity>]
eventlog = cell(length(satIdex)*size(failArr,1), 5);

%array of the current times for each failure array
time = zeros([length(satIdex) 1]);
time(:) = cell2mat(summary(1, 3, :));
timeIndex = ones(length(satIdex));
minTime = 0;
minIndex = 0;
ind = 1;

for i = 1:length(satIdex)*size(failArr, 1)
    
    %find index of minimum time
    [minTime, minIndex] = min(time);
    
    %check if at end
    if minTime == intmax
       eventlog = eventlog(1:(i-1), :);
       break;
    end
    
    %case of minTime = -1
    %no failure so not in event log
    if minTime < 0
        
        %check if at end of array
        if timeIndex(minIndex) >= size(failArr, 1)
            time(minIndex) = intmax;
        else
            time(minIndex) = cell2mat(summary(timeIndex(minIndex) + 1, 3, minIndex));
        end
        
        timeIndex(minIndex) = timeIndex(minIndex) + 1;
        
    %case of minTime > 0
    %time > 0, so failure actually happened
    elseif minTime > 0
        %write to eventlog
        eventlog(ind, 1) = mat2cell(satIdex(minIndex),1,1); %satellite name
        eventlog(ind, 2:5) = summary(timeIndex(minIndex), 1:4, minIndex); %rest of row
        
        %check if at end of array
        if timeIndex(minIndex) >= size(failArr, 1)
            time(minIndex) = intmax;
        else
            time(minIndex) = cell2mat(summary(timeIndex(minIndex) + 1, 3, minIndex));
        end
        
        timeIndex(minIndex) = timeIndex(minIndex) + 1;
        ind = ind + 1;
    end
    
end

eventlog = eventlog(1:(ind - 1), :);


%write output csv file
fileID = fopen(filename, 'w');
fprintf(fileID, header);
formatSpec = '%s,%s,%d,%d,%d\n';
[nrows,ncols] = size(eventlog);
for row = 1:nrows
    index = eventlog{row,1};
    name = string(satData{index}{1});
    type = string(eventlog{row,2});
    nums = [eventlog{row,3},eventlog{row,4},eventlog{row,5}];
    fprintf(fileID,'%s,%s,',[name,type]);
    fprintf(fileID,'%d,%f,%d\n',nums);
end
fclose(fileID);
end

