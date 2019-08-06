% 描述报告中所有的图形并证明结果；                 这八个程序对应word中的八个问题；
clear;clc;close all
[s1 fs1] = audioread('train_long\1.wav'); %wavread函数是把一个指定的wave文件采样，然后赋给s1，采样率是fs1;
[s2 fs2] = audioread('train\6.wav'); 

set(0,'defaultfigurecolor','w');
%Question 1； Q1的作用：把录入的语音采样转换成波形；     
disp('> Question 1：时域波形');          %disp的作用是显示这个字符串；
t = 0:1/fs1:(length(s1) - 1)/fs1;%录入的语音时间轴都除以fs以还原时域内的真实时间
figure(1),plot(t, s1), axis([0, (length(s1) - 1)/fs1 -1.0 1.0]);
title('Plot of signal 1.wav');
xlabel('Time [s]');
ylabel('Amplitude (normalized)')
pause
%close all 

%Question 2 (linear)%完成的功能是加框
disp('> Question 2：能量谱');
M = 160;
N = 320;
frames = blockFrames(s1, fs1, M, N);       %调用blockFrames函数，加窗
t = N / 2;
tm = length(s1) / fs1;     %产生第二幅图；
figure(2),subplot(1,2,1);    %figure函数的作用是在原窗口不关闭的基础上产生新的图形窗口；subplot函数的作用是在同一个图形窗口中布置M*N幅图，并使其中的第K幅图成为当前图；
imagesc([0 tm], [0 fs1/2], abs(frames(1:t, :)).^2), axis xy;     %imagesc产生谱图；
title('Power Spectrum (M = 160, N = 320)');
xlabel('Time [s]');
ylabel('Frequency [Hz]');
colorbar;

%Question 3 (logarithmic)                     %计算能量谱画出来
disp('> Question 3: 对数能量谱');
figure(2),subplot(1,2,2);
imagesc([0 tm], [0 fs1/2], 20 * log10(abs(frames(1:t, :)).^2)), axis xy;   %imagesc(x,y,C)，其中X为横坐标的范围，Y为纵坐标的范围，c决定了图形的轮廓及各处颜色的深浅。
title('Logarithmic Power Spectrum (M = 160, N = 320)');
xlabel('Time [s]');   
ylabel('Frequency [Hz]');
colorbar     %以不同颜色代表曲面的高度，显示一个水平或垂直的颜色标尺;
%以下是在做什么，目的是什么
D=get(gcf,'Position');   %获取句柄对象指定位置的属性值；gcf获取当前图形窗口句柄；
set(gcf,'Position',round([D(1)*.5 D(2)*.5 D(3)*2 D(4)*1.3]))   %设置句柄对象指定位置的属性值；
pause
%close all

%Question 4    %完成的功能是MEL频率弯折
disp('> Question 4: Plots for different values for N');
lN = [160 320 480];
u=220;    %u是什么
for i = 1:length(lN)
    N = lN(i);
    M = round(N / 2);
    frames = blockFrames(s1, fs1, M, N);
    t = N / 2;
    temp = size(frames);
    nbframes = temp(2);
    u=u+1;
    subplot(u)
    imagesc([0 tm], [0 fs1/2], 20 * log10(abs(frames(1:t, :)).^2)), axis xy;    %imagesc命令用来画出能量谱；
%Mini-Project: An automatic speaker recognition system
%Christian Cornaz, Urs Hunkeler 03.02.2003
    title(sprintf('Power Spectrum (M = %i, N = %i, frames = %i)', M, N, nbframes));
    xlabel('Time [s]');
    ylabel('Frequency [Hz]');
    colorbar
end
D=get(gcf,'Position');
set(gcf,'Position',round([D(1)*.5 D(2)*.5 D(3)*1.5 D(4)*1.5]))
pause
close all
   
%Question 5  绘制mel空间滤波器组，为什么？？？？？？？？？？？？？？？？？？？？？？？？
disp('> Question 5: Mel Space');
plot(linspace(0, (fs1/2), 129), (melfb(20, 256, fs1))');
title('Mel-Spaced Filterbank');
xlabel('Frequency [Hz]');
pause
close all

%Question 6    %mel倒谱，计算在mel频率变换前后声音文件的频率
disp('> Question 6: Modified spectrum');
M = 100;
N = 256;
frames = blockFrames(s1, fs1, M, N);    %再次调用这个函数
n2 = 1 + floor(N / 2);
m = melfb(20, N, fs1);
z = m * abs(frames(1:n2, :)).^2;
t = N / 2;
tm = length(s1) / fs1;
subplot(121)
imagesc([0 tm], [0 fs1/2], abs(frames(1:n2, :)).^2), axis xy;
title('Power Spectrum unmodified');
xlabel('Time [s]');
ylabel('Frequency [Hz]');
colorbar;
subplot(122)
imagesc([0 tm], [0 20], z), axis xy;
title('Power Spectrum modified through Mel Cepstrum filter');
xlabel('Time [s]');
ylabel('Number of Filter in Filter Bank');
colorbar;
D=get(gcf,'Position');
set(gcf,'Position',[0 D(2) D(3)*2 D(4)])
pause
close all

%Question 7  这里应该算是开始了vqlbg程序；并在2维平面中画出数据点
disp('> Question 7: 2D plot of accoustic vectors');
c1 = mfcc(s1, fs1);     %调用mfcc函数；
c2 = mfcc(s2, fs2);
plot(c1(5, :), c1(6, :), 'or');%圆圈标记，红色；
hold on;
plot(c2(5, :), c2(6, :), 'xb');  %叉号标记，蓝色；
xlabel('5th Dimension');
ylabel('6th Dimension');
legend('Signal 1', 'Signal 2');%legend函数的作用是在指定位置建立图例。Signal 1,Signal 2是图例中的文字注释
title('2D plot of accoustic vectors');
pause
close all

%Question 8
disp('> Question 8: Plot of the 2D trained VQ codewords')  %绘制二维的训练矢量码字；画出生成的VQ码字
d1 = vqlbg(c1,16);
d2 = vqlbg(c2,16);
% plot(c1(5, :), c1(6, :), 'xr')
hold on
% plot(d1(5, :), d1(6, :), 'vk')
 plot(d1(5, :), d1(6, :), 'or')
% plot(c2(5, :), c2(6, :), 'xb')
% plot(d2(5, :), d2(6, :), '+k')
plot(d2(5, :), d2(6, :), 'xb')
xlabel('5th Dimension');
ylabel('6th Dimension');
% legend('Speaker 1', 'Codebook 1', 'Speaker 2', 'Codebook 2');
legend('Codebook 1',  'Codebook 2');
title('2D plot of accoustic vectors');
pause
close all