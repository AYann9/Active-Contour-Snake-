% hessian_matrix_eigvals.m
function eigvals = hessian_matrix_eigvals(Hxx, Hxy, Hyy)
    % 计算Hessian矩阵的特征值
    [rows, cols] = size(Hxx);
    eigvals = zeros(rows, cols, 2);
    
    for i = 1:rows
        for j = 1:cols
            H = [Hxx(i, j), Hxy(i, j); Hxy(i, j), Hyy(i, j)];
            e = eig(H);
            e = sort(e);
            eigvals(i, j, :) = e;
        end
    end
end