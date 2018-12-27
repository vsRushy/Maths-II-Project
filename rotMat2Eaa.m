function [euler_axis,euler_angle] = rotMat2Eaa(rotation_matrix)
% This function returns the Euler principal axis and the Euler principal
% angle. Note that the angle will be given in degrees and the axis will
% be given normalized.
% If the angle is 0, it returns one of the many possible euler_axis, but if the
% angle is 180, it returns one of the two possible euler angles.
aux_trace = trace(rotation_matrix);

euler_angle = acosd((aux_trace - 1) / 2);

skew_matrix = ((rotation_matrix - rotation_matrix') / (2 * sind(euler_angle)));

euler_axis = [skew_matrix(3, 2); skew_matrix(1, 3); skew_matrix(2, 1)];

if euler_angle == 180
    aux_mat = (rotation_matrix - eye(3)*(-1))/2;
    euler_axis = [aux_mat(1,1); aux_mat(2,2); aux_mat(3,3)];
end

if isnan(euler_axis)
    if euler_angle == 0
       euler_axis = [1; 1; 1] / sqrt(3);  % We return an axis (with module 1, of course) from the infinite that there are
    end
end

end

