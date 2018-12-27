function rotation_matrix = rotVec2rotMat(rot_vector)
%ROTVEC2ROTMAT This functions returns the rotation matrix of a given
%rotation vector.
% NOTE: The vector has to be dimensions [3, 1].
%   Input: rotation vector
%   Output: rotation matrix

vn = norm(rot_vector);
rot_vector = rot_vector / vn;

sk_matrix = [0 -rot_vector(3) rot_vector(2);
             rot_vector(3) 0 -rot_vector(1);
             -rot_vector(2) rot_vector(1) 0];

rotation_matrix = eye(3) * cosd(vn) + (1 - cosd(vn)) * (rot_vector * rot_vector') + sk_matrix * sind(vn);

end

