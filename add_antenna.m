%Adds an antenna to a spacecraft

%INPUTS
    %satellite: saetllie to add antenna to
    %name: name of antenna
    %frequency: frequency of anteanna
    %length: characteristic length of antennna
    %efficency: efficency of anrenna

%OUTPUTS
    %antenna: antenna object
    %antennaModel: antennaModel object

function [antenna,antennaModel] = add_antenna(satellite,name,type,frequency,length,efficency)
antenna = satellite.Children.New('eAntenna', name);
antenna.SetModel(type);
antennaModel = antenna.Model;
antennaModel.DesignFrequency = frequency; %GHz
antennaModel.Length = length; %m 
antennaModel.Efficiency = efficency; %Percent
end

