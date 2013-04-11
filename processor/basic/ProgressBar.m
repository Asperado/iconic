classdef ProgressBar < handle
    %PROGRESSBAR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        start_time = tic;
        n = 0;
    end
    
    methods
        function  self = set_total(self, count)
            self.n = count;
        end
        function self = reset(self) 
            self.start_time = tic;
        end
        function left_time = log(self, current_element_index)
            elapse = toc(self.start_time);
            average_element_run_time = 1.0 * elapse / current_element_index;
            tot_time = average_element_run_time * self.n;
            left_time = tot_time - elapse;
        end
    end
    
end

