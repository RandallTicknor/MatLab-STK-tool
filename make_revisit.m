%Caclulates revist times

%INPUTS
    %coverage: vector of coverage defintions
    %maxTime: maxium revisit time in hours

%OUTPUTS
    %satisfied: vector of percent satified for each report

function [satisfied] = make_revisit(coverage,maxTime)
numReports = size(coverage,2);
f = waitbar(0,'Computing Revisit Times');
for i = 1:numReports
    fom = coverage(i).Children.New('eFigureOfMerit', ['Revisit']);
    fom.SetDefinitionType('eFmRevisitTime');
    fom.Definition.SetComputeType('eMaximum');
    fom.Definition.Satisfaction.EnableSatisfaction=1;
    fom.Definition.Satisfaction.SatisfactionType=('eFmAtMost');
    fom.Definition.Satisfaction.SatisfactionThreshold=maxTime*3600;
    coverage(i).ComputeAccesses;
    
    fomDP = fom.DataProviders.Item('Static Satisfaction');
    fomDpResult = fomDP.ExecElements({'Percent Satisfied'});
    satisfied(i) = cell2mat(fomDpResult.DataSets.Item(0).GetValues);
    waitbar(i/numReports,f,'Computing Revisit Times')
end
close(f);
end

