function [root,scenario] = CreateScenario(root)
    %Load inputs ("Inputs.m")
    Inputs

    %Launch STK
    app = actxserver('STK11.application')
    app.UserControl = 1
    root = app.Personality2

    %Generate Scenario
    scenario = root.Children.New('eScenario',Scenario_Name);
    scenario.SetTimePeriod(start_time,end_time)
    root.ExecuteCommand('Animate * Reset')
end


