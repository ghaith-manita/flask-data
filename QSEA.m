function [best_solution, best_fitness, convergence] = QSEA(objective_function, dim, lb, ub, max_iter, pop_size)
% Quantum Swarm Evolution Algorithm (QSEA) - A Novel Metaheuristic
% 
% This algorithm combines quantum-inspired particle dynamics with adaptive
% evolutionary strategies and multi-dimensional swarm intelligence.
%
% Key Novel Features:
% 1. Quantum tunneling probability for escaping local optima
% 2. Adaptive quantum gate operations on position vectors
% 3. Multi-level social hierarchy with dynamic leadership
% 4. Entropy-based diversity maintenance
% 5. Adaptive mutation based on quantum uncertainty principle
%
% Inputs:
%   objective_function - Handle to the objective function
%   dim - Problem dimensionality
%   lb - Lower bounds (scalar or vector)
%   ub - Upper bounds (scalar or vector)
%   max_iter - Maximum iterations
%   pop_size - Population size
%
% Outputs:
%   best_solution - Best solution found
%   best_fitness - Best fitness value
%   convergence - Convergence history

% Initialize parameters
if nargin < 6, pop_size = 30; end
if nargin < 5, max_iter = 500; end

% Ensure bounds are vectors
if isscalar(lb), lb = lb * ones(1, dim); end
if isscalar(ub), ub = ub * ones(1, dim); end

% Algorithm-specific parameters
alpha = 0.5;        % Quantum tunneling coefficient
beta = 0.7;         % Social hierarchy weight
gamma = 0.3;        % Quantum gate strength
phi = 0.9;          % Entropy threshold
psi = 0.1;          % Uncertainty principle coefficient

% Initialize population with quantum superposition
population = zeros(pop_size, dim);
velocity = zeros(pop_size, dim);
quantum_phase = zeros(pop_size, dim);
fitness = zeros(pop_size, 1);
personal_best = zeros(pop_size, dim);
personal_best_fitness = inf(pop_size, 1);

% Initialize with quantum-inspired distribution
for i = 1:pop_size
    for j = 1:dim
        % Quantum superposition initialization
        theta = 2 * pi * rand();
        quantum_phase(i, j) = theta;
        population(i, j) = lb(j) + (ub(j) - lb(j)) * (sin(theta)^2);
    end
    
    % Initialize velocity with quantum uncertainty
    velocity(i, :) = (ub - lb) .* (rand(1, dim) - 0.5) * psi;
    
    % Evaluate fitness
    fitness(i) = objective_function(population(i, :));
    personal_best(i, :) = population(i, :);
    personal_best_fitness(i) = fitness(i);
end

% Find global best
[global_best_fitness, best_idx] = min(fitness);
global_best = population(best_idx, :);

% Initialize convergence tracking
convergence = zeros(max_iter, 1);

% Multi-level hierarchy initialization
hierarchy_levels = 3;
level_size = floor(pop_size / hierarchy_levels);

