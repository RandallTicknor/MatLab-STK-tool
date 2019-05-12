%Adds coverage defition to STK senerio

%INPUTS:
    %sats: vectorof all satleeite objects interacting with coverage
            %defintion
    %root: root to stk senerio
    %scenario: STK scenario
    %maxLat: max latitude for coverage definition
    %minLat: min latitude foe coverage definition
    %raysReport: number of days between reports
    %path: file path to report export folder

%OUTPUTS
    %cov_vec: vector of coverage defintion objects
    %satisfied: vector of % satisfied
    %day_vec: vector of days reports were taken on

function [cov_vec,satisfied,day_vec] = make_coverage(sats,root,scenario,maxLat,minLat,daysReport)
elapsedSec = (etime(datevec(scenario.AnalysisInterval.FindStopTime),datevec(scenario.AnalysisInterval.FindStartTime)));
elapsedDay = elapsedSec/(24*3600);
numReports = floor(elapsedDay/daysReport);
f = waitbar(0,'Computing Coverage. This may take awhile');
    for i = 1:numReports
        coverage = scenario.Children.New('eCoverageDefinition', ['MyCoverage'+string(i)]);
        coverage.Grid.BoundsType = 'eBoundsLatLonRegion';
        covGrid = coverage.Grid;
        bounds = covGrid.Bounds;
        coverage.Grid.Bounds.MinLatitude=minLat;
        coverage.Grid.Bounds.MaxLatitude=maxLat;

        %Set the satellite as the Asset
        for j = 1:size(sats,2)
            coverage.AssetList.Add(['Satellite/',sats(j).InstanceName]);
        end
        start_time = datestr(addtodate(datenum(coverage.Interval.Start),(i-1)*daysReport,'day'),'dd mmm yyyy HH:MM:SS');
        day_vec(i) = string(start_time);
        end_time = datestr(addtodate(datenum(coverage.Interval.Start),(i-1)*daysReport+1,'day'),'dd mmm yyyy HH:MM:SS');
        root.ExecuteCommand(['Cov */CoverageDefinition/MyCoverage'+string(i)+' Interval "'+start_time+'" "'+end_time+'"']);

        fom = coverage.Children.New('eFigureOfMerit', ['Coverage']);
        fom.SetDefinitionType('eFmSimpleCoverage');
        %fom.Definition.SetComputeType('eAverage');
%         fom.Definition.Satisfaction.EnableSatisfaction=1;
%         fom.Definition.Satisfaction.SatisfactionType=('eFmGreaterThan');
%         fom.Definition.Satisfaction.SatisfactionThreshold=3600;
        coverage.ComputeAccesses;
        
        fomDP = fom.DataProviders.Item('Static Satisfaction');
        fomDpResult = fomDP.ExecElements({'Percent Satisfied'});
        satisfied(i) = cell2mat(fomDpResult.DataSets.Item(0).GetValues);
        cov_vec(i) = coverage;
        waitbar(i/numReports,f,'Computing Coverage. This may take awhile')
    end
    close(f)
end
