% seq_read_mmap = [2 2 3 7];
% seq_read_read = [1 5 1 5];
% 
% rand_read_mmap = [2 2 3 7];
% rand_read_read = [1 5 1 5];
% 
% seq_write_mmap = [2 2 3 7];
% seq_write_write = [1 5 1 5];
% 
% rand_write_mmap = [2 2 3 7];
% rand_write_write = [1 5 1 5];
% 
% % seq_read_mmap = [ 
% %     taille tps;
% %     taille tps;
% %     ]
% 
clc; close all;

seq_read_read = [1024 0.000137;
20480 0.000194;
409600 0.001623;
8192000 0.032018;
163840000 0.597520;
];

seq_read_mmap = [1024 0.000100;
20480 0.000239;
409600 0.001674;
8192000 0.030835;
163840000 0.596376;
];

seq_write_write = [1024 0.000168;
20480 0.000183;
409600 0.001489;
8192000 0.029628;
163840000 0.599732;
];

seq_write_mmap = [1024 0.000085;
20480 0.000203;
409600 0.001917;
8192000 0.038649;
163840000 0.741297;
];

rand_read_read = [1024 0.000872;
5120 0.005964;
25600 0.083955;
128000 1.355888;
640000 8.541356;
];

rand_read_mmap = [1024 0.000130;
5120 0.000250;
25600 0.000669;
128000 0.002974;
640000 0.016877;
];

rand_write_write = [1024 0.002187;
5120 0.011053;
25600 0.052615;
128000 0.260498;
640000 1.280407;
];

rand_write_mmap = [1024 0.000113;
5120 0.000247;
25600 0.000676;
128000 0.002947;
640000 0.017302;
];


seq_sizes = seq_read_read(:,1);
rand_sizes = rand_read_read(:,1);

seq_read_times = [seq_read_read(:,2) seq_read_mmap(:,2)];
rand_read_times = [rand_read_read(:,2) rand_read_mmap(:,2)];

seq_write_times = [seq_write_write(:,2) seq_write_mmap(:,2)];
rand_write_times = [rand_write_write(:,2) rand_write_mmap(:,2)];

% file size sequential reading
% file_size = [  2 1; 2 5; 3 1; 7 5];
% bar(file_size)

figure('Name','seq read','NumberTitle', 'off');
colormap('winter');
bar(seq_read_times);
% set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');
set(gca, 'XTickLabel', {'1 Kb' '20 Kb' '400 Kb' '8000 Kb' '160000 Kb'});
legend('read', 'mmap');
title('Sequential read on different file sizes');
ylabel('Time [s]');

xlabel('File sizes');

% file size sequential writing

figure('Name','seq write','NumberTitle', 'off');
colormap('winter');
bar(seq_write_times);
% set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');
set(gca, 'XTickLabel', {'1 Kb' '20 Kb' '400 Kb' '8000 Kb' '160000 Kb'});
legend('write', 'mmap');
title('Sequential write on different file sizes');
ylabel('Time [s]');
xlabel('File sizes');

% file size random reading
figure('Name','rand read','NumberTitle', 'off');
colormap('winter');
bar(rand_read_times);
% set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');
set(gca, 'XTickLabel', {'1 Kb' '5 Kb' '25 Kb' '125 Kb' '625Kb'});
legend('read', 'mmap');
title('Random read on different file sizes');
ylabel('Time [s]');

xlabel('File sizes');

% file size random writing

figure('Name','rand write','NumberTitle', 'off');
colormap('winter');
bar(rand_write_times);
% set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');
set(gca, 'XTickLabel', {'1 Kb' '5 Kb' '25 Kb' '125 Kb' '625Kb'});
legend('write', 'mmap');
title('Random write on different file sizes');
ylabel('Time [s]');
xlabel('File sizes');





% BONUS sur 8 192 000 bytes (s4.txt)

seq_read_read_user = [0.023, 0.026, 0.021, 0.029, 0.014];
seq_read__read_kernel = [0.009, 0.009, 0.012,0.006, 0.018 ];

seq_read_mmap_user = [0.028, 0.029,0.027,0.032,0.026];
seq_read_mmap_kernel = [0.003,0.003,0.005,0.006];

rand_read_read_user = [0.012, 0.024,0.016,0.024,0.012];
rand_read__read_kernel = [1.34, 1.326,1.33,1.322,1.340];

rand_read_mmap_user = [0.001,0.005, 0.004,0.005, 0];
rand_read__mmap_kernel = [0.004,0,0 ,0, 0.008];


% (Group, Stack, StackElement)
% à gauche c'est read et à droite c'est mmap
Y = [0.0108 0.0043 ; 1.3316 0.0024 ];
Y(:,:,2) = [0.0226 0.0284 ; 0.0176 0.0030 ];
%A(:,:,2) = [1 0 4; 3 5 6; 9 8 7]
%Y = round(rand(nb_file,nb_group,nb_stack_el)*10); %[nb_file,nb_group,5]% rand(5,3,2)*10
%Y(1:5,1:nb_stack_el,1) = 0; % setting extra zeros to simulate original groups.
groupLabels = { 'Sequential', 'Random'};     % set labels
plotBarStackGroups(Y, groupLabels); % plot groups of stacked bars
colormap('winter');
ylabel('Time [s]');
title('Reading times for a 8000 Kb file')
xlabel('Reading pattern');
legend('kernel space', 'user space');
set(gca, 'YScale', 'log');

% BONUS OLD
% Y = [kernel_mmap_small, kernel_read_small ;kernel_mmap_medium, kernel_read_medium]
% Y(:,:,2) = [user_mmap_small, user_read_small ;user_mmap_medium, user_read_medium ];
% Y = [1 2 ; 4 5 ; 7 8];
% Y(:,:,2) = [10 11 ; 13 14 ; 16 17 ];
% groupLabels = { '100MB', 2, 3, 4, 5};     % set labels
% plotBarStackGroups(Y, groupLabels); % plot groups of stacked bars
% colormap('winter');
% ylabel('Time [s]');
% xlabel('File size');
% legend('kernel space', 'user space');
% title('user space and kernel space time');

% -- old

% 
% % mmap() kernel vs user space
% figure('Name','mmap file size comparison with time','NumberTitle', 'off');
% y = [[2 3 ; 5 6] ; 4 6; 2 7];
% bar(y,'stacked')
% colormap('winter');
% legend('kernel space','user space');
% title('Time VS file size comparison');
% ylabel('Time [s]');
% set(gca, 'XTickLabel', {'100Kb' '10MB' '100MB'})
% xlabel('File size');
