clear;
% 读取图像
img = imread('coin.jpg'); % 替换为你的图像路径
if size(img, 3) == 3
    img = rgb2gray(img); % 转换为灰度图像
end
img = double(img);

% 计算图像梯度（外部能量）
[grad_x, grad_y] = gradient(img);
grad_magnitude = sqrt(grad_x.^2 + grad_y.^2);
E_ext = -grad_magnitude.^2; % 使用梯度平方的负值作为外部能量

% 让用户选择初始矩形区域
figure;
imshow(uint8(img), []);
title('请拖动鼠标选择矩形区域作为初始轮廓');
rect = getrect; % 获取用户选择的矩形 [x, y, width, height]

% 保存初始矩形区域的坐标用于后续显示
rect_x = rect(1);
rect_y = rect(2);
rect_w = rect(3);
rect_h = rect(4);

% 从矩形生成初始Snake曲线
num_points = 20; % Snake的点数

% 创建沿着矩形的点
points_per_side = round(num_points / 4);
% 上边
x_top = linspace(rect_x, rect_x + rect_w, points_per_side);
y_top = rect_y * ones(1, points_per_side);
% 右边
x_right = (rect_x + rect_w) * ones(1, points_per_side);
y_right = linspace(rect_y, rect_y + rect_h, points_per_side);
% 下边
x_bottom = linspace(rect_x + rect_w, rect_x, points_per_side);
y_bottom = (rect_y + rect_h) * ones(1, points_per_side);
% 左边
x_left = rect_x * ones(1, points_per_side);
y_left = linspace(rect_y + rect_h, rect_y, points_per_side);

% 组合所有点，并确保总数为num_points
x = [x_top(1:end-1), x_right(1:end-1), x_bottom(1:end-1), x_left(1:end-1)];
y = [y_top(1:end-1), y_right(1:end-1), y_bottom(1:end-1), y_left(1:end-1)];

% 确保点的数量为num_points
if length(x) > num_points
    % 如果点太多，进行下采样
    indices = round(linspace(1, length(x), num_points));
    x = x(indices);
    y = y(indices);
elseif length(x) < num_points
    % 如果点太少，插值添加更多点
    t = 1:length(x);
    t_new = linspace(1, length(x), num_points);
    x = interp1(t, x, t_new);
    y = interp1(t, y, t_new);
end

% 参数设置
alpha = 0.01; % 弹性参数
beta = 1; % 刚性参数
gamma= 1;% 伪时间步长
max_iterations = 100; % 最大迭代次数

% 构造差分矩阵，用于计算导数
A = diag(2*ones(1,num_points)) - diag(ones(1,num_points-1),1) - diag(ones(1,num_points-1),-1);
A(1,end) = -1; % 确保闭合
A(end,1) = -1;

B = diag(6*ones(1,num_points)) - diag(4*ones(1,num_points-1),1) - diag(4*ones(1,num_points-1),-1) ...
    + diag(ones(1,num_points-2),2) + diag(ones(1,num_points-2),-2);
B(1,end) = -4; B(1,end-1) = 1; % 确保闭合
B(end,1) = -4; B(end,2) = 1;
B(2,end) = 1; B(end-1,1) = 1;

% 构造矩阵，包含alpha和beta
P = alpha * A - beta * B;
P_inv = inv(eye(num_points) - gamma* P); % 预计算矩阵的逆

% 显示初始选择的矩形区域
figure;
imshow(uint8(img), []); hold on;
rectangle('Position', [rect_x, rect_y, rect_w, rect_h], 'EdgeColor', 'g', 'LineWidth', 2);
title('用户选择的矩形区域');
hold off;
pause(1);

% 显示初始Snake轮廓
figure;
imshow(uint8(img), []); hold on;
plot([x, x(1)], [y, y(1)], 'r-', 'LineWidth', 2);
title('初始Snake轮廓');
pause(1);

% 创建一个新的图像用于迭代过程可视化
figure('Position', [100, 100, 800, 600]);
h_img = subplot(1, 2, 1);
h_energy = subplot(1, 2, 2);

