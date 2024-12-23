% Find the row indices where all elements are zero
zero_rows = all(pixel_series == 0, 2);

% Find the last row index that doesn't contain all zeros
last_non_zero_row = find(~zero_rows, 1, 'last');

fft_max_freq = zeros(last_non_zero_row, 1);
fringe_dist = zeros(last_non_zero_row, 1);
for n = 1:last_non_zero_row
    % As pixel series col 1 and 2 are the location of fringes
    pixels = nonzeros(pixel_series(n, 3:end));
    % 1124 - 1351 , 410 : f max = 
    % 1023 - 1250, 570 : f max = 8
    % pixels = uint8(pixel_values(:,3));
    % figure, plot(pixels);
    plot(pixels);
    fft_pixel = fft(pixels-mean(pixels));
    fft_pixel = abs(fft_pixel(1:floor(size(fft_pixel,1)/2)));
    
    % figure, plot(fft_pixel);
    plot(fft_pixel);
    hold on;
    max_k_value = 6;
    [maxYValue, indicesAtMaxY] = maxk(abs(fft_pixel), max_k_value);
    l=1;
    while l<=max_k_value 
        if indicesAtMaxY(l) < 5
            l=l+1;
        else
            break;
        end
    end
    if l <= max_k_value
        xValueAtMaxYValue = indicesAtMaxY(l);
    else
        xValueAtMaxYValue = 0;
    end
    
    xnew = linspace(xValueAtMaxYValue-1, xValueAtMaxYValue+1 , 100);
    f = interp1(abs(fft_pixel), xnew, 'spline');
    x_max_freq_interp = xnew(f==max(f));
    
    plot(xnew, f, '-');
    hold off;
    fft_max_freq(n, 1) = x_max_freq_interp;
    fringe_dist(n,1) = numel(pixels) / x_max_freq_interp ;

end

% 
% x_max_freq_formula = find_max_freq(xValueAtMaxYValue, ...
%     abs(fft_pixel(xValueAtMaxYValue+1)), ...
%     abs(fft_pixel(xValueAtMaxYValue-1)));

% interpolation in research paper
function max_freq = find_max_freq(x0, p_more, p_less)
    delk = (log(p_less/p_more) / log(p_less * p_more))/2;
    max_freq = x0 + 0.9169*delk + 0.3326*(delk)^3;
end


