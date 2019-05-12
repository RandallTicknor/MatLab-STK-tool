%Launch STK
function [root] = LaunchSTK()
    %Load inputs ("Inputs.m")
    Inputs

    %Launch STK
    app = actxserver('STK11.application')
    app.UserControl = 1
    root = app.Personality2
end