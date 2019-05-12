%Returns the lattiutdes that bound x% of a planet, assuming equal north and
%south distribution

%INPUTS:
    %requirements: cell array of requiremetns
%OUTPUTS:
    %lat: lattitude bounds
    %days: number of days between reports
    %percent: percent coverage required

function [lat,days,percent] = get_lat_bouds(requirements)
num = size(requirements,1);
days = 7; %default value
lat = 90;
for i = 1:num
    if isequal(requirements{1}{i},'Coverage')
        days = requirements{3}(i);
        percent = requirements{2}(i);
        Aref = pi*percent/50;
        lat = asind(Aref/(2*pi));
    end
end
end

