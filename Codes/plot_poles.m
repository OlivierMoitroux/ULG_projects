function [] = plot_poles(sys, sysTf)
%PLOT_POLE Summary of this function goes here
%   Detailed explanation goes here

figure('name', 'pzPlot')
pz = pzplot(sysTf)
h = findobj(pz, 'type', 'line');

for i = 1:length(h)
    set(h(i),'markersize',20) %change marker size
    set(h(i), 'linewidth',5)  %change linewidth
end

figure('name', 'pzMap')
pzmap(sys)

% set(h, 'markersize', 50)

% text(real(roots(sysTf.num)) - 0.1, imag(roots(num)) + 0.1, 'Zero')
% text(real(roots(sysTf.den)) - 0.1, imag(roots(den)) + 0.1, 'Pole')
% axis equal

% set(hpz.allaxes.Children(1).Children, 'MarkerSize', 12)
% a = findobj(gca,'type','line')
% for i = 1:length(a)
%     set(a(i),'markersize',12) %change marker size
%     set(a(i), 'linewidth',2)  %change linewidth
% end


% figure('name', 'pzmap')
% pzmap(sys)
end

