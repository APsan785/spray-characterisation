myFolder = 'Images/';
files = dir(fullfile(myFolder,'*.tif'));
bg = imread(fullfile(myFolder, 'bg.tif'));
files_to_sample = floor(length(files)/10);
breaking_pts = zeros(files_to_sample, 1);
for j = 1:length(files)
    if files(j).name == "bg.tif" || files(j).name == "jet.tif" || files(j).name == "jet2.tif"
        continue
    end
    img = imread(fullfile(files(j).folder, files(j).name));
    a = bg - img;
    a = imcrop(a, [0, 0, 640 , 680]);
%Uncomment this to see the animation of jet    
   % imshow(a);
   % disp(files(j).name);
    a_bright_adj = (imadjust(imlocalbrighten(a),[0 0.9],[0 1]));
    for i=760:height(a_bright_adj)
        if a_bright_adj(i,:) < 225
            a_bright_adj(i,:) = a_bright_adj(i,:)-30;
        end
    end
    a_bright_adj_bw = imbinarize(a_bright_adj, 150/255);
    reduce_spots = bwareaopen(a_bright_adj_bw, 500);
    
    [bwLabel, num] = bwlabel(reduce_spots, 8);
    s = regionprops(bwLabel,'Area', 'BoundingBox', 'Centroid');
%    disp(size(s));
    cent = cat(1,s.Centroid);
    % disp(cent);
    bbox = cat(1,s.BoundingBox);
%    This is the comment block for displaying rectangles around the jet of 6 images, you can uncomment this to see the result 
    if j == 17
        figure, imshow(imcrop(img, [0, 0, 640 , 680])), impixelinfo();
        figure, imshow(a), impixelinfo();
        figure, imshow(a_bright_adj_bw), impixelinfo();
        figure, imshow(bwLabel), impixelinfo();
        hold on;
        plot(cent(:,1), cent(:,2), 'g*');
        for i = 1:size(s)
            rectangle('Position', bbox( i, :), 'EdgeColor', 'r');
        end
        hold off;
    end
    % disp(cat(1, s.Area));
    % disp(bbox);
    [val,jet_ind] = min(bbox(:,2));
    break_up_pt = bbox(jet_ind,4);
    breaking_pts(j) = break_up_pt;

    if j==17
        disp(break_up_pt);
        figure, imshow(bwLabel), impixelinfo();
    end
 %   figure, imshow(a) , impixelinfo();
end

mean_break_pt = mean(breaking_pts);
std_dev_break_pt = std(breaking_pts);
mean_break_len = mean_break_pt;
std_dev_break_len = std(breaking_pts);
rms_break_len = rms(breaking_pts);


disp(strcat("Mean Jet Breakup Length is : ", int2str(mean_break_len), " Pixels"));
disp(strcat("RMS Jet Breakup Length is : ", int2str(rms_break_len), " Pixels"));
disp(strcat("Std Dev Jet Breakup Length is : ", int2str(std_dev_break_len), " Pixels"));
res = 45*10^-6;
disp(strcat("Considering the resolution to be ", num2str(res), "m /pixel for z = 0:"));
disp(strcat("The Mean Jet Breakup Length is : ", num2str(res*mean_break_len), " +- ", num2str(res*std_dev_break_len),  " metres"));
disp(strcat("The RMS Jet Breakup Length is : ", num2str(res*rms_break_len), " +- ", num2str(res*std_dev_break_len),  " metres"));
