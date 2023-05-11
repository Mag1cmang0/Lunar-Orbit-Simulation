classdef FINAL_SIMULATION_Code_View < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        CurrentAccelerationLabel       matlab.ui.control.Label
        CurrentVelocityLabel           matlab.ui.control.Label
        TripLengthLabel                matlab.ui.control.Label
        ExitAppButton                  matlab.ui.control.Button
        SimulationStatusLabel          matlab.ui.control.Label
        BurnStrengthEditField          matlab.ui.control.NumericEditField
        BurnStrengthEditFieldLabel     matlab.ui.control.Label
        FirstRocketBurnTimeEditField   matlab.ui.control.NumericEditField
        FirstRocketBurnTimeEditFieldLabel  matlab.ui.control.Label
        InitialVelocityEditField       matlab.ui.control.NumericEditField
        InitialVelocityEditFieldLabel  matlab.ui.control.Label
        InitialAltitudeEditField       matlab.ui.control.NumericEditField
        InitialAltitudeEditFieldLabel  matlab.ui.control.Label
        Label                          matlab.ui.control.Label
        HelpButton                     matlab.ui.control.Button
        InstructionsPanel              matlab.ui.container.Panel
        InstructionsText               matlab.ui.control.Label
        ExitButton                     matlab.ui.control.Button
        MaxFlightDurationDropDown      matlab.ui.control.DropDown
        MaxFlightDurationLabel         matlab.ui.control.Label
        RUNSIMULATIONButton            matlab.ui.control.Button
        MoonAngleSlider                matlab.ui.control.Slider
        MoonAngleSliderLabel           matlab.ui.control.Label
        UIAxes                         matlab.ui.control.UIAxes
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Upon startup, we want to have the earth graphed. The way
            % we acomplish this is by plotting a circle with the radius of 
            % the earth. We also set limits for the viewing window, and
            % turn hold on for the graph.

            hold(app.UIAxes, "on")
            RE = 6378100; % Radius of the earth in meters
            xlim(app.UIAxes, [-3e8, 7e8])
            ylim(app.UIAxes, [-3.5e8, 3.5e8])
                for a =  1:800

                    theta = 360*a/800;

                    x_m_e(a) = RE*cosd(theta);
                    y_m_e(a) = RE*sind(theta);

                end
                
                % Plot the earth lines
                plot(app.UIAxes,x_m_e,y_m_e,'.b')
        end

        % Button pushed function: ExitButton
        function ExitButtonPushed(app, event)
            % The role of this button is to close the instructions panel.
            % The way we go about this is by setting the instructions panel
            % visibility to "off", while simultaneously setting all of the
            % input fields and text label's visibilty to "on". We also set
            % the visibility of the help button to "on" as well.
            
            app.InstructionsPanel.Visible = "off";
            app.HelpButton.Visible = "on";
            app.BurnStrengthEditField.Visible = "on";
            app.FirstRocketBurnTimeEditField.Visible = "on";
            app.InitialAltitudeEditField.Visible = "on";
            app.InitialVelocityEditField.Visible = "on";
            app.Label.Visible = "on";
            app.BurnStrengthEditFieldLabel.Visible = "on";
            app.FirstRocketBurnTimeEditFieldLabel.Visible = "on";
            app.InitialAltitudeEditFieldLabel.Visible = "on";
            app.InitialVelocityEditFieldLabel.Visible = "on";
            app.SimulationStatusLabel.Visible = "on";
            app.ExitAppButton.Visible = "on";
            app.TripLengthLabel.Visible = "on";
            app.CurrentAccelerationLabel.Visible = "on";
            app.CurrentVelocityLabel.Visible = "on";
        end

        % Button pushed function: HelpButton
        function HelpButtonPushed(app, event)
            % The role of this button is to open the instructions panel.
            % The way we go about this is by setting the instructions panel
            % visibility to "on", while simultaneously setting all of the
            % input fields and text label's visibilty to "off". We also set
            % the visibility of the help button to "off" as well.

            app.InstructionsPanel.Visible = "on";
            app.HelpButton.Visible = "off";
            app.BurnStrengthEditField.Visible = "off";
            app.FirstRocketBurnTimeEditField.Visible = "off";
            app.InitialAltitudeEditField.Visible = "off";
            app.InitialVelocityEditField.Visible = "off";
            app.Label.Visible = "off";
            app.BurnStrengthEditFieldLabel.Visible = "off";
            app.FirstRocketBurnTimeEditFieldLabel.Visible = "off";
            app.InitialAltitudeEditFieldLabel.Visible = "off";
            app.InitialVelocityEditFieldLabel.Visible = "off";
            app.SimulationStatusLabel.Visible = "off";
            app.ExitAppButton.Visible = "off";
            app.TripLengthLabel.Visible = "off";
            app.CurrentAccelerationLabel.Visible = "off";
            app.CurrentVelocityLabel.Visible = "off";
        end

        % Button pushed function: RUNSIMULATIONButton
        function RUNSIMULATIONButtonPushed(app, event)
            
            % Anytime we run the simulation, the first thing we want to do
            % is clear the graph
            cla(app.UIAxes)
            
            % Update the simulation status
            app.SimulationStatusLabel.Text = "Simulation Status: In Progress";

            % Reset the x and y axes just in case the user chose to zoom in
            % and examine the flight path
            xlim(app.UIAxes, [-3e8, 7e8])
            ylim(app.UIAxes, [-3.5e8, 3.5e8])

            % Next, we initialize all the user inputs by assigning their
            % values to unique variables.
            theta0 = app.MoonAngleSlider.Value;
            altitude0 = app.InitialAltitudeEditField.Value+6378100;
            velocity0 = app.InitialVelocityEditField.Value;
            first_rocket_burn_time = app.FirstRocketBurnTimeEditField.Value*24*3600;
            delta_V_during_burn = app.BurnStrengthEditField.Value;
            max_flight_duration = str2double(app.MaxFlightDurationDropDown.Value)*24*3600;

            % We also initalize our time as well as our time step
            t(1) = 0;
            dt = 0.1;

            % HB is a on/off variable that we use to determine if the
            % rocket's secondary thruster has burned, hence HB
            HB = 0;

            % For the last part of initialization, we define some constants
            % that are involved with the physics behind this simulation
            T = 2358720; % Period of the moon's orbit around earth in seconds
            R = 3.84e8; % Radius of moon's orbit around earth in meters
            RE = 6378100; % Radius of the earth

            % Since we cleared our graph as the first step associated with
            % this button press, we must re-graph the earth. Due to a lack
            % of easy-to-make public variable access in matlab, we must
            % redefine our earth plot as well as re-plot it
            for a =  1:800

                theta = 360*a/800;

                x_m_e(a) = RE*cosd(theta);
                y_m_e(a) = RE*sind(theta);

            end

            plot(app.UIAxes,x_m_e,y_m_e,'.b')

            % Next, in order for our simulation to run, we must define the
            % first variable for our x and y vectors for both position
            % and velocity. Here we make the first of a couple assumptions,
            % which states that the initial launch point will be purely
            % normal to the earths surface, pointing in exclusively the -x
            % direction. The second assumption we make is the the initial
            % velocity is pointing directly downwards(in the -y direction)
            x(1) = -1*altitude0;
            y(1) = 0;
            v_y(1) = -1*velocity0;
            v_x(1) = 0;

            % We also find the first variable in the x and y vectors for
            % our moon's position
            x_m_c(1) = R*cosd(theta0);
            y_m_c(1) = R*sind(theta0);

            % Next, we find the first variable for our x and y vectors in
            % regards to acceleration, by running a custom made function
            % that takes the x and y position coordinate of both the
            % rocket ship and the moon at a given point in time, and 
            % outputs the x and y and outputs the corresponding 
            % acceleration x and y components.
            [a_x(1), a_y(1)] = ACCELYX(x(1),y(1),x_m_c(1),y_m_c(1));

            % Initialize the index for all vectors
            i = 1;
            
            % A major problem with this simulation is the sheer amount of
            % points that our code creates. Plotting all of the points
            % heavily taxes both the GPU and CPU of the device the code is
            % being ran on. As a result, we have a counter that determines
            % what fraction of the total amount of points will be plotted.
            % Through testing we have found that plotting 1/9 of the total
            % points yields a timely response as well as an satisfactory 
            % representation of the simulated data.
            count = 15;

            % This variable deals with checking if the rocket has returned
            % to earth or not. We stop the simulation if the rocket has
            % returned to earth, because once the rocket reaches a certain
            % within a certain range of earth's atmosphere, a tertiary
            % process takes place where the rocket alters it's trajectory
            % to allow it to re-enter earth's atmosphere. This simulation
            % does not cover that process.
            has_passed_0 = 0;

