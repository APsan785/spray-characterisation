% Jet breakup length without bg subtraction over a single image

myFolder = 'Images/';
files = dir(fullfile(myFolder,'*.tif'));
breaking_pts = zeros(50, 1);


    a = imread(fullfile(myFolder,'C001H001S0001000040.tif'));
%Uncomment this to see the animation of jet    
   % imshow(a);
    a_bright_adj = (imadjust(imlocalbrighten(a),[0 0.9],[0 1]));
    for i=760:height(a_bright_adj)
        if a_bright_adj(i,:) < 225
            a_bright_adj(i,:) = a_bright_adj(i,:)+30;
        end
    end
    a_bright_adj_bw = imbinarize(a_bright_adj, 70/255);
    a_bright_adj_bw_comp = imcomplement(a_bright_adj_bw);
    reduce_spots = bwareaopen(a_bright_adj_bw_comp, 500);
    
    [bwLabel, num] = bwlabel(reduce_spots, 8);
    s = regionprops(bwLabel,'Area', 'BoundingBox', 'Centroid');
%    disp(size(s));
    cent = cat(1,s.Centroid);
    bbox = cat(1,s.BoundingBox);
%    This is the comment block for displaying rectangles around the jet of 6 images, you can uncomment this to see the result 
    
        figure, imshow(a);
        figure, imshow(bwLabel), impixelinfo();
        hold on;
        plot(cent(:,1), cent(:,2), 'g*');
        for i = 1:size(s)
            rectangle('Position', bbox( i, :), 'EdgeColor', 'r');
        end
        hold off;
 
    disp(cat(1, s.Area));
    disp(bbox);

    
 %   figure, imshow(a) , impixelinfo();


