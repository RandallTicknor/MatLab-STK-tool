%Adds antenna related failuers to satellites

%INPUTS:
    %root: STK senerio root
    %sats: vector of satellites
    %satData: cell array of satellite data
    %failureLog: cell array of failures
    
%OUTPUTS:
    %satsOut: return vector of modified satellites
    %allSats: return vector of original and modified satellites

function [satsOut,allSats] = add_antenna_failures(root,sats,satData,failureLog)
numFails = size(failureLog,1);
satsOut = sats;
allSats = sats;
for j = 1:numFails
    type = string(failureLog{j,2});
    i = failureLog{j,1};
    anttype = string(satData{i}{16});
    eff = satData{i}{15};
    freq = satData{i}{11};
    dia = satData{i}{13};
    if type == "total antenna failure"
        lifeTime = failureLog{i,4};
        [satRtn,antennaRtn] = change_antenna(root,sat(i),satData{i},lifeTime,anttype,freq,dia,0);
        satsOut(i) = satRtn;
        allSats = [allSats,satRtn];
    end
    if type == "partial antenna failure"
        lifeTime = failureLog{i,4};
        [satRtn,antennaRtn] = change_antenna(root,sat(i),satData{i},lifeTime,anttype,freq,dia,eff-0.25);
        satsOut(i) = satRtn;
        allSats = [allSats,satRtn];
    end
end
end

