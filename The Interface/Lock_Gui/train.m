function [code,dkmax,dkmin ]= train(traindir, n)  %己改，n 为几就是训练第几个

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function: train() 训练
% input :   testdir : 测试声音文件名
%           n       : testdir中测试文件数中第N个
% output:   code为已训练好的码书；训练时同时用到了mfcc.m和vqlb.m;
%           dkmax  训练的三个样本之间的最大距离
%           dkmin  训练的三个样本之间的最小距离
% rewriter: yuhansgg（Shi Gaige）
% time:     2017.4.9
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Note:
%       Sound files in traindir is supposed to be: 
%                       s1.wav, s2.wav, ..., sn.wav
% Example:
%       >> code = train('C:\data\train\', 8);

k = 16;                         % number of centroids required

 for i = 1:n                      % train a VQ codebook for each speaker
         
    file=sprintf('%s%d.wav', traindir, i);   %%
    disp(file);
    % 语音存储路径显示
    cut(file);  
    
    [s, fs] = audioread(file);
    
    v = mfcc(s, fs);            % Compute MFCC's
   
    code{i} = vqlbg(v, k);      % Train VQ codebook生成码书；
 end
 
if n ==3       
  d1 = disteu(code{1}, code{2});
  d2 = disteu(code{2}, code{3});
  d3 = disteu(code{1}, code{3});
  
  dk(1) = sum(min(d1,[],2)) / size(d1,1);
  dk(2) = sum(min(d2,[],2)) / size(d2,1);
  dk(3) = sum(min(d2,[],2)) / size(d2,1);
  
  dkmax = max(dk);
  dkmin = min(dk);
  
else
    dkmax=0;
    dkmin=0;   
end
