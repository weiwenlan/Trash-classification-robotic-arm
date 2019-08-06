function result=test(testdir, n, code, dkmax ,dkmin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function: test() 测试
% input :   testdir : 测试声音文件名
%           n       : testdir中测试文件数中第N个
%           code    : 所有说话人已训练好的码书
% output:   测试结果
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 注意:
%       testdir中声音文件名的格式如下: 
%               1.wav, 2.wav, ..., n.wav

    % 读取每个说话人的声音文件read test sound file of each speaker
    global passcode
    file = sprintf('%s%d.wav', testdir, n);   
    cut(file);
    
    [s, fs] = audioread(file);      
        
    v = mfcc(s,fs);            % 计算MFCC
   
    distmin = inf;              %无穷
    k1 = 0;
   
  for i = 1:length(code)      % code的最大长度，对于每个训练码书，计算失真each trained codebook, compute distortion（畸变，失真）
        d = disteu(v, code{i}); %码书 
                dist = sum(min(d,[],2)) / size(d,1) %size(d,1): 列的长度即行数
          % min(A,[],dim),dim取1或2，取1时，与min(A)完全相同，取2时，该函数返回一个列向量，其第i个元素是A矩阵的第i行上的最小值     
        if dist < distmin
            distmin = dist;
           k1 = i;
        end      
  end
  
  if distmin < 3.8
%       result = ['Correct! ', num2str(distmin)];
      passcode=1;      
      result = 'Correct! ';
  elseif distmin > 4
%       result = ['Wrong Code! ' , num2str(distmin)];
      result = 'Wrong Code! ';
      passcode=0;
  else result ='Again ' ;
      passcode=2;
  end
%   result = sprintf('与第 %d 个说话人匹配', k1);
%     disp(msg);

