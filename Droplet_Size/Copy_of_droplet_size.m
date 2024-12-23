myFolder = 'Droplet_images/';
files = dir(fullfile(myFolder, '*.tif'));
bg = imread(fullfile(myFolder, 'bg.tif'));
% dia_vector = zeros(100*20);
% index = 0;
% for j = 1:size(files)
    a = imread(fullfile(myFolder, 'drop.tif'));
    img = bg - a;
    ed = edge(img, "sobel", 0.1);
    ar = bwareaopen(ed, 10);
    
    s = regionprops(ar, 'Centroid', 'BoundingBox','EquivDiameter');
    cent = cat(1,s.Centroid);
    figure, imshow(ar);
    bbox = cat(1,s.BoundingBox);
    for i = 1:size(s)
            rectangle('Position', bbox( i, :), 'EdgeColor', 'r');
            V = bbox(i,:);
            w = V(3);
            h = V(4);
            area = w*h;
            dia = sqrt(area);
            % index = index+1;
            % dia_vector(index) = dia;
    end
    figure, imshow(ar);
    hold on;
        for i = 1:size(s)
            rectangle('Position', bbox( i, :), 'EdgeColor', 'r');
        end
        hold off;
mean_dia = mean(nonzeros(dia_vector));
std_dev = std(nonzeros(dia_vector));
disp(strcat("Mean diameter is ", num2str(mean_dia*25*(10^-6)), " +- ",num2str(std_dev*25*(10^-6)), " metres"));

% % Invert the image to form black curves on a white background
% binaryImage = ~binaryImage;
% % Get rid of huge background that touches the border
% binaryImage = imclearborder(binaryImage);
% % Count the objects remaining
% [~, numberOfClosedRegions] = bwlabel(binaryImage);