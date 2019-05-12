%MATLAB - STK interface tool
%Aero 483 W19 Mission Assurance Team

%This function simulates constellations in STK and generates reports and
%error logs based on user defined inputs

%% Data Input
clear;
prompt = 'Run Input Helper? Y/N: ';
str = input(prompt,'s');
if isempty(str)
    str = 'Y';
end

if str == 'Y'
    [file,path] = uigetfile('*.csv','Select Constellation Pattern File');
    Input_Helper(file,path);
end

dataPath = uigetdir(path,'Select Constellation Folder');
[ScenerioTimeBounds,SatData] = satInputRead([dataPath,'\Constellation.csv']);
numSats = size(SatData,1);
requirements = requirementsRead([dataPath,'\reqInput.csv']);

groundData = groundStationRead([dataPath,'\groundStations.csv']);

%% Error generation
failData =  failInputRead([dataPath,'\failures.csv']);
failData = reduceVertical(failData);
failLog = MakeEventLog(1:numSats,failData,24,[dataPath,'\Failure_Event_Log.csv'],'Satellite,Type,Day,Day decimal,Severity\n',SatData);
failCommands = formatLog(failLog);
failTable = SortByFailureType2(failCommands,'%Failures sorted by type',[dataPath,'\Failure_Log_by_Type.csv'],SatData);


%% ----------------STK Launch and Sat creation
%Launch STK
try
    % Grab an existing instance of STK
    app = actxGetRunningServer('STK11.application');
catch
    % STK is not running, launch new instance
    app = actxserver('STK11.application');
end
app.UserControl = 1;
root = app.Personality2;

%close any open scenerio
try
    root.CloseScenario();
end

body = string(SatData{1}{4});

if isequal(body,"Mars")
    %Generate Scenario
    scenario = root.Children.NewOnCentralBody('eScenario','MatLab_STK_Scenario','Mars');
    scenario.SetTimePeriod(cell2mat(ScenerioTimeBounds(1)),cell2mat(ScenerioTimeBounds(2)));
    root.ExecuteCommand('Animate * Reset')

    %set windows for debugging
    root.ExecuteCommand('VO * CentralBody Mars')
    root.ExecuteCommand('MapGraphics * SetCentralBody Mars')

    %Make defualt sat to change central body
    %Default sat is not used in any calculations but is needed to modify
    %central body
    root.ExecuteCommand('New / */Satellite CentralBodySat CentralBody Mars');
end

[ground] = make_ground(groundData,root);
[sats,fail,antennas] = make_sats(SatData,root);
numSats = size(sats,1);


%% ------------------Add failures to STK sats
%TODO: use fail vector to prevent certain failures from occuring on certian
%satellites, if applicable
[sats,allSats] = add_antenna_failures(root,sats,SatData,failCommands);

add_sat_failures(sats,SatData,failCommands)

%%
%%-----------------Add requirement Stuff
[maxLat,Reportdays,coverageMin] = get_lat_bouds(requirements);
[cov_vec,satisfied,day_vec] = make_coverage(allSats,root,scenario,maxLat,-1*maxLat,Reportdays);
[revistTimeHours,days] = get_revisit_time(requirements);
[RTimeSatisified] = make_revisit(cov_vec,revistTimeHours);
[accesses,accessResults] = make_accesses(ground,allSats);

%%
%%Requirement reports
f = waitbar(0,'Writing Reports');
coverageOut = [dataPath,'\Coverage_Requirement_Report.csv'];
coverage_satisfied_report(satisfied,day_vec,coverageMin,coverageOut);
waitbar(0.33,f,'Writing Reports')
revisitOut = [dataPath,'\Revisit_Requirement_Report.csv'];
revisit_satisfied_report(RTimeSatisified,day_vec,revistTimeHours,revisitOut);
waitbar(0.66,f,'Writing Reports')

%Known issue: access_reports gives errors for access to satelies made from
%modifying antennas. This comes from the satellite name not being in the
%look-up from SatData
access_reports(groundData,accesses,dataPath,SatData);

close(f)
%% Helper functions
function [rtn] = reduceVertical(inVec)
vert = size(inVec,1);
horiz = size(inVec{1},2);
for i = 1:vert
    for j = 1:horiz
        rtn{i,j} = inVec{i}{j};
    end
end
end

function [rtn] = formatLog(logIn)
vert = size(logIn,1);
for i = 1:vert
    rtn{i,1} = logIn{i,1};
    rtn{i,2} = logIn{i,2};
    rtn{i,3} = logIn{i,4};
end
end