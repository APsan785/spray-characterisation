myFolder = 'Droplet_images/';
files = dir(fullfile(myFolder, '*.tif'));
bg = imread(fullfile(myFolder, 'bg.tif'));
index = 1;
% for j = 1:size(files)
for j = 2:3


    %for image 1
    a = imread(fullfile(myFolder, files(j).name));
    img = bg - a;
    img_bn = imbinarize(img);
    s = regionprops(img_bn, 'Centroid', 'BoundingBox', 'EquivDiameter');
    cent = cat(1,s.Centroid);
    bbox = cat(1,s.BoundingBox);
    radii = cat(1, s.EquivDiameter) / 2;
    og_img = a;

    % for image 2
    a2 = imread(fullfile(myFolder, 'C001H001S0001000004.tif'));
    img2 = bg - a2;
    img_bn_2 = imbinarize(img2);
    s1 = regionprops(img_bn_2, 'Centroid', 'BoundingBox','EquivDiameter');
    bbox_2 = cat(1, s1.BoundingBox);
    radii_2 = cat(1, s1.EquivDiameter) / 2;
    cent_2 = cat(1, s1.Centroid);

    displacement = zeros(500 , 2);

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
                % disp(ME.identifier)
                % disp(ME.message)
                % disp(pixel_loc(i));
                if strcmp(ME.message, "Index in position 2 exceeds array bounds. Index must not exceed 1280.")
                    pixel_val(i) = og_img(floor(cent_y), 1280);
                end
                if strcmp(ME.message, "Index in position 2 is invalid. Array indices must be positive integers or logical values.")
                    pixel_val(i) = og_img(floor(cent_y), 1);
                end
            end
        end
        dy = gradient(pixel_val,.01);
        % disp("Yo");
        if min(dy) < -2000
            disp("Hey");
            [y_init, y_final] = find_drop_next_img(n, bbox, bbox_2, radii, radii_2);
            displacement(index,1) = y_init;
            displacement(index,2) = y_final;
            disp(bbox(n,1));
            disp(y_init);
            disp(y_final);
            index = index + 1;
        end
    end
end


function [y_initial, y_final] = find_drop_next_img(n, bbox1, bbox2, radii1, radii2) 
    y_initial = 0;
    y_final = 248;
    for i = 1:size(bbox2)
        if ( abs(bbox2(i, 1) - bbox1(n,1)) < 6 ) && (abs(radii1(n) - radii2(i))< 3)
            y_initial = bbox1(n,2);
            y_final = bbox2(i,2);
        end
    end
end