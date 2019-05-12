%Adds total falilures to satellites

%INPUTS
    %sats: vector of satellite objects
    %satData: cell array of satellite daya
    %failureLog: cell array of failures

function [] = add_sat_failures(sats,satData,failureLog)
numFails = size(failureLog,1);
for i = 1:numFails
    type = string(failureLog{i,2});
    if type == "total failure"
        failedNum = failureLog{i,1};
        lifeTime = failureLog{i,3};
        specifics = satData{failedNum};
        startTimeStr = cell2mat(specifics{2});
        startTime = datenum(startTimeStr, 'dd/mmm/yyyy hh:MM');
        endTime =  startTime + lifeTime;
        endTimeStr = datestr(endTime, 'dd/mmm/yyyy hh:MM');
        sats(failedNum).Propagator.StopTime = endTimeStr;
        sats(failedNum).Propagator.Propagate
    end
end
end