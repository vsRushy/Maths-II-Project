function [rotation_matrix] = Eaa2rotMat(axis, angle)
% This function returns the rotation matrix given an axis and angle.
% param 1: Euler axis (column vector)
% param 2: Euler angle(in degrees)

axis_module = sqrt(axis' * axis);
axis_normalized = axis / axis_module;

c = cosd(angle);
s = sind(angle);

sk_matrix = [0 -axis_normalized(3) axis_normalized(2);
             axis_normalized(3) 0 -axis_normalized(1);
             -axis_normalized(2) axis_normalized(1) 0];

rotation_matrix = eye(3) * c + (axis_normalized * axis_normalized') * (1 - c) + s * sk_matrix;

end

