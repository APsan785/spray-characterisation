% Fourier Analysis over breakup length

myFolder = 'E:\Raw_images\';
files = dir(fullfile(myFolder,'*.tif'));
bg = imread(fullfile(myFolder, 'bg.tif'));
files_to_sample = floor(length(files)/10);
breaking_pts = zeros(files_to_sample, 1);

for j = 1:files_to_sample
    if files(j).name == "bg.tif" || files(j).name == "jet.tif" || files(j).name == "jet2.tif"
        continue
    end
    img = imread(fullfile(files(j).folder, files(j).name));
    a = bg - img;

    %processing the image
    a_bright_adj = (imadjust(imlocalbrighten(a),[0 0.9],[0 1]));
    a_bright_adj_bw = imbinarize(a_bright_adj, 150/255);
    reduce_spots = bwareaopen(a_bright_adj_bw, 500);
    [bwLabel, num] = bwlabel(reduce_spots, 8);

    %regionprops
    s = regionprops(bwLabel,'Area', 'BoundingBox', 'Centroid');
%    disp(size(s));
    cent = cat(1,s.Centroid);
    % disp(cent);
    bbox = cat(1,s.BoundingBox);

    [val,jet_ind] = min(bbox(:,2));
    break_up_pt = bbox(jet_ind,4);
    breaking_pts(j) = break_up_pt;
    
end

deviation_len = breaking_pts - mean(breaking_pts);

frame_rate = 5000;
freq_dom = frame_rate/files_to_sample * (1:files_to_sample);
freq_fft = fft(deviation_len);
plot(freq_dom,abs(freq_fft));
xlabel("Frequency (in Hz)");
ylabel("Power Spectrum");