% Here we begin the simulation. The condition for the length of the
% simulation is restricted based on the max flgith duration set by the
% user.
while t <= max_flight_duration

    % Checking moon's current position
    theta = 360*t/T;

    x_m_c(i) = R*cosd(theta0 +theta);
    y_m_c(i) = R*sind(theta0 +theta);

    
    % The velocity for the i+1 indexed variable in a vector is determined 
    % by the instantaneous acceleration of the previous index multiplied 
    % by our time step, and added to the velocity of the previous index.
    v_x(i+1) = a_x(i)*dt+v_x(i);
    v_y(i+1) = a_y(i)*dt+v_y(i);

    % The position for the i+1 indexed variable in a vector is determined
    % in the same way as velocity is described above, except instead of the
    % acceleration of the prior index, we use the velocity.
    x(i+1)=v_x(i)*dt+x(i);
    y(i+1)=v_y(i)*dt+y(i);

    % Now we use our custom made function to find the next index of
    % acceleration based upon our x and y variables that we calculated on
    % the previous loop iteration
    [a_x(i+1), a_y(i+1)] = ACCELYX(x(i),y(i),x_m_c(i),y_m_c(i));

    % Here we utilize count, and say that if the count is 15, plot the x
    % and y coordinates for the rocket ship, as well as the moon's x and y
    % coordinates. The nested if statement ensures that the code only plots
    % coordinates of the moon that appear within the viewing window. After
    % plotting the 2 points nessecary, we reset count to 0. If the count is
    % not 15, we increment it by 1, and do not plot any points.
    if count == 15
        plot(app.UIAxes, x(i+1),y(i+1),'r.')

        if y_m_c(i) >= -3.5e8 && y_m_c(i) <= 3.5e8
            plot(app.UIAxes, x_m_c(i),y_m_c(i),'g.')
        end

        count = 0;
    else
        count = count+1;
    end

    % Another way we combat inadequate processing power is by using
    % something called a variable time step. Normally for simulations, we
    % increment the time between plotting 2 points by a set amount called a
    % time step. However, in order to accurately simulate the process
    % described by our simulation, we need a time step of 0.1 seconds. When
    % multiplied across the maximum of 14 days that our simulation allows
    % for, the CPU of computers that we consider relatively powerful still
    % struggles to calculate and plot all of the points in a timely manner.
    % What our variable time step does is as follows: When the rocket is
    % traveling in relatively constant motion, we do not need to simulate 
    % as many points, because no real change is happening in its movement, 
    % so we can change our time step to be larger. When our rocket is 
    % changing directions, we need many more points to accurately depict
    % it's motion, and therefore we need a smaller time step. Using
    % calculus, we change our time step with each iteration of the loop,
    % based on the magnitude of both the acceleration and the velocity of
    % the rocket
     dt = sqrt(v_x(i)^2+v_y(i)^2)/(sqrt(a_x(i)^2+a_y(i)^2)*10^(3));

    if dt > 1800

        dt = 1800;

    elseif dt < 0.1

        dt = 0.1;

    end

    % Update time by incrementing time by time step
    t = t + dt;

    % Increment our index by 1
    i = i+1;

    % Checking if it is time for first rocket burn and if the rocket has
    % burned
    if (t > first_rocket_burn_time) && (HB == 0) 

        % Because of physics, we can treat the change in velocity due to
        % the rocket burn as instantaneous
        v_x(i) = delta_V_during_burn + v_x(i);

        % Change Has Burned variable value to true
        HB = 1;

    end

     % Pause for a split second in between each iteration of the loop
     pause(1e-12)

     % Check if the rocket has passed the center of the earth in the first
     % phase of the simulation
     if x(i) >= 0
         has_passed_0 = 1;
     end

     % If the rocket has already passed the earth, and it has now crossed
     % the x = 0 and the y=0 line, we deem the rocket as returned to earth,
     % and stop the simulation. The user may still need to visually confirm
     % that the rocket has returned to earth without colliding with the
     % earth
     if x(i) <= 0 && y(i) <=0 && has_passed_0 == 1
         break
     end

     time_tracker = round(t/86400,2);
     accel_tracker = sqrt(a_x(i)^2+a_y(i)^2);
     velocity_tracker = sqrt(v_x(i)^2+v_y(i)^2);

     app.TripLengthLabel.Text = "Trip Length: " + num2str(time_tracker) + " days";
     app.CurrentAccelerationLabel.Text = "Current Acceleration: " + num2str(accel_tracker) + " m/s";
     app.CurrentVelocityLabel.Text = "Current Velocity: " + num2str(velocity_tracker) + " m/s";

