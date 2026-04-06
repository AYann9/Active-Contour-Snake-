clear;
warning('off', 'MATLAB:plotting:norenderer');

% 加载数据：原始图像和二值区域感兴趣的图像
% 注意：请确保文件存在于当前路径
im = imread('2.bmp');
mask = imread('2.bmp');
mask = im2bw(mask, graythresh(mask)); % 确保掩膜是二值图像

% 获取掩膜的边界点
boundary_pts = mask_to_boundary_pts(mask, 3);
x = boundary_pts(:, 2);
y = boundary_pts(:, 1);

% 距离脊线中线的距离
ridges = enhance_ridges(im);
thresh = graythresh(ridges) * 255;
prominent_ridges = ridges > 0.8 * thresh;
skeleton = bwskel(prominent_ridges);
edge_dist = bwdist(~skeleton);
edge_dist = imgaussfilt(edge_dist, 2);

% 距离骨架分支点的距离
blurred_skeleton = imfilter(double(skeleton), ones(3)/9, 'symmetric');
corner_im = blurred_skeleton > 4/9;
[corners_labels, ~] = bwlabel(corner_im);
props = regionprops(corners_labels, 'Centroid');
corners = zeros(length(props), 2);
for i = 1:length(props)
    corners(i, :) = props(i).Centroid;
end

% 显示中间图像
figure;
colormap gray;

subplot(2, 2, 1);
imshow(im);
title('original image');
axis off;

subplot(2, 2, 2);
imshow(ridges, []);
title('ridge filter');
axis off;

subplot(2, 2, 3);
imshow(skeleton, []);
hold on;
plot(corners(:, 1), corners(:, 2), 'ro');
title('ridge skeleton w/ branch points');
axis off;

subplot(2, 2, 4);
imshow(edge_dist, colormap(jet))
title('distance transform of skeleton');
axis off;

% 显示拟合过程的动画
figure;
imshow(im);
hold on;
plot(x, y, 'bo');
line_obj = plot(x, y, 'ro');
axis off;

% 调用蛇形拟合函数
alpha = 0.5;
beta = 0.2;
nits = 100;
snake_pts = fit_snake(boundary_pts, edge_dist, alpha, beta, nits, line_obj);

% 显示最终结果
figure;
imshow(im);
hold on;
plot(snake_pts(:,2), snake_pts(:,1), 'g-', 'LineWidth', 2);
title('Final Snake Contour');