function showSphere(cax,f,v)
%SHOWSPHERE displays icosphere given faces and vertices.
%   Displays a patch surface on the axes, cax, and sets the view.
%   
%   Properties:
%       - vertex normals == vertex vectors
%       - no backface lighting
%       - colour data matches z value of vertex
%       - material properties match default SURF
%
%   Wil O.C. Ward 19/03/2015
%   University of Nottingham, UK
% set some axes properties if not held
if ~ishold(cax)
    az = -37.5; el = 30;
    view(az,el)
    grid
end
% create patch object on cax
patch('Faces',f,'Vertices',v,...
    'VertexNormals',v,...
    'LineWidth',0.5,'FaceLighting','phong',...
    'BackFaceLighting','unlit',...
    'AmbientStrength',0.3,'DiffuseStrength',0.6,...
    'SpecularExponent',10,'SpecularStrength',0.9,...
    'FaceColor','flat','CData',v(:,3),...
    'Parent',cax,'Tag','Icosphere');
end