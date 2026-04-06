% fit_snake.m
function snake_pts = fit_snake(pts, edge_dist, alpha, beta, nits, point_plot)
    % 使用活动轮廓模型拟合边界
    %
    % 输入参数:
    %   pts: [N,2]形状的数组，表示轮廓点的初始位置
    %   edge_dist: 2D数组，边缘检测器的距离变换
    %   alpha: 权重参数，控制点的均匀分布，值越高越鼓励均匀分布点，应大于0
    %   beta: 权重参数，控制局部曲率，值越高越鼓励平滑轮廓
    %   nits: 最大迭代次数
    %   point_plot: 图形线对象，用于动画显示优化过程
    
    % 使用高级优化方法
    options = optimoptions('fminunc', 'Display', 'off', 'MaxIterations', nits);
    
    if nargin >= 6 && ~isempty(point_plot)
        % 设置回调函数用于实时显示
        iteration_count = 0;
        options.OutputFcn = @(x, optimValues, state) snake_callback(x, optimValues, state, point_plot, iteration_count);
    end
    
    % 展平点数组以适应优化函数
    flattened_pts = pts(:)';
    
    % 优化
    cost_function = @(flat_pts) double(snake_energy(flat_pts, edge_dist, alpha, beta));
    [optimal_flat_pts, ~] = fminunc(cost_function, flattened_pts, options);
    
    % 重塑为原始形状
    snake_pts = reshape(optimal_flat_pts, [], 2);
end

function [energy] = snake_energy(flattened_pts, edge_dist, alpha, beta)
    % 计算轮廓的能量
    pts = reshape(flattened_pts, [], 2);
    
    % 外部能量（偏向距离图像的低值）
    [rows, cols] = size(edge_dist);
    x = pts(:,2);
    y = pts(:,1);
    
    % 确保点在图像范围内
    x = max(1, min(cols, x));
    y = max(1, min(rows, y));
    
    % 使用双线性插值获取距离值
    dist_vals = interp2(edge_dist, x, y, 'linear');
    edge_energy = sum(dist_vals);
    external_energy = edge_energy;
    
    % 间距能量（偏向等距点）
    prev_pts = circshift(pts, 1);
    next_pts = circshift(pts, -1);
    displacements = pts - prev_pts;
    point_distances = sqrt(displacements(:,1).^2 + displacements(:,2).^2);
    mean_dist = mean(point_distances);
    spacing_energy = sum((point_distances - mean_dist).^2);
    
    % 曲率能量（偏向平滑曲线）
    curvature_1d = prev_pts - 2*pts + next_pts;
    curvature = (curvature_1d(:,1).^2 + curvature_1d(:,2).^2);
    curvature_energy = sum(curvature);
    
    % 总能量
    energy = external_energy + alpha*spacing_energy + beta*curvature_energy;
end

function stop = snake_callback(x, ~, ~, point_plot, iteration_count)
    % 回调函数用于更新图形显示
    persistent iter_count;
    
    if isempty(iter_count)
        iter_count = 0;
    end
    
    iter_count = iter_count + 1;
    
    % 每5次迭代更新一次图形，以加快速度
    if mod(iter_count, 5) == 0
        % 重塑点数组
        pts = reshape(x, [], 2);
        
        % 更新图形
        set(point_plot, 'XData', pts(:,2), 'YData', pts(:,1));
        title(sprintf('%i iterations', iter_count));
        drawnow;
    end
    
    stop = false;
end