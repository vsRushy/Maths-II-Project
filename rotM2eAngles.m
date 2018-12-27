function [angle1, angle2, angle3] = rotM2eAngles(rotation_matrix)
% This function returns the Euler angles in degrees given a rotation
% matrix.

angle2 = asind(rotation_matrix(3, 1));
angle1 = atan2d((rotation_matrix(3, 2) / cosd(angle2)), (rotation_matrix(3, 3) / cosd(angle2)));
angle3 = atan2d((rotation_matrix(2, 1) / cosd(angle2)), (rotation_matrix(1, 1) / cosd(angle2)));

end

