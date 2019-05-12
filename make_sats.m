%Creates a vector of satellites based on the data read in from the file
%Uses the parent body from where the fucntion is called

%INPUTS:
    %data: satellite data
    %root: STK senerio
    
%OUTPUTS:
    %satsOut: vectors of STK satellite objects
    %failVec: vector of failure supsecptability
    %antennas: vector of antennas

function [satsOut,failVec,antennas] = make_sats(data,root)
num = size(data,1);
failVec = zeros(1,num);
for i = 1:num
    specifics = data(i);
    vals = specifics{1};
    failVec(i) = cell2mat(vals(17));
    semiMajor = cell2mat(vals(5));
    ecen = cell2mat(vals(6));
    inc = cell2mat(vals(7));
    AOP = cell2mat(vals(8));
    RAAN = cell2mat(vals(9));
    TA = cell2mat(vals(10));
    
    name = string(vals(1));
    satsOut(i) = root.CurrentScenario.Children.New('eSatellite', name);
    keplerian = satsOut(i).Propagator.InitialState.Representation.ConvertTo('eOrbitStateClassical'); % Use the Classical Element interface
    keplerian.LocationType = 'eLocationTrueAnomaly'; % Makes sure True Anomaly is being used
    
    keplerian.SizeShape.SemimajorAxis = semiMajor;   %Km
    keplerian.SizeShape.Eccentricity = ecen;
    
    keplerian.Orientation.Inclination = inc;         % deg
    keplerian.Orientation.ArgOfPerigee = AOP;        % deg
    keplerian.Orientation.AscNode.Value = RAAN;         % deg
    keplerian.Location.Value = TA;                  % deg
    
    frequency = cell2mat(vals(11));
    beamwidth = cell2mat(vals(12));
    diameter = cell2mat(vals(13));
    mainGain = cell2mat(vals(14));
    eff = cell2mat(vals(15));
    type = string(vals(16));
    
    name = "StartingAntenna";
    [TempAntenna,antennaModel] = add_antenna(satsOut(i),name,type,frequency,diameter,eff);
    antennas(i) = TempAntenna;
    
    % Apply the changes made to the satellite's state and propagate:
    satsOut(i).Propagator.StartTime = string(specifics{1}(2));
    satsOut(i).Propagator.StopTime = string(specifics{1}(3));
    %satsOut(i).Propagator.StopTime = '7/Jan/2019 08:47';
    satsOut(i).Propagator.InitialState.Representation.Assign(keplerian);
    satsOut(i).Propagator.Propagate
end
end

