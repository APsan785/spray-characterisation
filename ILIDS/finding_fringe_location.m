img = imread('002a.tif');
% img = flipud(img);
[row, col] = size(img);
imshow(img);
branch_taken_care = false;

rects = zeros(1000, 4);
pixel_series = zeros(1000,1000);
pixel_counter = 1;
% rects = [x_left, y_top_left, y_bot_left, x_right]
region_coord = zeros(1000, 4);
index=1;
m = false;

%TODO : checking complete white fringes


for i = 1:row
    for j = 1:col
        m = false;
        if img(i,j) >= 30
            disp(strcat(num2str(i)," and ",num2str(j)));
            for q = 1:index
                if i >= rects(q,2) && i<=rects(q,3) && j>=rects(q,1) && j<=rects(q,4)
                    % disp("going in 1");
                    m = true;
                    break
                end
            end
            if m == true
                continue
            end

            % disp(i);
            % disp(j);
            % disp("going in 2");
            [x_right, y_bot_max, y_top_max, pixel_values, line_vector, length] = fringe_tracing(img, j, i);
            % disp("going in 3");
            if pixel_counter~=1
                prev_start_x = pixel_series(pixel_counter - 1, 1);            
                prev_start_y = pixel_series(pixel_counter - 1, 2);
                curr_start_y = double(pixel_values(1,2));
                curr_start_x = double(pixel_values(1,1));
                prev_end_x = numel(nonzeros(pixel_series(pixel_counter - 1, 3:end))) + prev_start_x; 
                curr_end_x = x_right;
            end
            % if j == x_right - 15 || i == y_bot_left || length < 30
            if length < 30
                branch_taken_care = true;
                for p = line_vector
                    delete(p);
                end
                branch_taken_care = false;
                continue
            elseif pixel_counter ~= 1 && abs(prev_start_y - curr_start_y) < 4
                
                pixel_len_prev = numel(nonzeros(pixel_series(pixel_counter - 1, :)));
                pixel_len_curr = (size(pixel_values,1));
                if pixel_counter == 14
                    disp("HY");
                end
                if pixel_len_prev < pixel_len_curr && curr_start_x < prev_start_x && curr_end_x > prev_start_x
                    branch_taken_care = true;
                    pixel_counter = pixel_counter - 1;
                    pixel_series(pixel_counter, :) = 0;
                    pixel_series(pixel_counter, 1) = pixel_values(1,1);
                    pixel_series(pixel_counter, 2) = pixel_values(1,2);
                    pixel_series(pixel_counter, 3:size(pixel_values,1)+2) = pixel_values(:,3);
                    for p = line_vector_prev
                        delete(p)
                    end
                elseif pixel_len_prev > pixel_len_curr && curr_start_x > prev_start_x && curr_start_x < prev_end_x
                    branch_taken_care = true;
                    pixel_counter = pixel_counter - 1;
                    for p = line_vector
                        delete(p)
                    end
                end
            end
            if branch_taken_care == false
                pixel_series(pixel_counter, 1) = pixel_values(1,1);
                pixel_series(pixel_counter, 2) = pixel_values(1,2);
                pixel_series(pixel_counter, 3:size(pixel_values,1)+2) = pixel_values(:,3);
            end
            branch_taken_care = false;
            rects(index, :) = [j-15,y_top_max,y_bot_max, x_right];
            index = index+1;
            pixel_counter = pixel_counter+1;
            line_vector_prev = line_vector;
        end
    end
end

