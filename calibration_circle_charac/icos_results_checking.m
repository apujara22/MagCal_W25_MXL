% John Springmann
% 8/30/12
%
% Checking the angualr resolution of points on the unit sphere generated
% with the icosahedron method (using the provided fortran code)

clear all
clc
close all

%% load the files
addpath('icosahedron_results\')

res = [12]; % resolutions used to pixelate

vecs = cell(length(res),1);

for i = 1:length(res)
    
    resHere = res(i);
        
    flName = ['vectors_res',num2str(resHere),'.dat'];
    fid = fopen(flName);
    data = textscan(fid,'%n %n %n %n %n');
    fclose(fid);
    
    X = data{3};    % vectors on the sphere
    Y = data{4};
    Z = data{5};
    
    vecs{i} = [X Y Z];
    
    [spX spY spZ] = sphere; % matlab sphere to overlay
    figure(i)
    surf(spX,spY,spZ);
    colormap('white');
    hold on
    plot3(data{3},data{4},data{5},'.')
    axis square
    hold off
    
    % compute the angle betwen pixel k and pixel k+1
    dotProd = X(1:end-1).*X(2:end) + Y(1:end-1).*Y(2:end) + ...
                Z(1:end-1).*Z(2:end);
            
    angs = acos(dotProd);
            
    
    
end
