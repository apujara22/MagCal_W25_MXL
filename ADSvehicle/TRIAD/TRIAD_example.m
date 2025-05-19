yaw_pitch_roll = [30,20,-10] * pi/180;
BN = Euler3212C(yaw_pitch_roll);
s_N = [ 1 0 0 ]';
m_N = [ 0 0 1 ]';

s_B_true = BN*s_N;
s_B = [0.8190 -0.5282 0.2242]';
s_B = s_B / norm(s_B);

m_B_true = BN*m_N;
m_B = [-0.3138 -0.1548 0.9362]';
m_B = m_B/norm(m_B);

% Triad method
t1_B = s_B;
t2_B = cross(s_B, m_B) / norm(cross(s_B, m_B));
t3_B = cross(t1_B, t2_B);

barBT = [ t1_B t2_B t3_B ];

t1_N = s_N;
t2_N = cross(s_N, m_N) / norm(cross(s_N, m_N));
t3_N = cross(t1_N, t2_N);

NT = [t1_N t2_N t3_N];

barBN = barBT * NT'

barBB = barBN * BN'; % Errors

ErrorPhiDeg = acos(0.5*(trace(barBB) - 1)) * 180/pi
