function [l] = draw_line()
    l = zeros(200,1);
   l(1) = line([50,100], [50,100], 'Color', 'green');
   l(2) = line([70,120], [70,100], 'Color', 'green');

   pause(1.5);
end