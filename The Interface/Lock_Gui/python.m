function [result status] = python(varargin)
% call python
%命令字符串
cmdString='python';
for i = 1:nargin
    thisArg = varargin{i};
    if isempty(thisArg) | ~ischar(thisArg)
        error(['All input arguments must be valid strings.']);
    elseif exist(thisArg)==2
        %这是一个在Matlab路径中的可用的文件
        if isempty(dir(thisArg))
            %得到完整路径
            thisArg = which(thisArg);
        end
    elseif i==1
        % 第一个参数是Python文件 - 必须是一个可用的文件
        error(['Unable to find Python file: ', thisArg]);
    end
    % 如果thisArg中有空格，就用双引号把它括起来
    if any(thisArg == ' ')
          thisArg = ['"', thisArg, '"'];
    end
    % 将thisArg加在cmdString后面
    cmdString = [cmdString, ' ', thisArg];
end
%发送命令
[status,result]=system(cmdString);
end