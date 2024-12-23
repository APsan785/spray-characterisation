% Fourier analysis over mean intensity of image

myFolder = 'Images/';
files = dir(fullfile(myFolder,'*.tif'));
bg = imread(fullfile(myFolder, 'bg.tif'));
intensity_mean = zeros(50, 1);

for j = 1:size(files)
    if files(j).name == "bg.tif" || files(j).name == "jet.tif" || files(j).name == "jet2.tif"
        continue
    end
    img = imread(fullfile(files(j).folder, files(j).name));
    a = bg - img;

    %processing the image
    a_bright_adj = (imadjust(imlocalbrighten(a),[0 0.9],[0 1]));
    
    intensity_mean(j) = mean2(a_bright_adj);
    
end

intensity_dev = intensity_mean - mean(intensity_mean);

frame_rate = 5000;
freq_dom = frame_rate/50 * (1:50);

subplot(1,2,1);
plot(intensity_mean,'b');
freq_fft = fft(intensity_dev);
subplot(1, 2, 2);
plot(freq_dom,abs(freq_fft));
xlabel("Frequency (in Hz)");
ylabel("Power Spectrum");

