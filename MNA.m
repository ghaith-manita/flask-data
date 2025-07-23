function [best_solution, best_fitness, convergence] = MNA(objective_function, dim, lb, ub, max_iter, pop_size)
% Mycorrhizal Network Algorithm (MNA) - A Novel Metaheuristic
% 
% This algorithm simulates the symbiotic relationships and nutrient exchange
% networks between mycorrhizal fungi and plant roots in forest ecosystems.
%
% Key Novel Features:
% 1. Symbiotic partnerships with resource exchange
% 2. Underground network formation and communication
% 3. Seasonal adaptation cycles
% 4. Nutrient gradient following and accumulation
% 5. Root branching and fungal spore dispersal
% 6. Stress signaling through hyphal networks
%
% Inputs:
%   objective_function - Handle to the objective function
%   dim - Problem dimensionality
%   lb - Lower bounds (scalar or vector)
%   ub - Upper bounds (scalar or vector)
%   max_iter - Maximum iterations
%   pop_size - Population size (must be even for plant-fungi pairs)
%
% Outputs:
%   best_solution - Best solution found
%   best_fitness - Best fitness value
%   convergence - Convergence history

% Initialize parameters
if nargin < 6, pop_size = 30; end
if nargin < 5, max_iter = 500; end

% Ensure even population for plant-fungi pairs
if mod(pop_size, 2) ~= 0, pop_size = pop_size + 1; end

% Ensure bounds are vectors
if isscalar(lb), lb = lb * ones(1, dim); end
if isscalar(ub), ub = ub * ones(1, dim); end

% Algorithm-specific parameters
alpha = 0.6;        % Symbiotic cooperation strength
beta = 0.3;         % Network communication range
gamma = 0.4;        % Seasonal adaptation rate
delta = 0.2;        % Stress response intensity
epsilon = 0.1;      % Spore dispersal probability
phi = 0.8;          % Resource sharing efficiency

% Initialize populations
num_pairs = pop_size / 2;
plants = zeros(num_pairs, dim);      % Plant roots
fungi = zeros(num_pairs, dim);       % Mycorrhizal fungi
plant_fitness = zeros(num_pairs, 1);
fungi_fitness = zeros(num_pairs, 1);
plant_nutrients = zeros(num_pairs, dim);  % Accumulated nutrients
fungi_nutrients = zeros(num_pairs, dim);
network_connections = zeros(num_pairs, num_pairs);  % Network adjacency matrix
stress_levels = zeros(num_pairs, 1);
seasonal_phase = 0;  % 0-2π representing seasons

% Initialize symbiotic pairs
for i = 1:num_pairs
    % Initialize plant (more conservative, seeks stability)
    plants(i, :) = lb + (ub - lb) .* rand(1, dim);
    
    % Initialize fungi (more exploratory, seeks nutrients)
    fungi(i, :) = lb + (ub - lb) .* rand(1, dim);
    
    % Evaluate initial fitness
    plant_fitness(i) = objective_function(plants(i, :));
    fungi_fitness(i) = objective_function(fungi(i, :));
    
    % Initialize nutrient levels
    plant_nutrients(i, :) = rand(1, dim) * 0.5;
    fungi_nutrients(i, :) = rand(1, dim) * 0.5;
end

% Find initial best
all_fitness = [plant_fitness; fungi_fitness];
all_solutions = [plants; fungi];
[global_best_fitness, best_idx] = min(all_fitness);
global_best = all_solutions(best_idx, :);

% Initialize convergence tracking
convergence = zeros(max_iter, 1);

