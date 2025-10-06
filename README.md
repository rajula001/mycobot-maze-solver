# MyCobot Pro 600 — Maze Solver to Robot Execution (A* → IK → TCP)

This project solves a maze from a camera snapshot, maps the pixel path to robot coordinates, computes joint angles for a **MyCobot Pro 600**, and streams those angles to the arm over **TCP**. It demonstrates the full pipeline: **perception → planning → kinematics → actuation**.

---

##  What it does

1. **Capture & Solve Maze (Notebook)**
   - Capture a maze image from a camera.
   - Convert to binary and build a **cost matrix** from distance transform.
   - Run **A\*** (with Manhattan heuristic) to find a path from user-clicked start→goal.
   - Simplify the path using **Douglas–Peucker**.
   - Save the pixel path to `data/path_points.csv` (`Row, Column`).

2. **Pixel → Robot Coordinate Mapping (Notebook)**
   - Ask for two calibration points (robot top-left and bottom-right).
   - Fit linear maps (x: `pix→robot`, y: `pix→robot`) and transform every path point.
   - Save human-readable mappings to `data/robot_coordinates_output.txt`.

3. **Inverse Kinematics (MATLAB)**
   - Load **URDF** (`mycobot_pro600.urdf`) and set a **custom home pose**.
   - For each 3D waypoint (x,y,z) and fixed orientation (XYZ-Euler→quat),
     solve IK with `inverseKinematics`.
   - Append the 6-joint solution (deg) to `data/joint_solutions.csv`.

4. **Stream Joint Angles over TCP (Python)**
   - Read `joint_solutions.csv` and send commands like  
     `set_angles(j1, j2, j3, j4, j5, j6, 1200)` to the robot server (socket).
   - Robot executes the path.

 See `video/Group33_Demonstration.mp4` for a run (stored with **Git LFS**; download to view).

---



