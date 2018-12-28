function varargout = trackBall(varargin)
% TRACKBALL MATLAB code for trackBall.fig
%      TRACKBALL, by itself, creates a new TRACKBALL or raises the existing
%      singleton*.
%
%      H = TRACKBALL returns the handle to a new TRACKBALL or the handle to
%      the existing singleton*.
%
%      TRACKBALL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACKBALL.M with the given input arguments.
%
%      TRACKBALL('Property','Value',...) creates a new TRACKBALL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trackBall_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trackBall_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trackBall

% Last Modified by GUIDE v2.5 28-Dec-2018 11:16:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trackBall_OpeningFcn, ...
                   'gui_OutputFcn',  @trackBall_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before trackBall is made visible.
function trackBall_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trackBall (see VARARGIN)


set(hObject,'WindowButtonDownFcn',{@my_MouseClickFcn,handles.axes1});
set(hObject,'WindowButtonUpFcn',{@my_MouseReleaseFcn,handles.axes1});
axes(handles.axes1);

handles.Cube=DrawCube(eye(3));

set(handles.axes1,'CameraPosition',...
    [0 0 5],'CameraTarget',...
    [0 0 -5],'CameraUpVector',...
    [0 1 0],'DataAspectRatio',...
    [1 1 1]);

set(handles.axes1,'xlim',[-3 3],'ylim',[-3 3],'visible','off','color','none');

% Choose default command line output for trackBall
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes trackBall wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = trackBall_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function my_MouseClickFcn(obj,event,hObject)

handles=guidata(obj);
xlim = get(handles.axes1,'xlim');
ylim = get(handles.axes1,'ylim');
mousepos=get(handles.axes1,'CurrentPoint');
xmouse = mousepos(1,1);
ymouse = mousepos(1,2);

if xmouse > xlim(1) && xmouse < xlim(2) && ymouse > ylim(1) && ymouse < ylim(2)

    set(handles.figure1,'WindowButtonMotionFcn',{@my_MouseMoveFcn,hObject});
    
    % Get mouse input x-y. Here we store pos of the first click in the handles.
    handles.x_click = xmouse;
    handles.y_click = ymouse;
end
guidata(hObject,handles)

function my_MouseReleaseFcn(obj,event,hObject)
handles=guidata(hObject);
set(handles.figure1,'WindowButtonMotionFcn','');
guidata(hObject,handles);

function my_MouseMoveFcn(obj,event,hObject)

handles=guidata(obj);
xlim = get(handles.axes1,'xlim');
ylim = get(handles.axes1,'ylim');
mousepos=get(handles.axes1,'CurrentPoint');
xmouse = mousepos(1,1);
ymouse = mousepos(1,2);
% -----
i_vect = zeros(3, 1);
f_vect = zeros(3, 1);
r = 1;

if xmouse > xlim(1) && xmouse < xlim(2) && ymouse > ylim(1) && ymouse < ylim(2)

    % In order to rotate the cube, we need to use the Holdoyd's arcball
    % method, as specified in the project document.
    
    % Get the previously stored mouse position x-y
    m_x = handles.x_click;
    m_y = handles.y_click;
    
    % --------------- First step... (Initial mouse pos)
    if((m_x^2 + m_y^2) < 1 / 2 * r^2)
        m_z = sqrt(r^2 - m_x^2 - m_y^2); % Apply formula
        i_vect = [m_x; m_y; m_z];
    end
    if(m_x^2 + m_y^2 >= 1 / 2 * r^2)
        i_vect= [m_x; m_y; (r^2) / (2 * sqrt(m_x^2 + m_y^2))]; % Apply formula
        i_vect= (r * i_vect) / norm(i_vect); % Make sure this vector is normalized!!
    end
    
    % --------------- Second step... (Current mouse pos)
    if(xmouse^2 + ymouse^2 < 1 / 2 * r^2)
        zmouse= sqrt(r^2 - xmouse^2 - ymouse^2); % Apply formula
        f_vect = [xmouse; ymouse; zmouse];
    end
    if(xmouse^2 + ymouse^2 >= 1 / 2 * r^2)
        f_vect= [xmouse; ymouse; (r^2)/(2 * sqrt(xmouse^2 + ymouse^2))]; % Apply formula
        f_vect= (r * f_vect) / norm(f_vect); % Make sure this vector is normalized!!
    end
    
    % Now we can rotate the cube correctly
    r_axis = cross(f_vect, i_vect); % Get rotation axis
    r_angle = -acosd(dot(f_vect, i_vect)); % Get the rotation angle between the two vectors. We also need to negate the angle (IMPORTANT).
   
    R = Eaa2rotMat(r_axis, r_angle);
    handles.Cube = RedrawCube(R, handles);
    
