% function: test_record() 录音并进行检测，供gui调用，并返回结果给gui

fs=16000;

fprintf('testing...\n');

delete('test/*.wav');  %删除旧的测试音频
mm=1;%从头开始

y=audiorecorder(fs, 16, 1);
recordblocking(y,3);%录制3秒

name=strcat('test\',...
            num2str(mm),'.wav');
        
y1 = getaudiodata(y,'int16');
audiowrite(name,y1,fs);
cut(name);

result=test('test\',mm, code, dkmax, dkmin);
disp(result);

% set(con_text,'string',result);
