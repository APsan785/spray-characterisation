myFolder = 'E:/Raw_images/';
files = dir(fullfile(myFolder,'*.tif'));
bg = imread(fullfile(myFolder, 'bg.tif'));
breaking_pts = zeros(length(files), 1);

ind_start = 1;
ind_end = 1000;
numb_img = ind_end - ind_start;
img_range = strcat(int2str(ind_start), " to ", int2str(ind_end));
for j = ind_start:ind_end
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

breaking_pts = nonzeros(breaking_pts);

%Finding moments of statistics
mean_break_pt = mean(breaking_pts);
std_dev_break_pt = std(breaking_pts);
mean_break_len = mean_break_pt;
std_dev_break_len = std(breaking_pts);
rms_break_len = rms(breaking_pts);


%use autocorrelation function
[acf, lags] = autocorr(breaking_pts, NumLags=ind_end-ind_start);
% disp([acf lags]);

frame_rate = 5000;
time_scale = lags*1000/frame_rate;

%reverse x and y value to get interpolation from y value
vq = interp1(acf, time_scale, 0.25, "linear" );
disp(strcat("\tau_{0} = ", num2str(vq)));

acf_for_area = acf(acf>0.25);
acf_for_area(end+1) = 0.25;

time_scale_for_area = time_scale(time_scale<vq);
time_scale_for_area(end+1) = vq;

%Finding area by trapezoidal integration
tau_c = trapz(time_scale_for_area, acf_for_area);
disp("No of images = ");
disp(img_range);
disp("Tau_c = ")
disp(tau_c);

%Shading the graph
H1=area(time_scale,acf,'FaceColor',[1 1 1]);
hold on;
H=area(time_scale_for_area,acf_for_area);
set(H(1),'FaceColor',[1 0.5 0], 'FaceAlpha', 0.2);


plot(time_scale,acf, 'r:.', vq, 0.25, 'bo');
yline(0, 'g--');
yline(0.25, 'g-')
xlabel("\tau (in ms)","FontSize", 16);
ylabel("R_{L}_{B}", "FontSize", 16);
title(strcat("Auto-Correlation of Breakup length ", img_range), "FontSize", 18);

hold off;

figure()
fft_acf = fft(acf-mean(acf));
freq_dom = frame_rate/numb_img * (0:numb_img/2);
plot(freq_dom, abs(fft_acf(1:numb_img/2+1)));
xlabel("Freq (in Hz)");
ylabel("Power Spectrum");
title(strcat("FFT Of Autocorrelation plot ", img_range));


