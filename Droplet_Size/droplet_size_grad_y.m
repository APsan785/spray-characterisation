myFolder = 'Droplet_images/';
files = dir(fullfile(myFolder, '*.tif'));
bg = imread(fullfile(myFolder, 'bg.tif'));
drop_dia = zeros(100*200,1);
index = 1;
for j = 1:size(files)
    a = imread(fullfile(myFolder, files(j).name));
    img = bg - a;
    img_bn = imbinarize(img);
    og_img = a;

    if mod(j, 8)==0
    % figure(), imshow(ar), impixelinfo();
    % figure(), imshow(img),impixelinfo();

    end
    s = regionprops(img_bn, 'Centroid', 'BoundingBox', 'EquivDiameter');
    cent = cat(1,s.Centroid);
    bbox = cat(1,s.BoundingBox);
    radii = cat(1, s.EquivDiameter) / 2;
    for n = 1:size(s)
        radius = radii(n);
        pixel_loc = zeros(2*ceil(radius), 1);
        pixel_val = zeros(2*ceil(radius), 1);
        temp = num2cell(cent);
        [cent_x, cent_y] = temp{n, :};
        for i = 1:2*ceil(radius)
            try
            pixel_loc(i) = floor(cent_y - 2*radius + i);
            pixel_val(i) = og_img((pixel_loc(i)),floor(cent_x));
            catch ME
                % disp(ME.identifier)
                % disp(ME.message)
                % disp(pixel_loc(i));
                if strcmp(ME.message, "Index in position 1 exceeds array bounds. Index must not exceed 248.")
                    pixel_val(i) = og_img(248, floor(cent_x));
                end
                if strcmp(ME.message, "Index in position 1 is invalid. Array indices must be positive integers or logical values.")
                    pixel_val(i) = og_img(1, floor(cent_x));
                end
            end
        end
        dy = gradient(pixel_val,.01);
        if min(dy) < -2000
            drop_dia(index) = radius*2;
            index = index + 1;
        end
    end
end

mean_dia = mean(nonzeros(drop_dia));
rms_dia = rms(nonzeros(drop_dia));
std_dev = std(nonzeros(drop_dia));
disp(strcat("Mean diameter is ", num2str(mean_dia*25*(10^-6)), " +- ",num2str(std_dev*25*(10^-6)), " metres"));

% % Invert the image to form black curves on a white background
% binaryImage = ~binaryImage;
% % Get rid of huge background that touches the border
% binaryImage = imclearborder(binaryImage);
% % Count the objects remaining
% [~, numberOfClosedRegions] = bwlabel(binaryImage);