% Main optimization loop
for iter = 1:max_iter
    
    % Adaptive parameters based on iteration
    w = 0.9 - 0.7 * iter / max_iter;  % Inertia weight
    c1 = 2 - 2 * iter / max_iter;     % Cognitive coefficient
    c2 = 2 * iter / max_iter;         % Social coefficient
    
    % Calculate population entropy for diversity measure
    entropy = calculate_entropy(population, lb, ub);
    
    for i = 1:pop_size
        
        % Determine hierarchy level
        level = min(ceil(i / level_size), hierarchy_levels);
        
        % Quantum tunneling probability (novel feature)
        tunneling_prob = alpha * exp(-entropy / phi) * exp(-iter / max_iter);
        
        if rand() < tunneling_prob
            % Quantum tunneling: teleport to new position
            for j = 1:dim
                population(i, j) = lb(j) + (ub(j) - lb(j)) * rand();
                quantum_phase(i, j) = 2 * pi * rand();
            end
        else
            % Standard quantum swarm update with novel modifications
            
            % Multi-level social learning
            if level == 1
                % Elite level: learn from global best
                social_component = global_best;
            elseif level == 2
                % Middle level: learn from level leaders
                level_start = 1;
                level_end = level_size;
                [~, leader_idx] = min(fitness(level_start:level_end));
                social_component = population(level_start + leader_idx - 1, :);
            else
                % Lower level: learn from random better solution
                better_indices = find(fitness < fitness(i));
                if ~isempty(better_indices)
                    rand_idx = better_indices(randi(length(better_indices)));
                    social_component = population(rand_idx, :);
                else
                    social_component = global_best;
                end
            end
            
            % Quantum gate operations on position (novel feature)
            for j = 1:dim
                % Apply quantum rotation gate
                old_phase = quantum_phase(i, j);
                new_phase = old_phase + gamma * (rand() - 0.5);
                quantum_phase(i, j) = new_phase;
                
                % Quantum-inspired velocity update
                r1 = rand(); r2 = rand();
                
                % Novel quantum uncertainty component
                uncertainty = psi * sin(quantum_phase(i, j)) * (ub(j) - lb(j));
                
                velocity(i, j) = w * velocity(i, j) + ...
                                c1 * r1 * (personal_best(i, j) - population(i, j)) + ...
                                c2 * r2 * (social_component(j) - population(i, j)) + ...
                                uncertainty;
                
                % Position update with quantum superposition
                population(i, j) = population(i, j) + velocity(i, j) * cos(quantum_phase(i, j));
                
                % Boundary handling with quantum reflection
                if population(i, j) < lb(j)
                    population(i, j) = lb(j) + abs(population(i, j) - lb(j));
                    velocity(i, j) = -velocity(i, j);
                    quantum_phase(i, j) = pi - quantum_phase(i, j);
                elseif population(i, j) > ub(j)
                    population(i, j) = ub(j) - abs(population(i, j) - ub(j));
                    velocity(i, j) = -velocity(i, j);
                    quantum_phase(i, j) = pi - quantum_phase(i, j);
                end
            end
        end
        
        % Adaptive quantum mutation (novel feature)
        if entropy < phi
            mutation_strength = beta * exp(-iter / max_iter);
            for j = 1:dim
                if rand() < mutation_strength
                    population(i, j) = population(i, j) + ...
                        (ub(j) - lb(j)) * 0.1 * randn() * sin(quantum_phase(i, j));
                    population(i, j) = max(lb(j), min(ub(j), population(i, j)));
                end
            end
        end
        
        % Evaluate fitness
        fitness(i) = objective_function(population(i, :));
        
        % Update personal best
        if fitness(i) < personal_best_fitness(i)
            personal_best(i, :) = population(i, :);
            personal_best_fitness(i) = fitness(i);
        end
        
        % Update global best
        if fitness(i) < global_best_fitness
            global_best = population(i, :);
            global_best_fitness = fitness(i);
        end
    end
    
    % Quantum phase evolution (novel feature)
    for i = 1:pop_size
        for j = 1:dim
            phase_drift = 0.01 * sin(iter * pi / max_iter);
            quantum_phase(i, j) = quantum_phase(i, j) + phase_drift;
        end
    end
    
    % Store convergence
    convergence(iter) = global_best_fitness;
    
    % Display progress
    if mod(iter, 50) == 0
        fprintf('Iteration %d: Best fitness = %.6e, Entropy = %.4f\n', ...
                iter, global_best_fitness, entropy);
    end
end

% Return results
best_solution = global_best;
best_fitness = global_best_fitness;

end

function entropy = calculate_entropy(population, lb, ub)
% Calculate population entropy for diversity measurement
[pop_size, dim] = size(population);
entropy = 0;

for j = 1:dim
    % Normalize dimension to [0, 1]
    normalized = (population(:, j) - lb(j)) / (ub(j) - lb(j));
    
    % Calculate histogram
    num_bins = min(10, pop_size);
    [counts, ~] = hist(normalized, num_bins);
    
    % Calculate entropy
    probabilities = counts / sum(counts);
    probabilities = probabilities(probabilities > 0);
    
    if ~isempty(probabilities)
        entropy = entropy - sum(probabilities .* log2(probabilities));
    end
end

entropy = entropy / dim;  % Average entropy across dimensions
end