% enhance_ridges.m
function ridges = enhance_ridges(frame)
    % 检测脊线（较大的Hessian特征值）
    if size(frame, 3) > 1
        frame = rgb2gray(frame); % 确保图像是灰度的
    end
    frame = double(frame);
    
    blurred = imgaussfilt(frame, 2);
    [Hxx, Hxy, Hyy] = hessian_matrix(blurred, 4.5);
    eigvals = hessian_matrix_eigvals(Hxx, Hxy, Hyy);
    ridges = abs(eigvals(:, :, 2));
end