% Main optimization loop
for iter = 1:max_iter
    
    % Update seasonal phase
    seasonal_phase = 2 * pi * iter / max_iter;
    season_factor = 0.5 * (1 + sin(seasonal_phase));
    
    % Build mycorrhizal network based on proximity and compatibility
    network_connections = build_network(plants, fungi, beta);
    
    % Calculate nutrient gradients in the search space
    nutrient_map = calculate_nutrient_gradients(plants, fungi, plant_fitness, fungi_fitness, lb, ub);
    
    for i = 1:num_pairs
        
        % Calculate stress level based on fitness stagnation
        if iter > 1
            prev_plant_fitness = convergence(iter-1);
            stress_levels(i) = max(0, min(1, (plant_fitness(i) - prev_plant_fitness) / abs(prev_plant_fitness + eps)));
        end
        
        % PLANT BEHAVIOR: Root growth and nutrient absorption
        old_plant = plants(i, :);
        
        % Root branching towards nutrient-rich areas
        for j = 1:dim
            gradient = nutrient_map(j);
            
            % Seasonal root growth adaptation
            growth_rate = alpha * season_factor * (1 - stress_levels(i));
            
            % Move towards nutrient gradient
            if gradient > 0
                direction = 1;
            else
                direction = -1;
            end
            
            root_extension = growth_rate * direction * abs(gradient) * (ub(j) - lb(j)) * 0.1;
            plants(i, j) = plants(i, j) + root_extension;
        end
        
        % FUNGI BEHAVIOR: Hyphal exploration and spore dispersal
        old_fungi = fungi(i, :);
        
        % Hyphal network exploration
        for j = 1:dim
            % More aggressive exploration than plants
            exploration_rate = (1 - alpha) * (1 + season_factor) * (1 + stress_levels(i));
            
            % Random exploration with bias towards unexplored regions
            exploration_direction = randn() * exploration_rate * (ub(j) - lb(j)) * 0.15;
            fungi(i, j) = fungi(i, j) + exploration_direction;
        end
        
        % Spore dispersal during stress (novel mechanism)
        if stress_levels(i) > 0.7 && rand() < epsilon
            % Long-distance dispersal
            dispersal_idx = randi(dim);
            fungi(i, dispersal_idx) = lb(dispersal_idx) + (ub(dispersal_idx) - lb(dispersal_idx)) * rand();
        end
        
        % Boundary handling with reflection (like growth hitting obstacles)
        plants(i, :) = reflect_boundaries(plants(i, :), lb, ub);
        fungi(i, :) = reflect_boundaries(fungi(i, :), lb, ub);
        
        % SYMBIOTIC RESOURCE EXCHANGE (novel mechanism)
        % Plants provide carbon, fungi provide nutrients and exploration
        plant_fitness(i) = objective_function(plants(i, :));
        fungi_fitness(i) = objective_function(fungi(i, :));
        
        % Mutual benefit calculation
        if fungi_fitness(i) < plant_fitness(i)
            % Fungi found better solution, share with plant
            exchange_rate = phi * (plant_fitness(i) - fungi_fitness(i)) / (plant_fitness(i) + eps);
            for j = 1:dim
                plants(i, j) = plants(i, j) + exchange_rate * (fungi(i, j) - plants(i, j));
            end
        else
            % Plant is better, provide stability to fungi
            stability_factor = phi * 0.5;
            for j = 1:dim
                fungi(i, j) = fungi(i, j) + stability_factor * (plants(i, j) - fungi(i, j));
            end
        end
        
        % NETWORK COMMUNICATION (novel mechanism)
        % Exchange information through hyphal networks
        connected_pairs = find(network_connections(i, :) > 0);
        if ~isempty(connected_pairs)
            for k = connected_pairs
                if k ~= i
                    % Information exchange strength based on connection quality
                    comm_strength = network_connections(i, k) * delta;
                    
                    % Share successful strategies
                    if fungi_fitness(k) < fungi_fitness(i)
                        % Learn from better connected fungi
                        for j = 1:dim
                            fungi(i, j) = fungi(i, j) + comm_strength * (fungi(k, j) - fungi(i, j));
                        end
                    end
                    
                    if plant_fitness(k) < plant_fitness(i)
                        % Learn from better connected plants
                        for j = 1:dim
                            plants(i, j) = plants(i, j) + comm_strength * (plants(k, j) - plants(i, j));
                        end
                    end
                end
            end
        end
        
        % Re-evaluate after all updates
        plants(i, :) = reflect_boundaries(plants(i, :), lb, ub);
        fungi(i, :) = reflect_boundaries(fungi(i, :), lb, ub);
        
        plant_fitness(i) = objective_function(plants(i, :));
        fungi_fitness(i) = objective_function(fungi(i, :));
        
        % Update global best
        if plant_fitness(i) < global_best_fitness
            global_best = plants(i, :);
            global_best_fitness = plant_fitness(i);
        end
        if fungi_fitness(i) < global_best_fitness
            global_best = fungi(i, :);
            global_best_fitness = fungi_fitness(i);
        end
    end
    
    % SEASONAL ADAPTATION (novel mechanism)
    if mod(iter, 50) == 0
        % Simulate seasonal changes affecting growth patterns
        seasonal_mutation_rate = gamma * abs(sin(seasonal_phase));
        
        for i = 1:num_pairs
            if rand() < seasonal_mutation_rate
                % Adapt to seasonal conditions
                adaptation_strength = 0.1 * (ub - lb);
                plants(i, :) = plants(i, :) + adaptation_strength .* (rand(1, dim) - 0.5);
                fungi(i, :) = fungi(i, :) + adaptation_strength .* (rand(1, dim) - 0.5);
                
                plants(i, :) = reflect_boundaries(plants(i, :), lb, ub);
                fungi(i, :) = reflect_boundaries(fungi(i, :), lb, ub);
            end
        end
    end
    
    % Store convergence
    convergence(iter) = global_best_fitness;
    
    % Display progress
    if mod(iter, 50) == 0
        avg_stress = mean(stress_levels);
        network_density = sum(sum(network_connections)) / (num_pairs * (num_pairs - 1));
        fprintf('Iteration %d: Best fitness = %.6e, Avg stress = %.4f, Network density = %.4f\n', ...
                iter, global_best_fitness, avg_stress, network_density);
    end