end

% Update the simulation status
app.SimulationStatusLabel.Text = "Simulation Status: Complete!";

        end

        % Value changing function: MoonAngleSlider
        function MoonAngleSliderValueChanging(app, event)
            
            % Clear the figure
            cla(app.UIAxes)

            % Re-Zooms the graph to oringal viewing window
            xlim(app.UIAxes, [-3e8, 7e8])
            ylim(app.UIAxes, [-3.5e8, 3.5e8])

            app.CurrentAccelerationLabel.Text = "Current Acceleration: ";
            app.CurrentVelocityLabel.Text = "Current Velocity: ";
            app.TripLengthLabel.Text = "Trip length: ";
            app.SimulationStatusLabel.Text = "Simulation status:";

            % Update the text label to match the angle of the slider.
            % Initialize theta0 as the value of the slider 
            changingValue = event.Value;
            app.Label.Text = "("+ num2str(round(event.Value,2)) + ")";
            theta0 = event.Value;

            % Define the Constant of the Earth's radius and the radius of 
            % moon's orbit in meters
            RE = 6378100; % Radius of the Earth in meters
            R = 3.84e8; % Radius of the moon's orbit around earth in meters

            % Re-calculate all the earth's circle plot
            for a =  1:800

                theta = 360*a/800;

                x_m_e(a) = RE*cosd(theta);
                y_m_e(a) = RE*sind(theta);

                % To lower processing time, only plot the earth once the
                % loop is on it's final iteration
                if mod(a,800) == 0
                    plot(app.UIAxes,x_m_e,y_m_e,'.b')
                end
            end
            
            % Calculate the moon's x and y coordinate for the angle given
            % by the slider
            x_moon = R*cosd(theta0);
            y_moon = R*sind(theta0);

            % Plot the moons position
            plot(app.UIAxes, x_moon, y_moon, 'g*')
        end

        % Button pushed function: ExitAppButton
        function ExitAppButtonPushed(app, event)
            % Close the app
            app.delete
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 818 490];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Flight Path')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [17 62 528 428];

            % Create MoonAngleSliderLabel
            app.MoonAngleSliderLabel = uilabel(app.UIFigure);
            app.MoonAngleSliderLabel.HorizontalAlignment = 'right';
            app.MoonAngleSliderLabel.Position = [601 251 68 22];
            app.MoonAngleSliderLabel.Text = 'Moon Angle';

            % Create MoonAngleSlider
            app.MoonAngleSlider = uislider(app.UIFigure);
            app.MoonAngleSlider.Limits = [-60 60];
            app.MoonAngleSlider.Orientation = 'vertical';
            app.MoonAngleSlider.ValueChangingFcn = createCallbackFcn(app, @MoonAngleSliderValueChanging, true);
            app.MoonAngleSlider.Position = [686 190 3 121];

            % Create RUNSIMULATIONButton
            app.RUNSIMULATIONButton = uibutton(app.UIFigure, 'push');
            app.RUNSIMULATIONButton.ButtonPushedFcn = createCallbackFcn(app, @RUNSIMULATIONButtonPushed, true);
            app.RUNSIMULATIONButton.Position = [601 25 148 54];
            app.RUNSIMULATIONButton.Text = 'RUN SIMULATION';

            % Create MaxFlightDurationLabel
            app.MaxFlightDurationLabel = uilabel(app.UIFigure);
            app.MaxFlightDurationLabel.HorizontalAlignment = 'center';
            app.MaxFlightDurationLabel.Position = [597 119 67 30];
            app.MaxFlightDurationLabel.Text = {'Max  Flight '; 'Duration '};

            % Create MaxFlightDurationDropDown
            app.MaxFlightDurationDropDown = uidropdown(app.UIFigure);
            app.MaxFlightDurationDropDown.Items = {'6.5', '7', '7.5', '8', '14'};
            app.MaxFlightDurationDropDown.Position = [679 127 71 22];
            app.MaxFlightDurationDropDown.Value = '6.5';

            % Create InstructionsPanel
            app.InstructionsPanel = uipanel(app.UIFigure);
            app.InstructionsPanel.Title = 'Instructions Panel';
            app.InstructionsPanel.Visible = 'off';
            app.InstructionsPanel.Position = [86 6 640 480];

            % Create ExitButton
            app.ExitButton = uibutton(app.InstructionsPanel, 'push');
            app.ExitButton.ButtonPushedFcn = createCallbackFcn(app, @ExitButtonPushed, true);
            app.ExitButton.BusyAction = 'cancel';
            app.ExitButton.WordWrap = 'on';
            app.ExitButton.Position = [527 13 100 23];
            app.ExitButton.Text = 'Exit';

            % Create InstructionsText
            app.InstructionsText = uilabel(app.InstructionsPanel);
            app.InstructionsText.VerticalAlignment = 'top';
            app.InstructionsText.FontSize = 11;
            app.InstructionsText.Position = [16 30 579 420];
            app.InstructionsText.Text = {'Welcome to the Lunar Orbit Rocket Simulator, or L.O.R.S. for short!'; ''; 'In this simulator, you, the user, get to choose the various parameters involved in a simulated trip that takes a rocket '; 'from Earth, to our moon, and back to earth.'; ''; 'For simplification, this simulator will only cover the middle leg of the journey; Part of the parameters that the user '; 'inputs will be the initial velocity of the rocket(a.k.a. how fast the ship was moving once it exited Earth''s atmosphere),'; 'and the initial height of the rocket(a.k.a. how high off the surface of the earth the rocket made it.)'; ''; 'For reference, the height of earths atmosphere is around 10,000 meters.'; ''; 'The user also will set a starting angle for the moon in it''s orbit around earth. To simplify things for the user, we will'; 'make some assumptions:'; ''; '1) The first phase of the rocket launch will be directly in the negative x direction'; ''; '2) The initial velocity of the rocket will be downwards, (in the negative y direction).'; ''; '3) We will only consider angles -60 to +60 degrees for a rocket launch.'; ''; 'Like all space travel, there must be a deadline. In the Max Flight Duration drop down box the user can select the '; 'time constraints for the simulated rocket''s flight to and from our moon.'; ''; 'Lastly, is the matter of secondary thrust. Simply put, the spacecraft has ample excess fuel to aid in it''s journey to '; 'and from our moon. The factors that the user must decide are when and how much fuel the rocket uses. It  is '; 'relevant to note that the secondary thrusters can only fire one time during the entire journey, whether it be on the '; 'way to, or from the moon, as well as only in the positve or negative x direction.'; ''; 'The simulation should have loaded in with some pre-typed values, but if for some reason'; 'they did not load, here they are from top to bottom:'; '291900, 10818, 7.2, -110, 0 **Note, these values only work for large flight durations'};

            % Create HelpButton
            app.HelpButton = uibutton(app.UIFigure, 'push');
            app.HelpButton.ButtonPushedFcn = createCallbackFcn(app, @HelpButtonPushed, true);
            app.HelpButton.Position = [17 41 100 23];
            app.HelpButton.Text = 'Help';

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.HorizontalAlignment = 'center';
            app.Label.Position = [597 224 78 31];
            app.Label.Text = '(00.00)';

            % Create InitialAltitudeEditFieldLabel
            app.InitialAltitudeEditFieldLabel = uilabel(app.UIFigure);
            app.InitialAltitudeEditFieldLabel.HorizontalAlignment = 'right';
            app.InitialAltitudeEditFieldLabel.Position = [592 447 75 22];
            app.InitialAltitudeEditFieldLabel.Text = 'Initial Altitude';

            % Create InitialAltitudeEditField
            app.InitialAltitudeEditField = uieditfield(app.UIFigure, 'numeric');
            app.InitialAltitudeEditField.ValueDisplayFormat = '%.2f';
            app.InitialAltitudeEditField.HorizontalAlignment = 'left';
            app.InitialAltitudeEditField.Position = [682 447 75 22];
            app.InitialAltitudeEditField.Value = 291900;

            % Create InitialVelocityEditFieldLabel
            app.InitialVelocityEditFieldLabel = uilabel(app.UIFigure);
            app.InitialVelocityEditFieldLabel.HorizontalAlignment = 'right';
            app.InitialVelocityEditFieldLabel.Position = [586 413 78 22];
            app.InitialVelocityEditFieldLabel.Text = 'Initial Velocity';

            % Create InitialVelocityEditField
            app.InitialVelocityEditField = uieditfield(app.UIFigure, 'numeric');
            app.InitialVelocityEditField.ValueDisplayFormat = '%.2f';
            app.InitialVelocityEditField.HorizontalAlignment = 'left';
            app.InitialVelocityEditField.Position = [679 413 75 22];
            app.InitialVelocityEditField.Value = 10818;

            % Create FirstRocketBurnTimeEditFieldLabel
            app.FirstRocketBurnTimeEditFieldLabel = uilabel(app.UIFigure);
            app.FirstRocketBurnTimeEditFieldLabel.HorizontalAlignment = 'center';
            app.FirstRocketBurnTimeEditFieldLabel.Position = [592 374 72 30];
            app.FirstRocketBurnTimeEditFieldLabel.Text = {'First Rocket '; 'Burn Time'};

            % Create FirstRocketBurnTimeEditField
            app.FirstRocketBurnTimeEditField = uieditfield(app.UIFigure, 'numeric');
            app.FirstRocketBurnTimeEditField.ValueDisplayFormat = '%.2f';
            app.FirstRocketBurnTimeEditField.HorizontalAlignment = 'left';
            app.FirstRocketBurnTimeEditField.Position = [679 377 75 22];
            app.FirstRocketBurnTimeEditField.Value = 7.2;

            % Create BurnStrengthEditFieldLabel
            app.BurnStrengthEditFieldLabel = uilabel(app.UIFigure);
            app.BurnStrengthEditFieldLabel.HorizontalAlignment = 'center';
            app.BurnStrengthEditFieldLabel.Position = [589 342 79 22];
            app.BurnStrengthEditFieldLabel.Text = 'Burn Strength';

            % Create BurnStrengthEditField
            app.BurnStrengthEditField = uieditfield(app.UIFigure, 'numeric');
            app.BurnStrengthEditField.ValueDisplayFormat = '%.2f';
            app.BurnStrengthEditField.HorizontalAlignment = 'left';
            app.BurnStrengthEditField.Position = [679 342 75 22];
            app.BurnStrengthEditField.Value = -110;

            % Create SimulationStatusLabel
            app.SimulationStatusLabel = uilabel(app.UIFigure);
            app.SimulationStatusLabel.Position = [153 40 176 24];
            app.SimulationStatusLabel.Text = 'Simulation Status: ';

            % Create ExitAppButton
            app.ExitAppButton = uibutton(app.UIFigure, 'push');
            app.ExitAppButton.ButtonPushedFcn = createCallbackFcn(app, @ExitAppButtonPushed, true);
            app.ExitAppButton.Position = [17 10 69 20];
            app.ExitAppButton.Text = 'Exit App';

            % Create TripLengthLabel
            app.TripLengthLabel = uilabel(app.UIFigure);
            app.TripLengthLabel.Position = [153 8 176 24];
            app.TripLengthLabel.Text = 'Trip Length: ';

            % Create CurrentVelocityLabel
            app.CurrentVelocityLabel = uilabel(app.UIFigure);
            app.CurrentVelocityLabel.Position = [345 41 234 22];
            app.CurrentVelocityLabel.Text = 'Current Velocity:';

            % Create CurrentAccelerationLabel
            app.CurrentAccelerationLabel = uilabel(app.UIFigure);
            app.CurrentAccelerationLabel.Position = [345 9 242 22];
            app.CurrentAccelerationLabel.Text = 'Current Acceleration:';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = FINAL_SIMULATION

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end