function M3 = blockFrames(s, fs, m, n)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function: blockFrames() Puts the signal into frames 分帧加窗
% input :   s:输入的语音数字信号   fs：采样频率  m：帧移  n：窗长
% output:   M3:分帧后信号进行加窗并求出频率的矩阵
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%分帧函数开始处
l = length(s);  %l信号s的长度
nbFrame = floor((l - n) / m) + 1;
%计算帧数floor函数是取接近A的整数，但又不是四舍五入；
for i = 1:n
 %i表示每帧的点
for j = 1:nbFrame
 %j表示帧数
M(i, j) = s(((j - 1) * m) + i);
%M存储分帧后的信号，第一行表示第一帧，第二行表示第二帧
end
end
%%分帧结束处

h = hamming(n);
M2 = diag(h) * M;
%对每帧信号加窗处理：窗函数变成对角阵再乘以分帧信号矩阵
for i = 1:nbFrame
M3(:, i) = fft(M2(:, i));
end
%对每帧进行傅里叶变化，获得频率值
