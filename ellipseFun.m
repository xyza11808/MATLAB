function [x, y] = ellipseFun(Center, HorAndVerRadius, InputRadiu, rotation)
% generate a ellipse line shape according to input parameter
if nargin < 4
    rotation = 0; % whether to rotate axis
end

if isempty(InputRadiu)
    InputRadiu = -pi:0.01:pi;
end

x = Center(1) + HorAndVerRadius(1)*cos(InputRadiu + rotation);
y = Center(2) + HorAndVerRadius(2)*sin(InputRadiu + rotation);