end

% Return results
best_solution = global_best;
best_fitness = global_best_fitness;

end

function network = build_network(plants, fungi, beta)
% Build mycorrhizal network based on spatial proximity and compatibility
num_pairs = size(plants, 1);
network = zeros(num_pairs, num_pairs);

for i = 1:num_pairs
    for j = i+1:num_pairs
        % Calculate spatial distance between fungal networks
        distance = norm(fungi(i, :) - fungi(j, :));
        plant_distance = norm(plants(i, :) - plants(j, :));
        
        % Connection probability based on proximity and compatibility
        max_distance = beta * sqrt(size(plants, 2));  % Scaled by dimensionality
        
        if distance < max_distance
            connection_strength = exp(-distance / max_distance) * exp(-plant_distance / max_distance);
            
            % Stochastic connection formation
            if rand() < connection_strength
                network(i, j) = connection_strength;
                network(j, i) = connection_strength;  % Symmetric connections
            end
        end
    end
end
end

function gradients = calculate_nutrient_gradients(plants, fungi, plant_fitness, fungi_fitness, lb, ub)
% Calculate nutrient gradients in the search space
dim = length(lb);
gradients = zeros(1, dim);

% Calculate fitness-based gradients
all_positions = [plants; fungi];
all_fitness = [plant_fitness; fungi_fitness];

for j = 1:dim
    % Sort by dimension value
    [sorted_vals, sort_idx] = sort(all_positions(:, j));
    sorted_fitness = all_fitness(sort_idx);
    
    % Calculate gradient (simplified finite difference)
    if length(sorted_vals) > 1
        gradient = 0;
        for k = 2:length(sorted_vals)
            dx = sorted_vals(k) - sorted_vals(k-1) + eps;
            dy = sorted_fitness(k) - sorted_fitness(k-1);
            gradient = gradient + dy / dx;
        end
        gradients(j) = gradient / (length(sorted_vals) - 1);
    end
end
end

function bounded_pos = reflect_boundaries(position, lb, ub)
% Boundary handling with reflection (like biological growth constraints)
bounded_pos = position;

for j = 1:length(position)
    if position(j) < lb(j)
        bounded_pos(j) = lb(j) + abs(position(j) - lb(j));
        bounded_pos(j) = min(bounded_pos(j), ub(j));
    elseif position(j) > ub(j)
        bounded_pos(j) = ub(j) - abs(position(j) - ub(j));
        bounded_pos(j) = max(bounded_pos(j), lb(j));
    end
end
end