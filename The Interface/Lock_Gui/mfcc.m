function c=mfcc(s,fs)   % ��������mfcc�����У�cΪ���������mfccΪ��������s��fsΪ���������

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function: mfcc() ����melƵ�ʵ���ϵ��
% input :   s:��������������ź�   fs������Ƶ��
% output:   MFCC����ϵ��
% rewriter: yuhansgg��Shi Gaige��
% time:     2017.4.9
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Ԥ����
a=0.98;
len=length(s);
for i=2:len
    s1(i)=s(i)-a*s(i-1);%�γ���һ���µ��ź�s1��
end
%figure(2),plot(s1),title('heavyed signal');  s1ΪԤ���غ���źţ�

%���㹦�����ܶ�

n=320;%ÿ��֡�Ĳ�������
m=160;%����֡���֮�����֡��֮֡���ƫ�ƣ�
% [Pxx,w]=pwelch(s1,n,m,256,10000);  ��������Ǽ��������������������Ĺ������ܶȣ�

%��֡
frame=floor((len-n)/m)+1;%�źŷ�֡�ĸ�����floor��������ȡ�ӽ���������A��������
for j=1:frame %һ��Ϊһ֡
    for i=1:n
        z(i,j)=s1((j-1)*m+i);  %��仰����s1���Ǵ�2��ʼ����1
    end
end

%�Ӵ�hamming
h=hamming(n);
for j=1:frame
    for i=1:n
        z2(i,j)=h(i)*z(i,j);%�Ӵ���
    end
end
% z3=z2(:);ͬ��
% figure(4),plot(z3),title('window')   

% fft�任
for j=1:frame
    FFT(:,j)=fft(z2(:,j));%ÿһ֡��Ҫ���и��ϱ任��
end

%melfb ����mel���˲����飻
m=melfb(20,n,fs);     % ����Ӧ���ǵ���melfb����������ȡp=20��ָ�˲���������
n2=1+floor(n/2);
mel=m*abs(FFT(1:n2,:)).^2; %���㾭mel�˲������Ȩ�������ֵ��abs(FFT(1:n2,:)).^2Ϊ�����ף�����ƽ����ͨ�������˲����飻
                            % *mΪͨ��һ�������߶ȵ��������˲����飬�õ����˲������Ȩ�������ֵ��
c=dct(log(mel)); %  ���˲���������ȡ������Ȼ����DCT�任���õ�mel����ϵ����
c(1,:)=[];  %ȥ��c�ĵ�һ�У�

% �����ܽ᣺��������-Ԥ����-��֡-�Ӵ�-FFT-��MEL�˲�����Ƶ���Ȩ-�����Ȩ�������ֵ-�����ȡ��������DCT�任-�õ�mel����ϵ����

