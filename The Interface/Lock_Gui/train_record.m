% function y=record()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function: train_record() 录音并进行训练，供gui调用，并返回结果给gui
% rbd=get(con_rbd,'value');
global rbd n std
if (rbd)
    delete('train/*.wav');
    n=1;%从头开始
end
fs=16000;           %取样频率

% fprintf('Press any key to start %g seconds of recording...\n',duration);
% 
% pause;

fprintf('training...\n');
y=audiorecorder(fs,16,1);         % 16bit 单通道
recordblocking(y,3); %录制3秒
% fprintf('Finished training.\n');
% str=num2str(file,n);
y1 = getaudiodata(y,'int16');
name=strcat('train\',...
            num2str(n),'.wav'); % n为全局变量,组合成字符串
audiowrite(name,y1,fs);
% fprintf('Press any key to play the recording...\n');
% 
% pause;
[code, dkmax, dkmin]=train('train\',n);

% set(con_text,'string',[ num2str(n) '.wav' ]);
str=[ num2str(n) '.wav'] ;
set(handles.edit1,'string',str);
% audioplayer(y,fs);
n=n+1;  %指向下一次训练

