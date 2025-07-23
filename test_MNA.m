% Test script for Mycorrhizal Network Algorithm (MNA)
% This script demonstrates the novel metaheuristic on various optimization problems

clear; clc; close all;

%% Test Function Definitions
% Sphere function (unimodal)
sphere = @(x) sum(x.^2);

% Rastrigin function (multimodal)
rastrigin = @(x) 10*length(x) + sum(x.^2 - 10*cos(2*pi*x));

% Rosenbrock function (multimodal, narrow valley)
rosenbrock = @(x) sum(100*(x(2:end) - x(1:end-1).^2).^2 + (1 - x(1:end-1)).^2);

% Ackley function (multimodal)
ackley = @(x) -20*exp(-0.2*sqrt(mean(x.^2))) - exp(mean(cos(2*pi*x))) + 20 + exp(1);

%% Test Parameters
dim = 10;           % Problem dimension
max_iter = 300;     % Maximum iterations
pop_size = 20;      % Population size (will be made even automatically)

%% Test 1: Sphere Function
fprintf('=== Testing MNA on Sphere Function ===\n');
lb_sphere = -5.12 * ones(1, dim);
ub_sphere = 5.12 * ones(1, dim);

tic;
[best_sol_sphere, best_fit_sphere, conv_sphere] = MNA(sphere, dim, lb_sphere, ub_sphere, max_iter, pop_size);
time_sphere = toc;

fprintf('Best solution found: [%.4f, %.4f, ...]\n', best_sol_sphere(1), best_sol_sphere(2));
fprintf('Best fitness: %.6e\n', best_fit_sphere);
fprintf('Computation time: %.2f seconds\n\n', time_sphere);

%% Test 2: Rastrigin Function
fprintf('=== Testing MNA on Rastrigin Function ===\n');
lb_rastrigin = -5.12 * ones(1, dim);
ub_rastrigin = 5.12 * ones(1, dim);

tic;
[best_sol_rastrigin, best_fit_rastrigin, conv_rastrigin] = MNA(rastrigin, dim, lb_rastrigin, ub_rastrigin, max_iter, pop_size);
time_rastrigin = toc;

fprintf('Best solution found: [%.4f, %.4f, ...]\n', best_sol_rastrigin(1), best_sol_rastrigin(2));
fprintf('Best fitness: %.6e\n', best_fit_rastrigin);
fprintf('Computation time: %.2f seconds\n\n', time_rastrigin);

%% Test 3: Rosenbrock Function
fprintf('=== Testing MNA on Rosenbrock Function ===\n');
lb_rosenbrock = -2.048 * ones(1, dim);
ub_rosenbrock = 2.048 * ones(1, dim);

tic;
[best_sol_rosenbrock, best_fit_rosenbrock, conv_rosenbrock] = MNA(rosenbrock, dim, lb_rosenbrock, ub_rosenbrock, max_iter, pop_size);
time_rosenbrock = toc;

fprintf('Best solution found: [%.4f, %.4f, ...]\n', best_sol_rosenbrock(1), best_sol_rosenbrock(2));
fprintf('Best fitness: %.6e\n', best_fit_rosenbrock);
fprintf('Computation time: %.2f seconds\n\n', time_rosenbrock);

%% Test 4: Ackley Function
fprintf('=== Testing MNA on Ackley Function ===\n');
lb_ackley = -32.768 * ones(1, dim);
ub_ackley = 32.768 * ones(1, dim);

tic;
[best_sol_ackley, best_fit_ackley, conv_ackley] = MNA(ackley, dim, lb_ackley, ub_ackley, max_iter, pop_size);
time_ackley = toc;

fprintf('Best solution found: [%.4f, %.4f, ...]\n', best_sol_ackley(1), best_sol_ackley(2));
fprintf('Best fitness: %.6e\n', best_fit_ackley);
fprintf('Computation time: %.2f seconds\n\n', time_ackley);

%% Visualization of Convergence
figure('Position', [100, 100, 1200, 800]);

% Plot convergence curves
subplot(2, 2, 1);
semilogy(conv_sphere, 'LineWidth', 2, 'Color', [0, 0.7, 0]);
title('Sphere Function Convergence', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Iteration');
ylabel('Best Fitness (log scale)');
grid on;

subplot(2, 2, 2);
semilogy(conv_rastrigin, 'LineWidth', 2, 'Color', [0.8, 0, 0]);
title('Rastrigin Function Convergence', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Iteration');
ylabel('Best Fitness (log scale)');
grid on;

subplot(2, 2, 3);
semilogy(conv_rosenbrock, 'LineWidth', 2, 'Color', [0, 0, 0.8]);
title('Rosenbrock Function Convergence', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Iteration');
ylabel('Best Fitness (log scale)');
grid on;

subplot(2, 2, 4);
semilogy(conv_ackley, 'LineWidth', 2, 'Color', [0.6, 0.4, 0]);
title('Ackley Function Convergence', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Iteration');
ylabel('Best Fitness (log scale)');
grid on;

sgtitle('Mycorrhizal Network Algorithm (MNA) - Convergence Analysis', 'FontSize', 14, 'FontWeight', 'bold');

%% Performance Summary
fprintf('=== PERFORMANCE SUMMARY ===\n');
fprintf('Function       | Best Fitness  | Time (s) | Convergence\n');
fprintf('---------------|---------------|----------|------------\n');
fprintf('Sphere         | %.2e      | %.2f     | %s\n', best_fit_sphere, time_sphere, ...
    evaluate_convergence(conv_sphere));
fprintf('Rastrigin      | %.2e      | %.2f     | %s\n', best_fit_rastrigin, time_rastrigin, ...
    evaluate_convergence(conv_rastrigin));
fprintf('Rosenbrock     | %.2e      | %.2f     | %s\n', best_fit_rosenbrock, time_rosenbrock, ...
    evaluate_convergence(conv_rosenbrock));
fprintf('Ackley         | %.2e      | %.2f     | %s\n', best_fit_ackley, time_ackley, ...
    evaluate_convergence(conv_ackley));

fprintf('\n=== ALGORITHM CHARACTERISTICS ===\n');
fprintf('Novel Features Demonstrated:\n');
fprintf('1. Symbiotic plant-fungi cooperation\n');
fprintf('2. Dynamic network formation and communication\n');
fprintf('3. Seasonal adaptation cycles\n');
fprintf('4. Stress-induced spore dispersal\n');
fprintf('5. Nutrient gradient following\n');
fprintf('6. Multi-level exploration strategies\n');

function status = evaluate_convergence(convergence_curve)
    % Simple convergence evaluation
    final_improvement = abs(convergence_curve(end) - convergence_curve(end-min(50, length(convergence_curve)-1)));
    if final_improvement < 1e-10
        status = 'Converged';
    elseif convergence_curve(end) < 1e-6
        status = 'Good';
    else
        status = 'Fair';
    end
end