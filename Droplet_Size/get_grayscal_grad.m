% for drop.tif
% focused_img = [50,46,114,44,18, 27, 58];
% unfocused = [30, 119, 41 ];

% for drop2.tif
% focused = [66]
% unfocused = []

%couldnt find any drop in next image = [114, 27, ]
myFolder = 'Droplet_images/';
files = dir(fullfile(myFolder, '*.tif'));
bg = imread(fullfile(myFolder, 'bg.tif'));

a = imread(fullfile(myFolder, 'drop3.tif'));
img = bg - a;
img_bn = imbinarize(img);
s = regionprops(img_bn, 'Centroid', 'BoundingBox','EquivDiameter');
n = 161;
og_img = a;

% a2 = imread(fullfile(myFolder, 'C001H001S0001000004.tif'));
% img2 = bg - a2;
% img_bn_2 = imbinarize(img2);
% s1 = regionprops(img_bn_2, 'Centroid', 'BoundingBox','EquivDiameter');
% bbox_2 = cat(1, s1.BoundingBox);
% radii_2 = cat(1, s1.EquivDiameter) / 2;
% cent_2 = cat(1, s1.Centroid);


%GET_GRAYSCAL_GRAD Summary of this function goes here
%   Detailed explanation goes here
bbox = cat(1, s.BoundingBox);
radii = cat(1, s.EquivDiameter) / 2;
cent = cat(1, s.Centroid);
radius = radii(n);
pixel_loc = zeros(2*ceil(radius), 1);
pixel_val = zeros(2*ceil(radius), 1);
temp = num2cell(cent);
[cent_x, cent_y] = temp{n, :};
for i = 1:2*ceil(radius)
    pixel_loc(i) = floor(cent_x - 2*radius + i);
    pixel_val(i) = og_img(floor(cent_y), (pixel_loc(i)));
end
dy = zeros(2*ceil(radius), 1);    % array for storing pixel gradient
for i = 1:2*ceil(radius) - 1
    dy(i) = pixel_val(i+1) - pixel_val(i);
end
figure();
subplot(1, 2, 1 );
title("Gradient Subplot");
plot(pixel_loc,dy,'r');
subplot(1,2,2);
title("Pixel Values Subplot");
plot( pixel_loc, pixel_val, 'g');
filter_bbox = zeros(500, 1);
% for i = 1:size(bbox_2)
%     if ( abs(bbox_2(i, 1) - bbox(n,1)) < 6 ) && (abs(radii(n) - radii_2(i))< 3)
%         disp(i)
%     end
% end




%pixel val difference => -33, -60, , 
%pixel val difference dont take => -27,

%slopes for filtering => -3000, -5400, -5350, -5150, -4150, -2200, -4600,
%-4150, -5050

%don't take => -1650, -1300, -1800, -1400, -1350, -1550
