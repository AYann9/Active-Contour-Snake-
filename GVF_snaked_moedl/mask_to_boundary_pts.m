function boundary_pts = mask_to_boundary_pts(mask, pt_spacing)
    % 简化版本，直接使用边界点并进行均匀采样
    B = bwboundaries(mask);
    if isempty(B)
        error('No boundaries found in mask');
    end
    
    boundary = B{1};
    
    % 计算点之间的累积距离
    dx = diff(boundary(:,2));
    dy = diff(boundary(:,1));
    segment_lengths = sqrt(dx.^2 + dy.^2);
    cumulative_length = [0; cumsum(segment_lengths)];
    total_length = cumulative_length(end);
    
    % 计算需要的点数并创建均匀采样
    num_points = round(total_length / pt_spacing);
    target_distances = linspace(0, total_length, num_points+1);
    target_distances = target_distances(1:end-1); % 移除最后一个点避免重复
    
    % 对每个目标距离进行插值
    x_new = interp1(cumulative_length, boundary(:,2), target_distances, 'linear');
    y_new = interp1(cumulative_length, boundary(:,1), target_distances, 'linear');
    
    boundary_pts = [y_new, x_new];
end