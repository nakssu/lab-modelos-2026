
clear; clc; close all;

% 3.1. reduccion algebraica del modelo termico

fprintf('--- 3.1. reduccion algebraica ---\n');

% def de las func de transferencia
s = tf('s');
C = 5;
G1 = 2 / (s + 3);
G2 = 1 / (s^2 + 4*s + 4);
H = 1 / (0.5*s + 1);

% directa: G_forward = C * G1 * G2
G_forward = C * G1 * G2;

% lazo cerrado: T(s) = G_forward / (1 + G_forward * H)
T_algebraica = feedback(G_forward, H);

disp('funcion de transferencia equivalente de lazo cerrado T(s):');
minreal(T_algebraica)

%% ---------------------------------------------------------
% 3.2. analisis transitorio de la CPU 
fprintf('\n--- 3.2. analisis transitorio (CPU) ---\n');

% ecuacion diferencial: y''(t) + 7y'(t) + 10y(t) = 4u'(t) + 3u(t)
% 1. lazo abierto
num_abierto = [4, 3];
den_abierto = [1, 7, 10];
H_abierto = tf(num_abierto, den_abierto);

% 2. lazo cerrado
H_cerrado = feedback(H_abierto, 1);

% mostrar func de transferencia
disp('H_abierto(s):');
disp(H_abierto);
disp('H_cerrado(s):');
disp(H_cerrado);

% 3. simulacion entrada escalon unitario
t = 0:0.01:6; % Vector de tiempo para alta resolución
[y_abierto, t_ab] = step(H_abierto, t);
[y_cerrado, t_cl] = step(H_cerrado, t);

figure('Name', 'pregunta 1: respuesta al Escalon', 'NumberTitle', 'off');
plot(t_ab, y_abierto, 'b-', 'LineWidth', 2); hold on;
plot(t_cl, y_cerrado, 'r--', 'LineWidth', 2);
grid on;
title('respuesta transitoria de la temperatura de la CPU');
xlabel('tiempo (segundos)');
ylabel('temperatura y(t) [°C]');
legend('lazo abierto', 'lazo cerrado', 'location', 'southEast');

% 4. cuadro comparativo 
% lazo abierto
info_abierto = stepinfo(H_abierto, 'SettlingTimeThreshold', 0.02);
gain_abierto = dcgain(H_abierto);
poles_abierto = pole(H_abierto);
zeros_abierto = zero(H_abierto);

% lazo cerrado
info_cerrado = stepinfo(H_cerrado, 'SettlingTimeThreshold', 0.02);
gain_cerrado = dcgain(H_cerrado);
poles_cerrado = pole(H_cerrado);
zeros_cerrado = zero(H_cerrado);

% prints varios
fprintf('\n========================================================\n');
fprintf('%-25s | %-12s | %-12s\n', 'metrica', 'lazo abierto', 'lazo cerrado');
fprintf('========================================================\n');
fprintf('%-25s | %-12.4f | %-12.4f\n', 'ganancia estatica', gain_abierto, gain_cerrado);
fprintf('%-25s | %-12.4f | %-12.4f\n', 'tiempo estabilizacion (2%)', info_abierto.SettlingTime, info_cerrado.SettlingTime);
fprintf('%-25s | [%.1f; %.1f]   | [%.2f + %.2fi]\n', 'polos', poles_abierto(1), poles_abierto(2), real(poles_cerrado(1)), imag(poles_cerrado(1)));
fprintf('%-25s | %-12.4f | %-12.4f\n', 'ceros', zeros_abierto, zeros_cerrado);
fprintf('========================================================\n');