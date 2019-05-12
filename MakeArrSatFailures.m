function [arrFailures] = MakeArrSatFailures(failArr, ticksPerDay)
%MakeArrSatFailures: makes array of all failures in a single satellite

%inputs:
    %failArr: array of failures with all necessary information
        %row format: [<failure number>, <probability of failure per day>, <failure severity>]

%Explanation of failure severity:
    %Motivating Example: There is no need to roll for failure after total
        %failure and less severe failures could create problems in later
        %code (e.g.: partial antenna degradation after total failure could
        %cause code to mistakenly bring satellite back online)
    %Failure severity is a qualitative measure of the severity of each
        %failure
    %Lower number failures are more severe. Total failure is always
        %severity 0.
    %Higher number failures can't occur after lower number failures
        
%outputs:
    %arrFailures: array of all errors that occur
        %array is sorted by time of failure
        %if a more minor failure (higher severity number) occurs after a more
        %major failure, the time of the more minor failure is -1 (failure
        %precluded by more serious failure)
        %row format [<failure number>, <failure day int>, <failure day double>, <severity>]

%convert probability of failure per day to probability of failure per tick    
vectProbFailPerTick = ConvertProbDaytoTick(failArr(:, 2), ticksPerDay);

%failure tick 
vectFailTick = zeros(size(vectProbFailPerTick));

%make vector of failures
for i = 1:length(vectFailTick)
    vectFailTick(i) = findFailureTick(vectProbFailPerTick(i));
end


%convert failure ticks to days
[failDayInt, failDayDoub] = ConvertTicktoDay(vectFailTick, ticksPerDay);

%assemble output
%assumes all vectors are column vectors (might cause a bug)
arrFailures = [failArr(:, 1), failDayInt, failDayDoub, failArr(:, 3)];

%sort rows in ascending order by time
arrFailures = sortrows(arrFailures, 3); %sorts in ascending order by time (in double)

%check that failures increase in severity
%assumption: only one failure has severity 0 (total failure)
severity = arrFailures(1, 4);

for i = 2:length(vectFailTick)
    
    %changing severity
    if (arrFailures(i, 4) < severity)
        severity = arrFailures(i, 4);
        
    %main check
    elseif (arrFailures(i, 4) > severity)
        %more minor error occurs after major error
        %error occurs after, since rows are sorted
        arrFailures(i, 2) = -1;
        arrFailures(i, 3) = -1;
    end
    
end

end


function [ProbFailPerTick] = ConvertProbDaytoTick(probFailPerDay, tickPerDay)
%ConvertProbDaytoTick: Converts probability of failure per day to
%probability of failure per tick


%actual formula
ProbFailPerTick = 1 - (1 - probFailPerDay).^(1./tickPerDay);

%linear approximation
%ProbFailPerTick = probFailPerDay/tickPerDay;

end


function [tickNum] = findFailureTick(probFailPerTick)
%findFailureTick: takes probability of failure per tick
%   returns tick that failure occurs on
%   tick 1 occurs after smallest time interval
%   "tick" is like step size in STK

%This function is probably slow from a runtime perspective

tickNum = 1;
roll = rand();

while roll > probFailPerTick
    tickNum = tickNum + 1;
    roll = rand();
end


end


function [dayInt, dayDoub] = ConvertTicktoDay(tick, tickPerDay)
%ConvertTicktoDay: converts tick number to day number
%Day 0: covers everything in 1st full day of operation

dayDoub = tick./tickPerDay;
dayInt = floor(dayDoub);

end
