function c=mfcc(s,fs)   % 创建函数mfcc，其中，c为输出变量，mfcc为函数名，s、fs为输入变量；

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function: mfcc() 计算mel频率倒谱系数
% input :   s:输入的语音数字信号   fs：采样频率
% output:   MFCC特征系数
% rewriter: yuhansgg（Shi Gaige）
% time:     2017.4.9
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%预加重
a=0.98;
len=length(s);
for i=2:len
    s1(i)=s(i)-a*s(i-1);%形成了一个新的信号s1；
end
%figure(2),plot(s1),title('heavyed signal');  s1为预加重后的信号；

%计算功率谱密度

n=320;%每个帧的采样点数
m=160;%相邻帧起点之间距离帧与帧之间的偏移；
% [Pxx,w]=pwelch(s1,n,m,256,10000);  这个函数是计算括号内所描述函数的功率谱密度；

%分帧
frame=floor((len-n)/m)+1;%信号分帧的个数，floor的作用是取接近于括号内A的整数；
for j=1:frame %一列为一帧
    for i=1:n
        z(i,j)=s1((j-1)*m+i);  %这句话对吗，s1不是从2开始的吗？1
    end
end

%加窗hamming
h=hamming(n);
for j=1:frame
    for i=1:n
        z2(i,j)=h(i)*z(i,j);%加窗；
    end
end
% z3=z2(:);同上
% figure(4),plot(z3),title('window')   

% fft变换
for j=1:frame
    FFT(:,j)=fft(z2(:,j));%每一帧都要进行傅氏变换；
end

%melfb 生成mel域滤波器组；
m=melfb(20,n,fs);     % 这里应该是调用melfb函数，这里取p=20，指滤波器个数；
n2=1+floor(n/2);
mel=m*abs(FFT(1:n2,:)).^2; %计算经mel滤波器组加权后的能量值；abs(FFT(1:n2,:)).^2为能量谱，幅度平方谱通过美尔滤波器组；
                            % *m为通过一组美尔尺度的三角形滤波器组，得到经滤波器组加权后的能量值；
c=dct(log(mel)); %  将滤波器组的输出取对数，然后做DCT变换；得到mel倒谱系数；
c(1,:)=[];  %去除c的第一行；

% 过程总结：输入语音-预加重-分帧-加窗-FFT-经MEL滤波器组频响加权-计算加权后的能量值-将输出取对数，做DCT变换-得到mel倒谱系数；


