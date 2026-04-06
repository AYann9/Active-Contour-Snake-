% hessian_matrix.m
function [Hxx, Hxy, Hyy] = hessian_matrix(image, sigma)
    % 计算Hessian矩阵
    [gx, gy] = gradient(imgaussfilt(image, sigma));
    [gxx, gxy] = gradient(gx);
    [~, gyy] = gradient(gy);
    
    Hxx = gxx;
    Hxy = gxy;
    Hyy = gyy;
end