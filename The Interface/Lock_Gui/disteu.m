
function d = disteu(x, y)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function: disteu()计算矩阵列对应向量之间的欧几里德距离
% input :   x，y :每列为一帧数据的两个矩阵
% output:   d: 元素d(i,j)是向量x(:,i)与y(:,j)的欧几里德距离
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 两个向量x，y的欧氏距离为D=sum((x-y).^2).^0.5

[M, N] = size(x); %
[M2, P] = size(y); 

if (M ~= M2)%两个向量的行数必须相等
    error('矩阵维数不匹配')
end

d = zeros(N, P);%欧氏距离的结果为N×P维矩阵

if (N < P)
    copies = zeros(1,P);
    for n = 1:N
        d(n,:) = sum((x(:, n+copies) - y) .^2);
        % N<P,增加x的列数，使其与y列数相同，x(:,n+copies):x的每一列都用第n列替换
        % 相当于x的第n列减去y中每一列再平方，然后各列分别求和
    end
else
    copies = zeros(1,N);
    for p = 1:P
        d(:,p) = sum((x - y(:, p+copies)) .^2)';
    end
end

d = d.^0.5;
