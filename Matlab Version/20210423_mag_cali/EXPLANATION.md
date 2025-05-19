# Code versions
- rc_pilot_a2sys 
    - afac3b1014a2f319034fd5f682a87dc1d7f09f5a


# Calibration Data ('calibration' Directory)
None for today

# General Notes
* The data here was gathered South of MAIR between sets of trees (goal is to have a magnetically constant area to calibrate in)
* Point of these tests is to gather some preliminary data to perform magnetometer calibration
    * I'll be just collecting onboard EStiBone data for this
        * This is because I'm planning on using Springman's calibration method which only needs a target magnetic field norm value to work with (i.e. no knwon attitude)
    * Later, it might be worthwhile to gather BBG mocap data as well to relate attitude to measurements
    
# Trajectories ('trajectory' directory)
- "Home pose" refers to drone porp guards being at navel height above mocap origin with +X body axis pointing towards +X mocap axis
- traj0
    * Start at home pose. 
    * Rotate +360 about +X body (roll)
    * Rotate +360 about +Y body (pitch)
    * Rotate +360 about +Z body (yaw)
- traj1
    * Perform motions in attempt to cover attitude sphere
- traj2
    * Perform 'traj0'
    * Perform 'traj1'


# Setup
- Quadrotor EstiBone 
- Outside of MAIR (south of MAIR)
    - +X of body facing geographic north

# Calibration Data ('calibration' Directory)

# Static Settings
- EstiBone
    - Settings File: estiBone_q4.json
    - Logging everything that can be logged
- Origin: 
    - Position: At taped center of OptiTrack Arena
    - Orientation: facing Eigen Cafe
- Vehicles:
    - EstiBone


# Test filenames ('flight_data' Directory)
- test0_
    - Trajectory:
        - traj0

- test1_
    - Trajectory:
        - traj0

- test2_
    - Trajectory:
        - traj1

- test3_
    - Trajectory:
        - traj1

- test4_
    - Trajectory:
        - traj2

- test5_
    - Trajectory:
        - traj2



        



# Anomalies