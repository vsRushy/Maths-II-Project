function rotation_matrix = eAngles2rotM(angle1, angle2, angle3)
% This function gives the rotation matrix given the Euler angles in
% degrees.

rotation_matrix = [cosd(angle2)*cosd(angle3) cosd(angle3)*sind(angle2)*sind(angle1)-cosd(angle1)*sind(angle3) cosd(angle3)*cosd(angle1)*sind(angle2)+sind(angle3)*sind(angle1);
                   cosd(angle2)*sind(angle3) sind(angle3)*sind(angle2)*sind(angle1)+cosd(angle1)*cosd(angle3) sind(angle3)*sind(angle2)*cosd(angle1)-cosd(angle3)*sind(angle1);   
                   -sind(angle2) cosd(angle2)*sind(angle1) cosd(angle2)*cosd(angle1)];

end

