%% Importing Robot Model and Setting Initial Configuration
urdfPath = "D:\Ajith\ASU\2ND SEMESTER\RAS 545 (ROBOTIC SYSTEMS 1)\Lab4\FINAL SOLUTION\mycobot_pro600.urdf";
robotModel = importrobot(urdfPath);

% Define the specified custom home configuration
customHomeConfig = homeConfiguration(robotModel);
customHomeConfig(1).JointPosition = deg2rad(46.484);    
customHomeConfig(2).JointPosition = deg2rad(-120.495);  
customHomeConfig(3).JointPosition = deg2rad(-107.298);     
customHomeConfig(4).JointPosition = deg2rad(-44.824);       
customHomeConfig(5).JointPosition = deg2rad(88.857);    
customHomeConfig(6).JointPosition = deg2rad(-8.877); 

initialGuessIK = customHomeConfig; % Initial guess for IK solver

%% Load 3D Coordinates from File
coordinateFilePath = "C:\Users\ajith\Downloads\converted_coordinates (1).txt";
coordinateData = readmatrix(coordinateFilePath, 'Delimiter', ',', 'OutputType', 'char');

% Parse data into a matrix of 3D points
numberOfPoints = size(coordinateData, 1);
coordinateMatrix = zeros(numberOfPoints, 3);

for pointIdx = 1:numberOfPoints
    coordinateMatrix(pointIdx, :) = str2double(split(coordinateData(pointIdx, :), ':'));
end

%% Set Up Inverse Kinematics Solver
ikSolver = inverseKinematics('RigidBodyTree', robotModel);
ikSolver.SolverParameters.PositionTolerance = 0;
ikSolver.SolverParameters.OrientationTolerance = 0;
ikSolver.SolverParameters.AllowRandomRestart = false;
solverWeights = [0.5, 0.5, 0.5, 0.5, 0.5, 0.5];
allJointAngles = zeros(numberOfPoints, 6);

%% Perform Inverse Kinematics for Each Coordinate with Visualization
rotationOrientation = eul2quat([175.846 * pi / 180, 0.863 * pi / 180, -85.628 * pi / 180], "XYZ");

figure;
for pointIdx = 1:numberOfPoints
    targetPosition3D = coordinateMatrix(pointIdx, :);
    targetPose = trvec2tform(targetPosition3D) * quat2tform(rotationOrientation);
    [solutionConfig, ~] = ikSolver('Link_6', targetPose, solverWeights, initialGuessIK);
    initialGuessIK = solutionConfig; % Update initial guess for next iteration
    allJointAngles(pointIdx, :) = [solutionConfig(1).JointPosition, ...
                                   solutionConfig(2).JointPosition, ...
                                   solutionConfig(3).JointPosition, ...
                                   solutionConfig(4).JointPosition, ...
                                   solutionConfig(5).JointPosition, ...
                                   solutionConfig(6).JointPosition] * 180 / pi;

    % Append joint angles to CSV file
    writematrix(allJointAngles(pointIdx, :), 'joint_solutions.csv', 'WriteMode', 'append');

    % Visualization of Robot Configuration
    subplot(1, 2, 1);
    show(robotModel, solutionConfig);
    view([1, 0, 0]);
    title('Front View');
    
    subplot(1, 2, 2);
    show(robotModel, solutionConfig);
    view([0, 0, 1]);
    title('Top View');
    
    sgtitle(sprintf('Step Number: %d', pointIdx));
    pause(1);
end