% 用于存储每次迭代的能量值
energy_values = zeros(1, max_iterations);
% 存储x和y的历史，用于显示中间结果
x_history = cell(1, max_iterations);
y_history = cell(1, max_iterations);

% 迭代求解Snake曲线
for iter = 1:max_iterations
    % 获取当前Snake点的位置（插值计算外部能量梯度）
    x_int = round(x);
    y_int = round(y);
    x_int = max(1, min(size(img, 2), x_int)); % 防止越界
    y_int = max(1, min(size(img, 1), y_int)); % 防止越界

    % 计算外部能量的梯度
    fx = interp2(grad_x, x_int, y_int, 'linear', 0); % x方向梯度
    fy = interp2(grad_y, x_int, y_int, 'linear', 0); % y方向梯度

    % 更新Snake点的位置
    F_ext_x = -fx(:); % 外部力（梯度负值）
    F_ext_y = -fy(:);

    x_new = P_inv * (x(:) + gamma * F_ext_x); % 更新x坐标
    y_new = P_inv * (y(:) + gamma * F_ext_y); % 更新y坐标
    
    % 更新Snake曲线
    x = x_new';
    y = y_new';

    % 存储当前迭代的曲线
    x_history{iter} = x;
    y_history{iter} = y;
    
    % 计算当前迭代的能量值
    energy_values(iter) = sum(E_ext(sub2ind(size(E_ext), round(y), round(x))));

    % 可视化Snake曲线的演化
    if mod(iter, 10) == 0 || iter == max_iterations
        % 显示当前Snake曲线
        subplot(h_img);
        imshow(uint8(img), []); hold on;
        plot([x, x(1)], [y, y(1)], 'r-', 'LineWidth', 2); % 绘制Snake曲线
        % 显示初始矩形（用绿色虚线）
        rectangle('Position', [rect_x, rect_y, rect_w, rect_h], 'EdgeColor', 'g', 'LineStyle', '--');
        title(['迭代次数: ', num2str(iter)]);
        hold off;
        
        % 更新能量曲线
        subplot(h_energy);
        plot(1:iter, energy_values(1:iter));
        xlabel('迭代次数');
        ylabel('能量值');
        title('能量随迭代次数的变化');
        
        drawnow;
    end
end

% 绘制特定迭代步骤的结果（初始、中间和最终）
figure('Position', [100, 100, 900, 300]);

% 初始轮廓
subplot(1, 3, 1);
imshow(uint8(img), []); hold on;
rectangle('Position', [rect_x, rect_y, rect_w, rect_h], 'EdgeColor', 'g', 'LineWidth', 2);
plot([x_history{1}, x_history{1}(1)], [y_history{1}, y_history{1}(1)], 'r-', 'LineWidth', 2);
title('初始轮廓');
hold off;

% 中间轮廓 (取中间的迭代)
mid_iter = round(max_iterations / 2);
subplot(1, 3, 2);
imshow(uint8(img), []); hold on;
rectangle('Position', [rect_x, rect_y, rect_w, rect_h], 'EdgeColor', 'g', 'LineStyle', '--');
plot([x_history{mid_iter}, x_history{mid_iter}(1)], [y_history{mid_iter}, y_history{mid_iter}(1)], 'r-', 'LineWidth', 2);
title(['中间轮廓 (迭代 ', num2str(mid_iter), ')']);
hold off;

% 最终轮廓
subplot(1, 3, 3);
imshow(uint8(img), []); hold on;
rectangle('Position', [rect_x, rect_y, rect_w, rect_h], 'EdgeColor', 'g', 'LineStyle', '--');
plot([x, x(1)], [y, y(1)], 'r-', 'LineWidth', 2);
title(['最终轮廓 (迭代 ', num2str(max_iterations), ')']);
hold off;

% 绘制最终能量变化曲线
figure;
plot(1:max_iterations, energy_values);
xlabel('迭代次数');
ylabel('能量值');
title('能量随迭代次数的变化');