end
guidata(hObject,handles);

function h = DrawCube(R)

M0 = [ -1 -1 1;   %Node 1
       -1 1 1;    %Node 2
        1 1 1;    %Node 3
        1 -1 1;   %Node 4
       -1 -1 -1;  %Node 5
       -1 1 -1;   %Node 6
        1 1 -1;   %Node 7
        1 -1 -1]; %Node 8

M = (R*M0')';


x = M(:,1);
y = M(:,2);
z = M(:,3);


con = [1 2 3 4;
    5 6 7 8;
    4 3 7 8;
    1 2 6 5;
    1 4 8 5;
    2 3 7 6]';

x = reshape(x(con(:)),[4,6]);
y = reshape(y(con(:)),[4,6]);
z = reshape(z(con(:)),[4,6]);

c = 1/255*[255 248 88;
    0 0 0;
    57 183 225;
    57 183 0;
    255 178 0;
    255 0 0];

h = fill3(x,y,z, 1:6);

for q = 1:length(c)
    h(q).FaceColor = c(q,:);
end

% NOTE: This function has been modified so that we can access the handles
% when we draw the cube. Like this, we can update anything that it is on the
% handles, mainly for updating the GUIDE fields any time we draw the cube.
function h = RedrawCube(R, hin)

h = hin.Cube;
c = 1/255*[255 248 88;
    0 0 0;
    57 183 225;
    57 183 0;
    255 178 0;
    255 0 0];

M0 = [ -1 -1 1;   %Node 1
       -1 1 1;    %Node 2
        1 1 1;    %Node 3
        1 -1 1;   %Node 4
       -1 -1 -1;  %Node 5
       -1 1 -1;   %Node 6
        1 1 -1;   %Node 7
        1 -1 -1]; %Node 8

M = (R*M0')';


x = M(:,1);
y = M(:,2);
z = M(:,3);


con = [1 2 3 4;
    5 6 7 8;
    4 3 7 8;
    1 2 6 5;
    1 4 8 5;
    2 3 7 6]';

x = reshape(x(con(:)),[4,6]);
y = reshape(y(con(:)),[4,6]);
z = reshape(z(con(:)),[4,6]);

for q = 1:6
    h(q).Vertices = [x(:,q) y(:,q) z(:,q)];
    h(q).FaceColor = c(q,:);
end

SetGuideRotMat(hin, R);
SetEPAAFromRotMat(hin, R);
SetEulerAnglesFromRotMat(hin, R);
SetRotationVectorFromRotMat(hin, R);
SetQuaternionFromRotMat(hin, R);


% --- Executes on button press in Push_Button_Quaternion.
function Push_Button_Quaternion_Callback(hObject, eventdata, handles)
% hObject    handle to Push_Button_Quaternion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
quat_0 = str2double(get(handles.q_0_edit, 'String'));
quat_1 = str2double(get(handles.q_1_edit, 'String'));
quat_2 = str2double(get(handles.q_2_edit, 'String'));
quat_3 = str2double(get(handles.q_3_edit, 'String'));
quat = [quat_0; quat_1; quat_2; quat_3];
R = Quat2rotMat(quat);
SetGuideRotMat(handles, R);
SetEPAAFromRotMat(handles, R);
SetEulerAnglesFromRotMat(handles, R);
SetRotationVectorFromRotMat(handles, R);
handles.Cube = RedrawCube(R, handles);


function q_0_edit_Callback(hObject, eventdata, handles)
% hObject    handle to q_0_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q_0_edit as text
%        str2double(get(hObject,'String')) returns contents of q_0_edit as a double


% --- Executes during object creation, after setting all properties.
function q_0_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q_0_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function q_1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to q_1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q_1_edit as text
%        str2double(get(hObject,'String')) returns contents of q_1_edit as a double


% --- Executes during object creation, after setting all properties.
function q_1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q_1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function q_2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to q_2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q_2_edit as text
%        str2double(get(hObject,'String')) returns contents of q_2_edit as a double


% --- Executes during object creation, after setting all properties.
function q_2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q_2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function q_3_edit_Callback(hObject, eventdata, handles)
% hObject    handle to q_3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q_3_edit as text
%        str2double(get(hObject,'String')) returns contents of q_3_edit as a double


% --- Executes during object creation, after setting all properties.
function q_3_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q_3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Reset_Button.
function Reset_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Reset_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ------------ The following is not needed anymore. It was done when we didn't have the
% trackball yet.

%ResetEPAA(handles);
%ResetQuaternion(handles);
%ResetEulerAngles(handles);
%ResetRotationVector(handles);
%ResetRotationMatrix(handles);

% ------------

R = eye(3);
handles.Cube = RedrawCube(R, handles);
SetGuideRotMat(handles, R);


function u_angle_edit_Callback(hObject, eventdata, handles)
% hObject    handle to u_angle_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of u_angle_edit as text
%        str2double(get(hObject,'String')) returns contents of u_angle_edit as a double


% --- Executes during object creation, after setting all properties.
function u_angle_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to u_angle_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function u_x_edit_Callback(hObject, eventdata, handles)
% hObject    handle to u_x_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of u_x_edit as text
%        str2double(get(hObject,'String')) returns contents of u_x_edit as a double


% --- Executes during object creation, after setting all properties.
function u_x_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to u_x_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function u_y_edit_Callback(hObject, eventdata, handles)
% hObject    handle to u_y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of u_y_edit as text
%        str2double(get(hObject,'String')) returns contents of u_y_edit as a double


% --- Executes during object creation, after setting all properties.
function u_y_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to u_y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function u_z_edit_Callback(hObject, eventdata, handles)
% hObject    handle to u_z_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of u_z_edit as text
%        str2double(get(hObject,'String')) returns contents of u_z_edit as a double



% --- Executes during object creation, after setting all properties.
function u_z_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to u_z_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Push_Button_Euler_Principle_Angle_and_Axis.
function Push_Button_Euler_Principle_Angle_and_Axis_Callback(hObject, eventdata, handles)
% hObject    handle to Push_Button_Euler_Principle_Angle_and_Axis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
u_x = str2double(get(handles.u_x_edit, 'String'));
u_y = str2double(get(handles.u_y_edit, 'String'));
u_z = str2double(get(handles.u_z_edit, 'String'));
u_axis = [u_x; u_y; u_z];
u_angle = str2double(get(handles.u_angle_edit, 'String'));
R = Eaa2rotMat(u_axis, u_angle);
SetGuideRotMat(handles, R);
SetEulerAnglesFromRotMat(handles, R);
SetRotationVectorFromRotMat(handles, R);
SetQuaternionFromRotMat(handles, R);
handles.Cube = RedrawCube(R, handles);


function phi_edit_Callback(hObject, eventdata, handles)
% hObject    handle to phi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of phi_edit as text
%        str2double(get(hObject,'String')) returns contents of phi_edit as a double


% --- Executes during object creation, after setting all properties.
function phi_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function theta_edit_Callback(hObject, eventdata, handles)
% hObject    handle to theta_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of theta_edit as text
%        str2double(get(hObject,'String')) returns contents of theta_edit as a double


% --- Executes during object creation, after setting all properties.
function theta_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to theta_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function psi_edit_Callback(hObject, eventdata, handles)
% hObject    handle to psi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psi_edit as text
%        str2double(get(hObject,'String')) returns contents of psi_edit as a double


% --- Executes during object creation, after setting all properties.
function psi_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Push_Button_Euler_Angles.
function Push_Button_Euler_Angles_Callback(hObject, eventdata, handles)
% hObject    handle to Push_Button_Euler_Angles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
e_phi = str2double(get(handles.phi_edit, 'String'));
e_theta = str2double(get(handles.theta_edit, 'String'));
e_psi = str2double(get(handles.psi_edit, 'String'));
R = eAngles2rotM(e_phi, e_theta, e_psi);
SetGuideRotMat(handles, R);
SetEPAAFromRotMat(handles, R);
SetRotationVectorFromRotMat(handles, R);
SetQuaternionFromRotMat(handles, R);
handles.Cube = RedrawCube(R, handles);


% --- Executes on button press in Push_Button_Rotation_Vector.
function Push_Button_Rotation_Vector_Callback(hObject, eventdata, handles)
% hObject    handle to Push_Button_Rotation_Vector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
x_rot_v = str2double(get(handles.x_rot_edit, 'String'));
y_rot_v = str2double(get(handles.y_rot_edit, 'String'));
z_rot_v = str2double(get(handles.z_rot_edit, 'String'));
rot_vector = [x_rot_v; y_rot_v; z_rot_v];
R = rotVec2rotMat(rot_vector);
SetGuideRotMat(handles, R);
SetEPAAFromRotMat(handles, R);
SetEulerAnglesFromRotMat(handles, R);
SetQuaternionFromRotMat(handles, R);
handles.Cube = RedrawCube(R, handles);


function x_rot_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x_rot_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of x_rot_edit as text
%        str2double(get(hObject,'String')) returns contents of x_rot_edit as a double


% --- Executes during object creation, after setting all properties.
function x_rot_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_rot_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y_rot_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y_rot_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of y_rot_edit as text
%        str2double(get(hObject,'String')) returns contents of y_rot_edit as a double


% --- Executes during object creation, after setting all properties.
function y_rot_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_rot_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z_rot_edit_Callback(hObject, eventdata, handles)
% hObject    handle to z_rot_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of z_rot_edit as text
%        str2double(get(hObject,'String')) returns contents of z_rot_edit as a double


% --- Executes during object creation, after setting all properties.
function z_rot_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_rot_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------


function ResetQuaternion(handles)
    set(handles.q_0_edit, 'String', '0');
    set(handles.q_1_edit, 'String', '0');
    set(handles.q_2_edit, 'String', '0');
    set(handles.q_3_edit, 'String', '0');
    
function ResetEPAA(handles)
    set(handles.u_angle_edit, 'String', '0');
    set(handles.u_x_edit, 'String', '0');
    set(handles.u_y_edit, 'String', '0');
    set(handles.u_z_edit, 'String', '0');
    
function ResetEulerAngles(handles)
    set(handles.phi_edit, 'String', '0');
    set(handles.theta_edit, 'String', '0');
    set(handles.psi_edit, 'String', '0');
    
function ResetRotationVector(handles)
    set(handles.x_rot_edit, 'String', '0');
    set(handles.y_rot_edit, 'String', '0');
    set(handles.z_rot_edit, 'String', '0');
    
function ResetRotationMatrix(handles)
    set(handles.rm_11, 'String', '1');
    set(handles.rm_12, 'String', '0');
    set(handles.rm_13, 'String', '0');
    set(handles.rm_21, 'String', '0');
    set(handles.rm_22, 'String', '1');
    set(handles.rm_23, 'String', '0');
    set(handles.rm_31, 'String', '0');
    set(handles.rm_32, 'String', '0');
    set(handles.rm_33, 'String', '1');
    
function SetGuideRotMat(handles, rotation_matrix)
    set(handles.rm_11, 'String', rotation_matrix(1, 1));
    set(handles.rm_12, 'String', rotation_matrix(1, 2));
    set(handles.rm_13, 'String', rotation_matrix(1, 3));
    set(handles.rm_21, 'String', rotation_matrix(2, 1));
    set(handles.rm_22, 'String', rotation_matrix(2, 2));
    set(handles.rm_23, 'String', rotation_matrix(2, 3));
    set(handles.rm_31, 'String', rotation_matrix(3, 1));
    set(handles.rm_32, 'String', rotation_matrix(3, 2));
    set(handles.rm_33, 'String', rotation_matrix(3, 3));
        
function rotation_matrix = GetGuideRotMat(handles)
    rotation_matrix(1, 1) = str2double(get(handles.rm_11, 'String'));
    rotation_matrix(1, 2) = str2double(get(handles.rm_12, 'String'));
    rotation_matrix(1, 3) = str2double(get(handles.rm_13, 'String'));
    rotation_matrix(2, 1) = str2double(get(handles.rm_21, 'String'));
    rotation_matrix(2, 2) = str2double(get(handles.rm_22, 'String'));
    rotation_matrix(2, 3) = str2double(get(handles.rm_23, 'String'));
    rotation_matrix(3, 1) = str2double(get(handles.rm_31, 'String'));
    rotation_matrix(3, 2) = str2double(get(handles.rm_32, 'String'));
    rotation_matrix(3, 3) = str2double(get(handles.rm_33, 'String'));
        
% ---------

function SetEPAAFromRotMat(handles, rotation_matrix)
    [e_axis, e_angle] = rotMat2Eaa(rotation_matrix);
    set(handles.u_angle_edit, 'String', e_angle);
    set(handles.u_x_edit, 'String', e_axis(1));
    set(handles.u_y_edit, 'String', e_axis(2));
    set(handles.u_z_edit, 'String', e_axis(3));
    
function SetEulerAnglesFromRotMat(handles, rotation_matrix)
    [a_1, a_2, a_3] = rotM2eAngles(rotation_matrix);
    set(handles.phi_edit, 'String', a_1);
    set(handles.theta_edit, 'String', a_2);
    set(handles.psi_edit, 'String', a_3);
    
function SetRotationVectorFromRotMat(handles, rotation_matrix)
    rot_vec = rotM2rotVec(rotation_matrix);
    set(handles.x_rot_edit, 'String', rot_vec(1));
    set(handles.y_rot_edit, 'String', rot_vec(2));
    set(handles.z_rot_edit, 'String', rot_vec(3));

function SetQuaternionFromRotMat(handles, rotation_matrix)
    quat = rotM2Quat(rotation_matrix);
    set(handles.q_0_edit, 'String', quat(1));
    set(handles.q_1_edit, 'String', quat(2));
    set(handles.q_2_edit, 'String', quat(3));
    set(handles.q_3_edit, 'String', quat(4));
    
    
