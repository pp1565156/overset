classdef overset_sub_grid < overset_grid
% class for the overset sub-grid

    properties
        % also see overset_grid.m

        % spatial properties
        grid_velocity_lin;  % linear velocity (m/s) w.r.t. base grid
        grid_velocity_ang;  % angular velocity (rd/s) w.r.t. base grid
        
        % global properties: UPDATE WITH MOVEMENT
        global_loc_of_center;   % location of center in global coordinates
        global_angle;             % angle with vertical
        
    end
    
    methods
        
        function obj = overset_sub_grid(name_, ...
                id_, ...
                nx_, ny_, ...
                dx_, dy_, ...
                sg1_list_voidBoundaryPointList_, ...
                center_init_, ...
                angle_init_) % constructor
            % call base-class constructor
            obj@overset_grid(name_, id_, nx_, ny_, dx_, dy_, sg1_list_voidBoundaryPointList_);
            obj.global_loc_of_center = center_init_;
            obj.global_angle = angle_init_;
        end
        
        function global_coords = get_global_coords(obj) % returns global coordinates of grid points
            global_coords = zeros(obj.ny, obj.nx, 2);
            dist_to_ctr_y = obj.grid_coords(:, :, 1) - obj.grid_center(1, 1);
            dist_to_ctr_x = obj.grid_coords(:, :, 2) - obj.grid_center(1, 2);
            
            global_coords(:, :, 1) = obj.global_loc_of_center(1, 1) + (dist_to_ctr_y(:, :) * cos(-obj.global_angle) - dist_to_ctr_x(:, :) * sin(-obj.global_angle));
            global_coords(:, :, 2) = obj.global_loc_of_center(1, 2) + (dist_to_ctr_x(:, :) * cos(-obj.global_angle) + dist_to_ctr_y(:, :) * sin(-obj.global_angle));
        end
        
        function [poly_x, poly_y] = get_void_polygon(obj, k)
            poly_x = zeros(1, size(obj.void_polygons{k}, 2));
            poly_y = zeros(1, size(obj.void_polygons{k}, 2));
            for l = 1: size(obj.void_polygons{k}, 2)
                dist_to_ctr_y = obj.dy*(obj.void_polygons{k}(1, l) - 1) - obj.grid_center(1, 1);
                dist_to_ctr_x = obj.dx*(obj.void_polygons{k}(2, l) - 1) - obj.grid_center(1, 2);
                poly_x(l) = obj.global_loc_of_center(1, 2) + (dist_to_ctr_x(:, :) * cos(-obj.global_angle) + dist_to_ctr_y(:, :) * sin(-obj.global_angle));
                poly_y(l) = obj.global_loc_of_center(1, 1) + (dist_to_ctr_y(:, :) * cos(-obj.global_angle) - dist_to_ctr_x(:, :) * sin(-obj.global_angle));
            end
        end
        
        function fig = display_grid(obj, fig) % plots the grid on figure img_number
            figure(fig);
            hold on
            y = zeros(1, obj.nx*obj.ny);
            x = zeros(1, obj.nx*obj.ny);

            global_coords = obj.get_global_coords();
            
            k = 1;
            for i = 1: obj.ny
                for j = 1: obj.nx
                    if ~obj.isVoidBoundary(i, j) && obj.flag(i, j) ~= 0
                        y(1, k) = global_coords(i, j, 1);
                        x(1, k) = global_coords(i, j, 2);
                        k = k + 1;
                    end
                end
            end
            
            scatter(x, y, 12);
            hold off;
        end
                
    end
end