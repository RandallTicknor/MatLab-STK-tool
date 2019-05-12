%modifies antenna for a satellite.
%Since edits can't happen mid sim this ends the passed in satelite at he
%failure time and returns a new satellite that starts at the same time with
%a diffrent antenna

%INPUTS
    %root: STK senerio
    %sat: satellite to change antenna on
    %satData: cell array of atellite data
    %time: time in decimal days when antenna is changed
    %type: type of antenna
    %frequency: frequency of anteanna
    %diameter: characteristic length of antenna
    %eff: efficency of antenna
    
%OUTPUTS
    %satOut: output satellite
    %antenna: antenna object

function [satOut,antenna] = change_antenna(root,sat,satData,time,type,frequency,diameter,eff)
    startTimeStr = cell2mat(satData{2});
    startTime = datenum(startTimeStr, 'dd/mmm/yyyy hh:MM');
    endTime =  startTime + time;
    endTimeStr = datestr(endTime, 'dd/mmm/yyyy hh:MM');
    sat.Propagator.StopTime = endTimeStr;
    sat.Propagator.Propagate;
    
    vals = satData;
    semiMajor = cell2mat(vals(5));
    ecen = cell2mat(vals(6));
    inc = cell2mat(vals(7));
    AOP = cell2mat(vals(8));
    RAAN = cell2mat(vals(9));
    TA = cell2mat(vals(10));
    
    name = string(vals(1))+"-1";
    satOut = root.CurrentScenario.Children.New('eSatellite', name);
    keplerian = satOut.Propagator.InitialState.Representation.ConvertTo('eOrbitStateClassical'); % Use the Classical Element interface
    keplerian.LocationType = 'eLocationTrueAnomaly'; % Makes sure True Anomaly is being used
    
    keplerian.SizeShape.SemimajorAxis = semiMajor;   %Km
    keplerian.SizeShape.Eccentricity = ecen;
    
    keplerian.Orientation.Inclination = inc;         % deg
    keplerian.Orientation.ArgOfPerigee = AOP;        % deg
    keplerian.Orientation.AscNode.Value = RAAN;         % deg
    keplerian.Location.Value = TA;                  % deg
    
    name = "ModifiedAntenna";
    [TempAntenna,antennaModel] = add_antenna(satOut,name,type,frequency,diameter,eff);
    antenna = TempAntenna;
    satOut.Propagator.StartTime = endTimeStr;
    satOut.Propagator.StopTime = string(satData(3));
    satOut.Propagator.InitialState.Representation.Assign(keplerian);
    satOut.Propagator.Propagate
end

