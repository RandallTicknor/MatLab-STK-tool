%Gets revisit time requirements

%INPUTS:
    %requirements: cell array of requiremetns
%OUTPUTS:
    %time: max revisit time in hours
    %days: number of days between reports

function [time,days] = get_revisit_time(requirements)
num = size(requirements{1},1);
time = 24; %default value
days = 7;
for i = 1:num
    if isequal(requirements{1}{i},'Revisit Time')
        days = requirements{3}(i);
        time = requirements{2}(i);
    end
end
end

