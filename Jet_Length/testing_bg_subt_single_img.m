% Code for finding jet length after bg subtraction and applying over a
% single image for testing purpose.

myFolder = 'Images/';
bg = imread(fullfile(myFolder, 'bg.tif'));
% breaking_pts = zeros(50, 1);

   
    img = imread(fullfile(myFolder, 'C001H001S0001000017.tif'));
    a = bg - img;
%Uncomment this to see the animation of jet    
   % imshow(a);
   % disp(files(j).name);
    a_bright_adj = (imadjust(imlocalbrighten(a),[0 0.9],[0 1]));
    a_bright_adj_bw = imbinarize(a_bright_adj, 150/255);
    figure, imshow(a_bright_adj_bw);
    reduce_spots = bwareaopen(a_bright_adj_bw, 500);
    figure, imshow(reduce_spots);
    [bwLabel, num] = bwlabel(reduce_spots, 8);
    figure, imshow(bwLabel);
    s = regionprops(bwLabel,'Area', 'BoundingBox', 'Centroid');
%    disp(size(s));
    cent = cat(1,s.Centroid);
    % disp(cent);
    bbox = cat(1,s.BoundingBox);
%    This is the comment block for displaying rectangles around the jet of 6 images, you can uncomment this to see the result 
    % if mod(j, 8) == 0
    figure, imshow(a), impixelinfo();
        figure, imshow(bwLabel), impixelinfo();
        hold on;
        plot(cent(:,1), cent(:,2), 'g*');
        for i = 1:size(s)
            rectangle('Position', bbox( i, :), 'EdgeColor', 'r');
        end
        hold off;
    % end
    % disp(cat(1, s.Area));
    % disp(bbox);
    [val,jet_ind] = min(bbox(:,2));
    break_up_pt = bbox(jet_ind,4);
    disp(break_up_pt);
    
 %   figure, imshow(a) , impixelinfo();

% mean_break_pt = mean(breaking_pts);
% std_dev_break_pt = std(breaking_pts);
% nozzle_pos = 50;
% mean_break_len = mean_break_pt;
% std_dev_break_len = std(breaking_pts);
% rms_break_len = rms(breaking_pts);
