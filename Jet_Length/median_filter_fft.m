% The media filter shifts the peak towards right side.

y_axis = abs(fft(breaking_pts_1_to_10000 - mean(breaking_pts_1_to_10000)));
y_axis = y_axis(1:5000);
x_axis = frame_rate/5000 * (1:5000);
y_axis = medfilt1(y_axis, 25);
figure, plot(x_axis, y_axis);