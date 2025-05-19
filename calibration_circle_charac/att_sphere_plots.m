% Function to create attitude sphere plots for photodiode paper

clear all
clc
close all

addpath('photodiode_optimization_code\')    % for freezeColors()
%% create points from even az/el:

% increments for az and el
az_inc = 2;
el_inc = 2;

numPts = floor(360/az_inc)*floor(180/el_inc);

az = zeros(numPts,1);
el = zeros(numPts,1);
ctr = 1;
for az_h = -(180-az_inc):az_inc:180
    for el_h = -(90-el_inc):el_inc:90
        az(ctr) = az_h;
        el(ctr) = el_h;
        ctr = ctr+1;
    end
end


[x_azel y_azel z_azel] = sph2cart(az.*pi/180,el.*pi/180,ones(size(az)));


%% load points from icosahedron pixelizing

fid = fopen('icos_fortran\vectors_res06.dat');
data = textscan(fid,'%n %n %n %n %n');
fclose(fid);

x_icos = data{3};
y_icos = data{4};
z_icos = data{5};

% convert to az el
[az_icos el_icos R] = cart2sph(x_icos,y_icos,z_icos);

% convert to deg
az_icos = az_icos.*180/pi;
el_icos = el_icos.*180/pi;

%% 2D plots

figure(1)   % even az el
plot(az,el,'.')
grid on 
axis equal
axis([-185 185 -95 95])
set(gca,'Xtick',-180:30:180,'Ytick',-90:30:90)
set(xlabel('\textbf{Azimuth, deg}'),'interpreter','latex','fontsize',12);
set(ylabel('\textbf{Elevation, deg}'),'interpreter','latex','fontsize',12);

figure(2)   % az el from icos
plot(az_icos,el_icos,'.')
grid on 
axis equal
axis([-185 185 -95 95])
set(gca,'Xtick',-180:30:180,'Ytick',-90:30:90)
set(xlabel('\textbf{Azimuth, deg}'),'interpreter','latex','fontsize',12);
set(ylabel('\textbf{Elevation, deg}'),'interpreter','latex','fontsize',12);

% %% 3D plots
% 
% % points for a sphere for the background
% [x_sp y_sp z_sp] = sphere;
% 
% figure(3)   % even az/el
% surf(x_sp,y_sp,z_sp)
% shading flat
% colormap('white')
% %freezeColors    %to hold the colormap and have a different one on top of it
% 
% hold on
% scatter3(x_azel,y_azel,z_azel,'b.')
% hold off
% 
% axis([-1 1 -1 1 -1 1])
% axis square
% 
% set(xlabel('\textbf{x}'),'interpreter','latex','fontsize',12)
% set(ylabel('\textbf{y}'),'interpreter','latex','fontsize',12)
% set(zlabel('\textbf{z}'),'interpreter','latex','fontsize',12)
% 
% 
% figure(4)   % icos gridding
% surf(x_sp,y_sp,z_sp)
% shading flat
% colormap('white')
% %freezeColors    %to hold the colormap and have a different one on top of it
% 
% hold on
% scatter3(x_icos,y_icos,z_icos,'b.')
% hold off
% 
% axis([-1 1 -1 1 -1 1])
% axis square
% 
% set(xlabel('\textbf{x}'),'interpreter','latex','fontsize',12)
% set(ylabel('\textbf{y}'),'interpreter','latex','fontsize',12)
% set(zlabel('\textbf{z}'),'interpreter','latex','fontsize',12)

%% plot an icosahedron with a sphere

% 
% %%%%%%
% % vertices of the icosahedron, from the Teanby paper
% 
% phi = 2*cos(pi/5);
% 
% icos_verts = [0     phi     1;...
%               0     -phi    1;...
%               0     phi     -1;...
%               0     -phi    -1;...
%               1     0       phi;...
%               -1    0       phi;...
%               1     0       -phi;...
%               -1    0       -phi;...
%               phi   1       0;...
%               -phi  1       0;...
%               phi   -1      0;...
%               -phi  -1      0];
% % normalize the lengths
% numVerts = size(icos_verts,1);
% for i = 1:numVerts
%     icos_verts(i,:) = icos_verts(i,:)/norm(icos_verts(i,:));
% end
% 
% %%%%%%%
% % create triangles from the vertices. This is from the GridSphere() code
% 
% % vertices of the 20 triangles fomed from the vertices
% As = [2; 5; 9; 7; 11; 4; 6; 2; 1; 5; 3; 9; 8; 7; 12; 12; 6; 1; 3; 10];
% Bs = [4; 11; 5; 9; 7; 2; 12; 5; 6; 9; 1; 7; 3; 4; 8; 6; 1; 3; 10; 8];
% Cs = [11; 2; 11; 11; 4; 12; 2; 6; 5; 1; 9; 3; 7; 8; 4; 10; 10; 10; 8; 12];
% 
% triangles = cell(20,1);
% %   dim 1: triangle number
% %   dim 2: row number of each triangle. Each row is a vertix
% %   dim 3: column number of each triangle. Cols are x y z vertices
% 
% for i = 1:20
%     triangles{i} = [ icos_verts(As(i),:); ...
%                      icos_verts(Bs(i),:); ...
%                      icos_verts(Cs(i),:); ...
%                      icos_verts(As(i),:)];  % 1st vertex again for plotting
% end
% 
% 
% % plot the icosahedron
% figure(5)
% hold on
% for i = 1:20
%     plot3(triangles{i}(:,1),triangles{i}(:,2),triangles{i}(:,3),'k','linewidth',2)
%     % fill in the area
% %     fill3(triangles{i}(:,1),triangles{i}(:,2),triangles{i}(:,3),ones(size(triangles{1},1),1))
%     fill3(triangles{i}(:,1),triangles{i}(:,2),triangles{i}(:,3),[.6 .6 .6])
% end
% hold off
%     
% axis([-1 1 -1 1 -1 1])
% axis square
% 
% set(xlabel('\textbf{x}'),'interpreter','latex','fontsize',12)
% set(ylabel('\textbf{y}'),'interpreter','latex','fontsize',12)
% set(zlabel('\textbf{z}'),'interpreter','latex','fontsize',12)
% 
% 
% % overlay sphere
% hold on
% plot3(x_sp,y_sp,z_sp,'k')
% plot3(x_sp',y_sp',z_sp','k')
% hold off
% 
% % % % make boundaries tight
% % % ti = get(gca,'TightInset');
% % % set(gca,'Position',[ti(1) ti(2) 1-ti(3)-ti(1) 1-ti(4)-ti(2)]);
% % 
% % % adjust paper size for saveas
% % set(gca,'units','centimeters')
% % pos = get(gca,'Position');
% % ti = get(gca,'TightInset');
% % 
% % % not that tight
% % ti = ti.*10;
% % 
% % set(gcf, 'PaperUnits','centimeters');
% % set(gcf, 'PaperSize', [pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
% % set(gcf, 'PaperPositionMode', 'manual');
% % set(gcf, 'PaperPosition',[0 0 pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);




