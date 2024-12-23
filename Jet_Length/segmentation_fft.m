%Segmentation leads to loss in frequency resolution
total_files = 10000;
n = 10;
files_to_sample = total_files / n;
frame_rate = 5000;
fft_avg = zeros(files_to_sample/2,1);
for i = 1:n
    breakup_subset = breaking_pts_1_to_10000(files_to_sample*(i-1)+1 : files_to_sample*i, 1);
    x_axis = frame_rate/files_to_sample * (1:files_to_sample/2);
    y_axis = abs(fft(breakup_subset(1:files_to_sample) - mean(breakup_subset(1:files_to_sample))));
    y_axis = y_axis(1:files_to_sample/2);
    % figure, plot(x_axis,y_axis);
    fft_avg = fft_avg + y_axis;
end
fft_avg = fft_avg./n;
figure, plot(x_axis, fft_avg);

xlabel("Frequency (in Hz)", 'FontSize', 16);
ylabel("Power Spectrum", 'FontSize', 16);
title("Power Spectrum of Jet Breakup Length", 'FontSize', 18);