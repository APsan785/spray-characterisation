function [x_right, y_bot_max, y_top_max, pixel_values, line_vector, length] = fringe_tracing(img, x_top_left, y_top_left)
    % img = imread('001a.tif');
    line_vector = gobjects(1,200);
    line_index = 1;
    
    impixelinfo();
    hold on;
    x_left = x_top_left;
    
    
    y_bottom = y_top_left;
    y_top = y_top_left;
    
    anchor = x_left;
    counter = 1;
    pixel_top_counter = 0;
    pixel_bottom_counter = 0;
    y_bot_max = 0;
    y_top_max = 1064;
    
    centroids = zeros(300, 2);
    
    while img(y_bottom, anchor+counter) > 25
        y_bottom = y_bottom+1;
    end
    % while img(y_top, anchor-counter) > 25
    %     y_bottom = y_bottom+1;
    % end
    y_bot_left = y_bottom;
    
    y_cent = floor((y_bottom+y_top_left)/2);
    index = 0;
    
    while counter < 30
    
        % Find the row indices where all elements are zero
        zero_rows = all(centroids == 0, 2);
        
        % Find the last row index that doesn't contain all zeros
        last_non_zero_row = find(~zero_rows, 1, 'last');
        
        index = index+1;
        try
            if img(y_cent, anchor + counter) > 25
                anchor = anchor + counter;
                counter = 1;
                % disp(anchor+counter);
                
                while img(y_cent-pixel_top_counter, anchor+counter) > 25
                    pixel_top_counter = pixel_top_counter + 1;
                  
                end
                y_top_max = min(y_top_max,y_cent - pixel_top_counter );
                while img(y_cent+pixel_bottom_counter, anchor+counter) > 25
                    pixel_bottom_counter = pixel_bottom_counter + 1;
                   
                end
                y_bot_max = max(y_bot_max, y_cent + pixel_bottom_counter);

                if index == 1 && ((y_top_left > y_cent - pixel_top_counter) && (y_top_left > y_cent + pixel_bottom_counter) ...
                        || ((y_top_left < y_cent - pixel_top_counter) && (y_top_left < y_cent + pixel_bottom_counter)))
                    length = 0;
                    pixel_values = zeroes(20,3);
                    x_right = 0;
                    y_bot_max = 0;
                    y_top_max = 0;

                    return
                end
                y_cent = y_cent + floor((- pixel_top_counter + pixel_bottom_counter )/2);
                y_top_right = y_cent - (pixel_top_counter + pixel_bottom_counter)/2 ;
                y_bot_right = y_cent + (pixel_top_counter + pixel_bottom_counter)/2 ;
                pixel_top_counter = 0;
                pixel_bottom_counter = 0;
            else
                counter = counter+1;
            end
        catch ME
            % Handle the exception
            if strcmp(ME.identifier, 'MATLAB:badsubscript')
                % disp('Index out of bounds!\n');
                break;
            end
        end
        centroids(index, 2) = y_cent;
        centroids(index, 1) = anchor + counter;
    
        if index ~= 1
            y_cent_mean = mean(centroids(1:last_non_zero_row, 2));
            if abs(y_cent_mean - y_cent) >= 5
                centroids(last_non_zero_row+1, :) = 0;
                break
            end
            line_vector(line_index) = line(centroids(index-1:index,1), centroids(index-1:index,2), 'Color', 'green');
            line_index = line_index + 1;
            % disp(line_vector(1));
            % disp(centroids(index-1:index,1));
        end

    
    end

    centroid_start_x= centroids(1,1);
    centroid_start_y = centroids(1,2);

    length = anchor + counter - centroid_start_x;
    x_right = anchor+counter;
    
    buffer_at_start = 15;
    
    pixel_values = zeros(buffer_at_start,3); 
    
    for i = 1:buffer_at_start
        try
            % Your code that might cause an index out of bounds exception
            pixel_values(i, 1) = centroid_start_x - buffer_at_start + 1 + i;
            pixel_values(i, 2) = centroid_start_y;
            pixel_values(i, 3) = img(centroid_start_y, centroid_start_x - buffer_at_start + 1 + i);
            % Use the value
        catch ME
            % Handle the exception
            if strcmp(ME.identifier, 'MATLAB:badsubscript')
                % fprintf('Index out of bounds!\n');
            end
        end
    end
    
    % Find the row indices where all elements are zero
    zero_rows = all(centroids == 0, 2);
    
    % Find the last row index that doesn't contain all zeros
    last_non_zero_row = find(~zero_rows, 1, 'last');
    
    % Extract the matrix without the trailing zero rows
    centroids = centroids(1:last_non_zero_row, :);
    
    for j = 1:size(centroids,1)
        try
            pixel_values = [pixel_values; [centroids(j,1), centroids(j,2), uint16(img(centroids(j,2), centroids(j,1)))]];
            
        catch ME
            % Handle the exception
            if strcmp(ME.identifier, 'MATLAB:badsubscript')
                % fprintf('Index out of bounds!\n');
            end
        end
    end
end
