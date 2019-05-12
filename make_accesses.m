%creates accesses in STK

%INPUTS
    %ground stations: vectorof ground station objects
    %Sats: vector of sat objects

%OUTPUTS
    %Access: vector of access objects
    %results: vector of result objects for each access

function [access,results] = make_accesses(groundStations,Sats)
numGround = size(groundStations,2);
numSat = size(Sats,2);
f = waitbar(0,'Computing Access');
tot = numGround*numSat;
for i = 1:numGround
    for j = 1:numSat
        access(i,j) = groundStations(i).GetAccessToObject(Sats(j));
        access(i,j).ComputeAccess();
        results(i,j) = access(i,j).Compute();
        progress = (i-1)*numGround+numSat;
        waitbar(progress/tot,f,'Computing Access')
    end
end
close(f)
end

