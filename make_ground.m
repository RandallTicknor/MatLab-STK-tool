%Makes ground Stations

%INPUTS:
    %data: ground station data cell array
    %root: root to STK scenerio

%Outputs
    %groundStations: vector of ground station objects

function [groundStations] = make_ground(data,root)
num = size(data{1},1);
for i = 1:num
    name = string(data{1}{i});
    lat = data{2}(i);
    long = data{3}(i);
    groundStations(i) = root.CurrentScenario.Children.New('eFacility', name);
    groundStations(i).Position.AssignPlanetodetic(lat, long, 0.0);
end
end

