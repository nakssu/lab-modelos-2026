
clear; clc; close all;

% 4.1. modelo de estados y simulacion hidraulica

% parametros del sistema
A1 = 2.0;    A2 = 1.0;
Ri1 = 0.5;   Ri2 = 0.25;
Rs1 = 0.4;   Rs2 = 0.2;

% matrices de espacio de estados
% dh1/dt = (1/A1)*u - (1/(A1*Ri1))*h1 + (1/(A1*Ri1))*h2 - (1/(A1*Ri2))*h1 + (1/(A1*Ri2))*h2 - (1/(A1*Rs1))*h1
% dh2/dt = (1/(A2*Ri1))*h1 - (1/(A2*Ri1))*h2 + (1/(A2*Ri2))*h1 - (1/(A2*Ri2))*h2 - (1/(A2*Rs2))*h2

A = [ -(1/Ri1 + 1/Ri2 + 1/Rs1)/A1 ,  (1/Ri1 + 1/Ri2)/A1 ;
       (1/Ri1 + 1/Ri2)/A2         , -(1/Ri1 + 1/Ri2 + 1/Rs2)/A2 ];

B = [1/A1; 
     0];

C = [1, 0;   % Salida 1: h1(t)
     0, 1];  % Salida 2: h2(t)

D = [0; 
     0];

% crear el objeto de espacio de estados
sys_ss = ss(A, B, C, D);
sys_ss.OutputName = {'altura tanque 1 (h1)', 'altura tanque 2 (h2)'};

fprintf('--- matrices del espacio de estados ---\n');
disp('matriz A:'); disp(A);
disp('matriz B:'); disp(B);

%% simulacion temporal

t_sim = 0:0.1:30; % 30 segundos de simulacion

% 1. respuesta al impulso
figure('Name', 'pregunta 2: respuesta al impulso', 'NumberTitle', 'off');
impulse(sys_ss, t_sim);
grid on;
title('respuesta al impulso (llenado repentino por mantenimiento)');

% 2. respuesta al escalon
figure('Name', 'pregunta 2: respuesta al escalon', 'NumberTitle', 'off');
step(sys_ss, t_sim);
grid on;
title('respuesta al escalon (flujo nominal de operacion)');

% 3. respuesta a entrada variable
u_variable = 50 * sin(0.5 * t_sim) + 10; % Asegura u >= 0

[y_var, t_var] = lsim(sys_ss, u_variable, t_sim);

figure('Name', 'pregunta 2: entrada variable', 'NumberTitle', 'off');
subplot(2,1,1);
plot(t_sim, u_variable, 'k', 'LineWidth', 2);
grid on;
title('flujo de entrada variable u(t) = 50\cdot_s_i_n(0.5t) + 10');
ylabel('flujo u(t)');

subplot(2,1,2);
plot(t_var, y_var(:,1), 'b-', 'LineWidth', 2); hold on;
plot(t_var, y_var(:,2), 'r--', 'LineWidth', 2);
grid on;
title('evolucion de las alturas en los tanques');
xlabel('tiempo (segundos)');
ylabel('alturas [m]');
legend('tanque 1 (h1)', 'tanque 2 (h2)');

%% ---------------------------------------------------------
% 4.2. verificacion e integracion
fprintf('\n--- 4.2. verificacion e integracion ---\n');

% transformación de espacio de estados a funcion de transferencia
sys_tf = tf(sys_ss);

disp('funcion de transferencia desde u(t) hacia h1(t):');
disp(sys_tf(1));
disp('funcion de transferencia desde u(t) hacia h2(t):');
disp(sys_tf(2));

% grafo de la comparacion de respuestas al escalon para validacion
[y_ss, ~] = step(sys_ss, t_sim);

% Simulamos las funciones de transferencia de forma independiente para evitar conflictos de dimensiones
[y_tf1, ~] = step(sys_tf(1), t_sim); % Respuesta para h1
[y_tf2, ~] = step(sys_tf(2), t_sim); % Respuesta para h2

figure('Name', 'Pregunta 2: Verificación SS vs TF', 'NumberTitle', 'off');

% Subplot para Tanque 1
subplot(2,1,1);
plot(t_sim, y_ss(:,1), 'b-', 'LineWidth', 2); hold on;
plot(t_sim, y_tf1, 'ko', 'MarkerSize', 4);
grid on;
title('Validación de Modelos para Tanque 1 (h_1)');
ylabel('Altura [m]');
legend('Espacio de Estados (SS)', 'Función de Transferencia (TF)', 'Location', 'SouthEast');

% Subplot para Tanque 2
subplot(2,1,2);
plot(t_sim, y_ss(:,2), 'r-', 'LineWidth', 2); hold on;
plot(t_sim, y_tf2, 'ko', 'MarkerSize', 4);
grid on;
title('Validación de Modelos para Tanque 2 (h_2)');
xlabel('Tiempo (segundos)');
ylabel('Altura [m]');
legend('Espacio de Estados (SS)', 'Función de Transferencia (TF)', 'Location', 'SouthEast');