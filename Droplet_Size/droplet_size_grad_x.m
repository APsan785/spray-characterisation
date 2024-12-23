myFolder = 'Droplet_images/';
files = dir(fullfile(myFolder, '*.tif'));
bg = imread(fullfile(myFolder, 'bg.tif'));
drop_dia = zeros(100*200,1);
index = 1;
for j = 1:size(files)-1
    a = imread(fullfile(myFolder, files(j).name));
    img = bg - a;
    img_bn = imbinarize(img);
    og_img = a;

    s = regionprops(img_bn, 'Centroid', 'BoundingBox', 'EquivDiameter');
    cent = cat(1,s.Centroid);
    bbox = cat(1,s.BoundingBox);
    radii = cat(1, s.EquivDiameter) / 2;
    if j == 55
        figure, imshow(a);
        hold on;
    end
    for n = 1:size(s)
        radius = radii(n);
        pixel_loc = zeros(2*ceil(radius), 1);
        pixel_val = zeros(2*ceil(radius), 1);
        temp = num2cell(cent);
        [cent_x, cent_y] = temp{n, :};
        for i = 1:2*ceil(radius)
            
            try
            pixel_loc(i) = floor(cent_x - 2*radius + i);
            pixel_val(i) = og_img(floor(cent_y), (pixel_loc(i)));
            catch ME
                if strcmp(ME.message, "Index in position 2 exceeds array bounds. Index must not exceed 1280.")
                    pixel_val(i) = og_img(floor(cent_y), 1280);
                end
                if strcmp(ME.message, "Index in position 2 is invalid. Array indices must be positive integers or logical values.")
                    pixel_val(i) = og_img(floor(cent_y), 1);
                end
            end
        end
        dy = zeros(100*200 , 1);    % array for storing pixel gradient
        % loop for finding difference in consecutive pixels
        for i = 1:2*ceil(radius) - 1
            dy(i) = pixel_val(i+1) - pixel_val(i);
        end
        if min(dy) < -33
            drop_dia(index) = radius*2;
            index = index + 1;
            if j == 55
                viscircles([floor((pixel_loc(1) + pixel_loc(end)) / 2) + ceil(radius) ,  floor(cent_y)] , radius+1, 'LineWidth',0.4);
            end
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