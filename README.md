# Robotics-LARPA-Project
Team: Chinonso Ovuegbe and Ernesto Hernandez

Final Project for the Fundamentals of Robotics course taught by Dr Pranav Bhounsule 

The motivation for this project is the DARPA robotics challenge. In this case we use a LEGO built mobile robot with a differential drive mobile base. As a result, we did not worry about a lot of the complexieties(e.g bipedal locomotion and control, manipulation, obstacle avoidance), including hardware complexities, as was the case in the DARPA competition. 

The goal of the project was build and program a robot to automonously navigate through a color coded task space and execute a series of tasks under certain constraints. More info here 


Uisng data from the available sensors provided in the kit (Gyro, ultrasonic, sonar, color sensor),we wrote MATLAB code to navigate along the task and perform required tasks. It helped that the navigation space was intentionally color coded to aid navigation. That way we wrote code specific to the color scheme and arrangement provided on the task space.

Here's a video of the robot performing one the required tasks: Debris clearing (https://youtu.be/qQem7EBzldo). For this routine, we programmed the robot to search for debris by rotating at a point until ultrasonic detects object/debris beyond a distance threshold(we kept tuning this parameter and 0.3 worked fine), then it moves forward and clears debris off the task space. The black strip acted as a boundary to prevent the robot from leaving the task space, so robot was programmed to back up whenever it met a black line in that specific region. It was daunting having to hard code or tune parameters for every single move through the project (e.g right turn after debris clearing was different from a simple right turn at a checkpoint when robot is facing forward). You certainly appreciate using advanced sensors(e.g LIDAR) and recycling navigation algorithm available on ROS for simple navigation and obstacle avoidance tasks.  

We only remebered to record the debris clearing stage :(, as it took some time to get it to work. We were releived so we recorded that bit. However we successfully completed all the tasks in time :)




  
