%Makes access reports for each groundstation

%INPUTS:
    %grounds: grond station data, used to get names
    %accesses: accesses
    %path: file path for export
    %satData: satellite data, used to get names

%OUTPUTS:
    % a file containg the number of access for each satellite and all gaps
    % in coverage

function [] = access_reports(grounds,accesses,path,satData)
numGround = size(grounds{1},1);
numResults = size(accesses,2);
for i = 1:numGround
    name = grounds{1}{i};
    filename = string(strcat(path,'\Access_reports_',name,'.csv'));
    Grndaccess = accesses(i,:);
    numAccesses = zeros(1,numResults);
    AllAccesses = [];
    for j = 1:numResults
        satNames(j) = string(satData{j}{1});
        sataccess = Grndaccess(j);
        intervalCollection = sataccess.ComputedAccessIntervalTimes;
        computedIntervals = intervalCollection.ToArray(0, -1);
        numAccesses(j) = size(computedIntervals,1);
        AllAccesses =[AllAccesses;computedIntervals];
    end
    converstionSTR = string(AllAccesses);
    accessDateTime = datetime(converstionSTR,'InputFormat','dd MMM yyyy HH:mm:ss.SSS');
    sorted1 = sortrows(accessDateTime(:,1));
    sorted2 = sortrows(accessDateTime(:,2));
    sorted = [sorted1,sorted2];
    numGaps = 0;
    GapTimes = [];
    for k = 2:size(sorted,1)
       if(sorted(k-1,2)<sorted(k,1))
            numGaps = numGaps + 1;
            GapTimes = [GapTimes;sorted(k-1,2),sorted(k,1)];
       end
    end

    fileID = fopen(filename, 'wt');
    fprintf(fileID,'%%Satelite Name, %%Total Number of Accesses\n');
    for l = 1:numResults
        fprintf(fileID,'%s,%.0f\n',satNames(l),numAccesses(l));
    end
    fprintf(fileID,',\n');
    fprintf(fileID,'Number of Gaps in Coverage,%.0f\n',numGaps);
    diff = GapTimes(:,2)-GapTimes(:,1);
    fprintf(fileID,'Shortest Gap in Coverage,%s\n',evalc('disp(min(diff))'));
    fprintf(fileID,'Mean Gap in Coverage,%s\n',evalc('disp(mean(diff))'));
    fprintf(fileID,'Longest Gap in Coverage,%s\n',evalc('disp(max(diff))'));
    

    fclose('all');
end
end

