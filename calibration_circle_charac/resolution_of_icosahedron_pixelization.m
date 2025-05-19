% Resolution of icosahedron pixelization. Make a yy plot
%
% John Springmann
% 9/29/12

clear all 
clc
close all

%% calculations 

r = 4:1:25; % resolution
N = 40.*r.*(r-1) + 12;  % number of points
d = sqrt( 4*pi./N .*2/sqrt(3)); % edge-to-edge distance of hexagonal pixels
Ang = asin(d./2).*2.*180/pi;    % angular resolution

%% plot

figure(1)
[ax,h1,h2] = plotyy(r,N,r,Ang);
set(ax,{'ycolor'},{'k';'k'})
set(h1,'LineStyle','-','linewidth',2,'color','k') % bold avg
set(h2,'LineStyle','--','linewidth',2,'color','k')

legend('Number of Pixels','Angular Resolution')

% y axis titles
set(get(ax(2),'YLabel'),'String','\textbf{Angular Resolution, deg}','interpreter','latex','fontsize',12)
set(get(ax(1),'YLabel'),'String','\textbf{Number of Pixels}','interpreter','latex','fontsize',12)
% x axis title
set(get(ax(1),'XLabel'),'String','\textbf{Resolution}','interpreter','latex','fontsize',12)

grid on



% x-axis limit/ticks
set(ax(1),'XLim',[r(1) r(end)],'YTick',r(1):4:r(end))
set(ax(2),'XLim',[r(1) r(end)],'YTick',[])

% y-axis limits/ticks
set(ax(2),'YLim',[1 6],'YTick',1:1:6)
set(ax(1),'YLim',[0 25000],'YTick',0:2500:25000)
