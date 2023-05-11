function [AX AY] = ACCELYX(x,y,x_m,y_m)

% Takes in the position of the space ship and moon to calculate the
% acceleration due to gravity from the earth and moon on the ship

% Inputs:
% x_m, y_m are the coordinates of the moon
% x, y are the coordiantes of the ship
% Outputs:
% AX, AY is the accelerations of the ship from the moon and earth in the x
% and y direction respectively 

% The function calculates the acceleration due to the moon and earth's
% gravity on the ship using an equation based off newton's law of
% gravitation. In order to simplify the calculation, it is broken into
% three steps: the earth's contribution, the moon's contribution, and the
% final calculation


% Constants

G = 6.647*10^-11; % gravitational constant
M_e = 5.972*10^24; % mass of earth (kg)
M_m = 7.348*10^22; % mass of moon (kg)

% Earth portion of calculation

  EarthCalcX = x/((x^2+y^2)^(3/2));
  EarthCalcY = y/((x^2+y^2)^(3/2));

% Moon portion of calculation

  MoonCalcX = (x-x_m)/((((x-x_m)^2)+((y-y_m)^2))^(3/2));
  MoonCalcY = (y-y_m)/((((x-x_m)^2)+((y-y_m)^2))^(3/2));

% Final acceleration calcuation 

  AY = -G*(M_e*EarthCalcY + M_m*MoonCalcY);
  AX = -G*(M_e*EarthCalcX + M_m*MoonCalcX);

end