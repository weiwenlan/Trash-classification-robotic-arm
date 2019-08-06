function varargout = Lock(varargin)
% LOCK MATLAB code for Lock.fig
%      LOCK, by itself, creates a new LOCK or raises the existing
%      singleton*.
%
%      H = LOCK returns the handle to a new LOCK or the handle to
%      the existing singleton*.
%
%      LOCK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOCK.M with the given input arguments.
%
%      LOCK('Property','Value',...) creates a new LOCK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Lock_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Lock_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Lock

% Last Modified by GUIDE v2.5 06-Aug-2019 06:19:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Lock_OpeningFcn, ...
                   'gui_OutputFcn',  @Lock_OutputFcn, ...
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


% --- Executes just before Lock is made visible.
function Lock_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Lock (see VARARGIN)

% Choose default command line output for Lock
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Lock wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global rbd
rbd=0;

% --- Outputs from this function are returned to the command line.
function varargout = Lock_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
global n
n=1;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str='Training ...';
set(handles.edit1,'string',str);
train_record;
save ('code','code','dkmax','dkmin');

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global passcode
load code.mat
str='Testing ...';
set(handles.edit1,'string',str);
test_record;
if passcode==1
    str='Correct !';
set(handles.edit1,'string',str);
pause(1.5)
close all
GUI2
pause(1.5)
close all
GUI
elseif passcode==0
       str='Wrong Code !';
set(handles.edit1,'string',str);
else
    str='Input Again !';
set(handles.edit1,'string',str);
end

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc
% Hint: get(hObject,'Value') returns toggle state of radiobutton1



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
