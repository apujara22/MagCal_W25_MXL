function [v,f] = icosahedron()
%ICOSAHEDRON creates unit regular icosahedron
%   Returns 12 vertex and 20 face values.
%
%   Wil O.C. Ward 19/03/2015
%   University of Nottingham, UK
t = (1+sqrt(5)) / 2;
% create vertices
v = [-1, t, 0; % v1
      1, t, 0; % v2
     -1,-t, 0; % v3
      1,-t, 0; % v4
      0,-1, t; % v5
      0, 1, t; % v6
      0,-1,-t; % v7
      0, 1,-t; % v8
      t, 0,-1; % v9
      t, 0, 1; % v10
     -t, 0,-1; % v11
     -t, 0, 1];% v12
% normalise vertices to unit size
v = v./norm(v(1,:));
% create faces
f = [ 1,12, 6; % f1
      1, 6, 2; % f2
      1, 2, 8; % f3
      1, 8,11; % f4
      1,11,12; % f5
      2, 6,10; % f6
      6,12, 5; % f7
     12,11, 3; % f8
     11, 8, 7; % f9
      8, 2, 9; % f10
      4,10, 5; % f11
      4, 5, 3; % f12
      4, 3, 7; % f13
      4, 7, 9; % f14
      4, 9,10; % f15
      5,10, 6; % f16
      3, 5,12; % f17
      7, 3,11; % f18
      9, 7, 8; % f19
     10, 9, 2];% f20
end