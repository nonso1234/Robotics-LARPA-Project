%% Go Straight Close-Loop Template %%

% Copyright 2014 The MathWorks, Inc.


%% Set up %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
clc
%------- Change ME -------------------------
% Change based on your communication setting
mylego = legoev3; 
mysonicsensor = sonicSensor(mylego)
mygyrosensor = gyroSensor(mylego)
mycolorsensor = colorSensor(mylego);
resetRotationAngle(mygyrosensor);

% Set up MATLAB and EV3 communication

%For touch sensors..did not use anyways 
% mytouch = touchSensor(mylego, 1); %touch sensor is in lpug 1
% touch = readTouch(mytouch);
% if (touch == 1)
%     writeLCD(mylego, 'Button has been pressed',2,3)
%     playTone(mylego, 500, 3, 10)
%     
% else
%     writeLCD(mylego, ' ', 2, 3)
% end

% Change based on your motor port numbers
mymotor3 = motor(mylego, 'D'); 
mymotor1 = motor(mylego, 'B');              % Set up motor
mymotor2 = motor(mylego, 'C');  


% Application parameters
EXE_TIME = 200;                              % Application running time in seconds
PERIOD = 0.1;                               % Sampling period
SPEED = 20;                                 % Motor speed
SPEED2 = -20;   
P = 0.07;                                   % P controller parameter
%-------------------------------------------

mymotor1.Speed = SPEED;                     % Set motor speed
mymotor2.Speed = SPEED;
mymotor3.Speed = 0;

resetRotation(mymotor1);                    % Reset motor rotation counter
resetRotation(mymotor2);

start(mymotor1);                            % Start motor
start(mymotor2);
start(mymotor3);

t = timer('TimerFcn', 'stat=false;', 'StartDelay',EXE_TIME);
start(t);


%//////////////////////////////////////////////////////
startTime = datetime('now');

 

 t =  datetime('now') - startTime;
 ts=0;
 
 %To display text on the brick display 
%  while ts <= 100
%      t =  datetime('now') - startTime;
%      ts = seconds(t);
%      pause(.01);
% distance = readDistance(mysonicsensor);
% distance = sprintf('%.6f',distance)
% %disp_distance = double2str(distance);
% 
% display(distance)
% 
% writeLCD(mylego, distance,2,3)
% 
% 
%     end


%% Operations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stat = true;
lastR1 = 0;
lastR2 = 0;
q = 0;
s=-1;

r3 = readRotation(mymotor3); 

lastR3 = r3; 
    
%%close 
% while r3 > (lastR3 - 400)
%     disp('in here');
%     r3 = readRotation(mymotor3); 
%     SPEED = -75;  
%     mymotor3.Speed = -75; 
%     r3 
% end 
% 
% %open
% while r3 < (lastR3 + 400)
%     r3 = readRotation(mymotor3); 
%     SPEED = 75;  
%     mymotor3.Speed = 75; 
%     r3 
% end 

mymotor3.Speed = 0; 

while stat == true                          % Quit when time's up
    distance = readDistance(mysonicsensor);
%     resetRotationAngle(mygyrosensor);
    init_angle = readRotationAngle(mygyrosensor);
    r1 = readRotation(mymotor1) ;
    if s == -1  %%%Move forward until it reaches black line//
         mymotor1.Speed = 30;
         mymotor2.Speed = 30;
         
        lastR1=readRotation(mymotor1) ;
        lastR2 = readRotation(mymotor2);
         i = 0;
        while i == 0
            color = readColor(mycolorsensor);
            r1 = readRotation(mymotor1)   ;        % Read rotation counter in degrees
            r2 = readRotation(mymotor2)   ;        
    
    speed1 = (r1 - lastR1)/PERIOD;         % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    diff = speed1 - speed2;                 % P controller
    mymotor1.Speed = mymotor1.Speed - int8(diff * P);
    mymotor2.Speed = SPEED;
    
    lastR1 = r1;
    lastR2 = r2;
      if strcmp(color, 'black')
          i=1;
        end
        
        s=0
        end
         
    end
    
     if s ==0                  %%%Move back after finding the black line
      lastR1 = 0;
      lastR2 = 0;
        RR1=r1;
        RR2=r2;
        while lastR1 < 150 & lastR2 < 150
    
    r1 = readRotation(mymotor1)          % Read rotation counter in degrees
    r2 = readRotation(mymotor2)           
    
    % P controller
    mymotor1.Speed = -SPEED;
    mymotor2.Speed = -SPEED;
    
    lastR1 = RR1-r1;
    lastR2 = RR2-r2;
end
         mymotor1.Speed = 30;
    mymotor2.Speed = 30;
        s=1;
     end
     
    while s ==1                                                                %%%Begin turning and looking for debri
        disp('inside s1')
        new_angle=readRotationAngle(mygyrosensor);
        new_angle
        if new_angle > -150                                                   %%%Angle turning before it stops searching for debris
            if distance > .7
            distance = readDistance(mysonicsensor);
            r1 = readRotation(mymotor1) ;          % Read rotation counter in degrees
    r2 = readRotation(mymotor2)  ;         
    
    speed1 = (r1 - lastR1)/PERIOD;          % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    
    diff = speed1 + speed2;                 % P controller
    mymotor1.Speed = (mymotor1.Speed - int8(diff * P))*0.1;
    
    lastR1 = r1;
    lastR2 = r2;
%     pause(0.5);                                                             %%%Add pause to let robot turn a little
        else
            s=2;
        end
            
        else
            s=5;
            
        end
    end
        
       if s==2                                                                  %%%Move towards debri
           distance = readDistance(mysonicsensor);
           
       IR1=r1;
       while distance > 0.3 
           disp('in > 0.2');
           distance = readDistance(mysonicsensor);
           r1 = readRotation(mymotor1)    ;       % Read rotation counter in degrees
    r2 = readRotation(mymotor2)   ;        
    
    speed1 = (r1 - lastR1)/PERIOD;         % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    diff = speed1 - speed2;                 % P controller
    mymotor1.Speed = mymotor1.Speed - int8(diff * P);
    mymotor2.Speed = SPEED;
    
    lastR1 = r1;
    lastR2 = r2;
     distance = readDistance(mysonicsensor);
     color = readColor(mycolorsensor);
     if strcmp(color, 'black')                                             %%%Detect wall when pushing debri
         
               distance = 0.01;
           end
           
           
       end
       disp('in s==2');

       s=3
       
       
       
       end
   

    

if s==3                                                                        %%Push out debri
   
   i=0;
   while i == 0
      color = readColor(mycolorsensor);
      r1 = readRotation(mymotor1)   ;        % Read rotation counter in degrees
    r2 = readRotation(mymotor2)   ;        
    
    speed1 = (r1 - lastR1)/PERIOD;         % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    diff = speed1 - speed2;                 % P controller
    mymotor1.Speed = mymotor1.Speed - int8(diff * P);
    mymotor2.Speed = SPEED;
    
    lastR1 = r1;
    lastR2 = r2;
      if strcmp(color, 'black')
          i=1;
          
      end
      
       
   end
    s=4;
end

    
if s==4                                                                   %%%% MOve back after pushin out debree
    disp('in s==4')
                      % Set motor speed
SPEED = SPEED2;
 mymotor1.Speed = SPEED2;
  mymotor2.Speed = SPEED2;
  
  RR=r1;

           
    while r1 > IR1
        disp('in loop')
        
           r1 = readRotation(mymotor1)  ;          % Read rotation counter in degrees
    r2 = readRotation(mymotor2);            
    
    speed1 = (r1 - lastR1)/PERIOD;         % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    diff = speed1 - speed2;                 % P controller
    mymotor1.Speed = mymotor1.Speed - int8(diff * P);
    
    
    lastR1 = r1;
    lastR2 = r2;
    pause(PERIOD);
    
    end
     s=1;
    mymotor1.Speed=0;
        mymotor2.Speed=0;
        SPEED = 20;
 mymotor1.Speed = SPEED;
  mymotor2.Speed = SPEED;
    
    new_angle=readRotationAngle(mygyrosensor);
        NA = new_angle;
        while new_angle > (NA - 3)
            new_angle=readRotationAngle(mygyrosensor);
              r1 = readRotation(mymotor1) ;          % Read rotation counter in degrees
    r2 = readRotation(mymotor2)  ;         
    
    speed1 = (r1 - lastR1)/PERIOD;          % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    
    diff = speed1 + speed2;                 % P controller
    mymotor1.Speed = (mymotor1.Speed - int8(diff * P))*0.1;
    
    lastR1 = r1;
    lastR2 = r2;
        end
    
                                                                           %%%Turn after returning
   
        
    
end
   
    if s==5                                                               %% Turn towards black line of second debris area                                         
        disp('inside s=5')
        new_angle=readRotationAngle(mygyrosensor)
%         while new_angle > -450
%  while new_angle > -440
while new_angle > -440+10
            disp('inside while')
            new_angle=readRotationAngle(mygyrosensor);
            disp(new_angle);
            r1 = readRotation(mymotor1) ;          % Read rotation counter in degrees
    r2 = readRotation(mymotor2)  ;         
    
    speed1 = (r1 - lastR1)/PERIOD;          % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    lastR1=r1;
    lastR2=r2;
    diff = speed1 + speed2;                 % P controller
    mymotor1.Speed = (mymotor1.Speed - int8(diff * P))*0.1;
        end
        s=6
    end
    
    if s==6                                                                       %%%Detect black line in second debri area
        i = 0;
         mymotor1.Speed = SPEED;
    mymotor2.Speed =  SPEED;
        while i == 0
            color = readColor(mycolorsensor);
      r1 = readRotation(mymotor1)   ;        % Read rotation counter in degrees
    r2 = readRotation(mymotor2)   ;        
    
    speed1 = (r1 - lastR1)/PERIOD;         % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    diff = speed1 - speed2;                 % P controller
    mymotor1.Speed = mymotor1.Speed - int8(diff * P);
    mymotor2.Speed = SPEED;
    
    lastR1 = r1;
    lastR2 = r2;
      if strcmp(color, 'black')
          i=1;
        end
        
        s=7
        end
         mymotor1.Speed = SPEED;
    mymotor2.Speed = SPEED;
    end
    
    
    if s==7                                                                     %%%Move back a little after detecting black line in second debri area
        lastR1 = 0;
lastR2 = 0;
        RR1=r1;
        RR2=r2;
        while lastR1 < 110 & lastR2 < 110
    
    r1 = readRotation(mymotor1)          % Read rotation counter in degrees
    r2 = readRotation(mymotor2)           
    
                  % P controller
    mymotor1.Speed = -SPEED;
    mymotor2.Speed = -SPEED;
    
    lastR1 = RR1-r1;
    lastR2 = RR2-r2;
end
        
        s=8;
    end
    
    if s==8                                                                    %%%turn 90% to push any last debri in 2nd debri area
        mymotor1.Speed = 30;
    mymotor2.Speed = 30;
        new_angle=readRotationAngle(mygyrosensor)
        while new_angle > -540
            disp('inside while')
            new_angle=readRotationAngle(mygyrosensor);
            disp(new_angle);
            r1 = readRotation(mymotor1) ;          % Read rotation counter in degrees
    r2 = readRotation(mymotor2)  ;         
    
    speed1 = (r1 - lastR1)/PERIOD;          % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    
    diff = speed1 + speed2;                 % P controller
    mymotor1.Speed = (mymotor1.Speed - int8(diff * P))*0.1;
        end
        lastR1=r1;
    lastR2=r2;
        s=9                                                                  
    end
     if s==9                                                                   %%%push any last debri
         i = 0;
        while i == 0
            color = readColor(mycolorsensor);
      r1 = readRotation(mymotor1)   ;        % Read rotation counter in degrees
    r2 = readRotation(mymotor2)   ;        
    
    speed1 = (r1 - lastR1)/PERIOD;         % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    diff = speed1 - speed2;                 % P controller
    mymotor1.Speed = mymotor1.Speed - int8(diff * P);
    mymotor2.Speed = SPEED;
    
    lastR1 = r1;
    lastR2 = r2;
      if strcmp(color, 'black')
          i=1;
        end
        
        s=10
        end
         
     end
     
     if s == 10                                                             %%%Back up to turn after removing all debri
        lastR1 = 0;
lastR2 = 0;
        RR1=r1;
        RR2=r2;
        while lastR1 < 110 & lastR2 < 110
    
    r1 = readRotation(mymotor1)          % Read rotation counter in degrees
    r2 = readRotation(mymotor2)           
    
                  % P controller
    mymotor1.Speed = -SPEED;
    mymotor2.Speed = -SPEED;
    
    lastR1 = RR1-r1;
    lastR2 = RR2-r2;
end
        
        s=11;
    end
    
    if s==11                                                                    %%%Rotate 180 degrees. Clearing is done
        mymotor1.Speed = 30;
    mymotor2.Speed = 30;
        new_angle=readRotationAngle(mygyrosensor)
%         while new_angle > -540-180
while new_angle > -540-180+10
            disp('inside while')
            new_angle=readRotationAngle(mygyrosensor);
            disp(new_angle);
            r1 = readRotation(mymotor1) ;          % Read rotation counter in degrees
    r2 = readRotation(mymotor2)  ;         
    
    speed1 = (r1 - lastR1)/PERIOD;          % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    
    diff = speed1 + speed2;                 % P controller
    mymotor1.Speed = (mymotor1.Speed - int8(diff * P))*0.1;
        end
        lastR1=r1;
    lastR2=r2;
        s=12
    end 
         
     if s==12                                                               %%%look for black line at corner by blue
         AN = readRotationAngle(mygyrosensor);
       
         i = 0;
         mymotor1.Speed = 1.5*SPEED;
    mymotor2.Speed = 1.5* SPEED;
        while i == 0
            color = readColor(mycolorsensor);
      r1 = readRotation(mymotor1)   ;        % Read rotation counter in degrees
    r2 = readRotation(mymotor2)   ;        
    
    speed1 = (r1 - lastR1)/PERIOD;         % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    diff = speed1 - speed2;                 % P controller
    mymotor1.Speed = mymotor1.Speed - int8(diff * P);
    mymotor2.Speed = SPEED;
    
    lastR1 = r1;
    lastR2 = r2;
      if strcmp(color, 'black')
          i=1;
        end
        
        s=13                                                                   
        end
        mymotor1.Speed = SPEED;
    mymotor2.Speed = SPEED;
         
     end
     
     if s ==13                                                               %Bakcup and get ready to turn towards blue
         lastR1 = 0;
lastR2 = 0;
        RR1=r1;
        RR2=r2;
        while lastR1 < 110 & lastR2 < 110
    
    r1 = readRotation(mymotor1)          % Read rotation counter in degrees
    r2 = readRotation(mymotor2)           
    
                  % P controller
    mymotor1.Speed = -SPEED;
    mymotor2.Speed = -SPEED;
    
    lastR1 = RR1-r1;
    lastR2 = RR2-r2;
end
        
        s=14;
     end
         
    
     if s==14                             
        mymotor1.Speed = 0;
    mymotor2.Speed = 30;
        new_angle=readRotationAngle(mygyrosensor)
%         while new_angle < -540-180+90                                      %%% %%%Turn 45 degrees first time
%  while new_angle < -540-180+45
while new_angle < -540-180+45+10
            disp('inside while')
            new_angle=readRotationAngle(mygyrosensor);
            disp(new_angle);
            r1 = readRotation(mymotor1) ;          % Read rotation counter in degrees
    r2 = readRotation(mymotor2)  ;         
    
    speed1 = (r1 - lastR1)/PERIOD;          % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    
    diff = speed1 + speed2;                 % P controller
    mymotor2.Speed = (mymotor2.Speed - int8(diff * P))*0.1;
        end
        lastR1=r1;
    lastR2=r2;
        s=15
     end 
    
    if s == 15                                                               %%%Move a little forward to clear edge
        lastR1 = 0;
lastR2 = 0;
        RR1=r1;
        RR2=r2;
        while lastR1 > -150 & lastR2 > -150
    
    r1 = readRotation(mymotor1)          % Read rotation counter in degrees
    r2 = readRotation(mymotor2)           
    
                  % P controller
    mymotor1.Speed = SPEED;
    mymotor2.Speed = SPEED;
    
    lastR1 = RR1-r1;
    lastR2 = RR2-r2;
end
        
        s=16;                              
    end
    
    if s==16                                                                  %%%Turn 45 degrees second time
         mymotor1.Speed = 0;
    mymotor2.Speed = 30;
        new_angle=readRotationAngle(mygyrosensor)
%         while new_angle < -540-180+45+40
%  while new_angle < -540-180+45+30
while new_angle < -540-180+45+30+10
            disp('inside while')
            new_angle=readRotationAngle(mygyrosensor);
            disp(new_angle);
            r1 = readRotation(mymotor1) ;          % Read rotation counter in degrees
    r2 = readRotation(mymotor2)  ;         
    
    speed1 = (r1 - lastR1)/PERIOD;          % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    
    diff = speed1 + speed2;                 % P controller
    mymotor2.Speed = (mymotor2.Speed - int8(diff * P))*0.1;
        end
        lastR1=r1;
    lastR2=r2;
        s=17
        mymotor1.Speed = 0;
    mymotor2.Speed = 0;
    Ang = new_angle;
     end 
        
        
    if s == 17                                                               %%%Move forward until it reacher blue
        mymotor1.Speed = 30;
    mymotor2.Speed = 30;
         i = 0;
        while i == 0
            color = readColor(mycolorsensor)
      r1 = readRotation(mymotor1)   ;        % Read rotation counter in degrees
    r2 = readRotation(mymotor2)   ;        
    
    speed1 = (r1 - lastR1)/PERIOD;         % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    diff = speed1 - speed2;                 % P controller
    mymotor1.Speed = mymotor1.Speed - int8(diff * P);
    mymotor2.Speed = SPEED;
    
    lastR1 = r1;
    lastR2 = r2;
      if strcmp(color, 'blue')
          i=1;
        end
        
        s=18
        end
         
     end
        
  if s == 18                                                                 %%%Move forward until it reaches white
        
         i = 0;
        while i == 0
            color = readColor(mycolorsensor)
      r1 = readRotation(mymotor1)   ;        % Read rotation counter in degrees
    r2 = readRotation(mymotor2)   ;        
    
    speed1 = (r1 - lastR1)/PERIOD;         % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    diff = speed1 - speed2;                 % P controller
    mymotor1.Speed = mymotor1.Speed - int8(diff * P);
    mymotor2.Speed = SPEED;
    
    lastR1 = r1;
    lastR2 = r2;
      if strcmp(color, 'white')
          i=1;
        end
        
        s=19
        end
         
  end
    t =  datetime('now') - startTime;
     if s==19                                                                  %%%Pause for 5 seconds
%          tt=t
%          while t < tt+6
%              tt
%              t =  datetime('now') - startTime
%              mymotor1.Speed=0;
%         mymotor2.Speed=0;
%          end
    mymotor1.Speed=0;
    mymotor2.Speed=0;
 pause(5);
         s=20;
     end
     
     if s == 20                                                                  %%%Move forward until it reaches black line
         mymotor1.Speed = 30;
    mymotor2.Speed = 30;
        lastR1=readRotation(mymotor1) ;
        lastR2 = readRotation(mymotor2);
         i = 0;
        while i == 0
            color = readColor(mycolorsensor)
      r1 = readRotation(mymotor1)   ;        % Read rotation counter in degrees
    r2 = readRotation(mymotor2)   ;        
    
    speed1 = (r1 - lastR1)/PERIOD;         % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    diff = speed1 - speed2;                 % P controller
    mymotor1.Speed = mymotor1.Speed - int8(diff * P);
    mymotor2.Speed = SPEED;
    
    lastR1 = r1;
    lastR2 = r2;
      if strcmp(color, 'black')
          i=1;
        end
        
        s=21
        end
        mymotor1.Speed = 330;
    mymotor2.Speed = 30;
         
     end
     
  if s ==21                                                                 %%%Move back after detecting black line
      lastR1 = 0;
    lastR2 = 0;
        RR1=r1;
        RR2=r2;
        while lastR1 < 250 & lastR2 < 250
    
    r1 = readRotation(mymotor1)          % Read rotation counter in degrees
    r2 = readRotation(mymotor2)           
    
                  % P controller
    mymotor1.Speed = -SPEED;
    mymotor2.Speed = -SPEED;
    
    lastR1 = RR1-r1;
    lastR2 = RR2-r2;
end
        
        s=22;
  end
     
    if s == 22                                                                 %%%Turncounter clockwise to search for can
            mymotor1.Speed = 30;
    mymotor2.Speed = 30;
%         while s ==1
        disp('inside s22')
        new_angle=readRotationAngle(mygyrosensor);
        new_angle
%         while new_angle > -540-180-270
while new_angle > -540-180-270+10
            new_angle=readRotationAngle(mygyrosensor)
            if distance > .4
            distance = readDistance(mysonicsensor);
            r1 = readRotation(mymotor1) ;          % Read rotation counter in degrees
    r2 = readRotation(mymotor2)  ;         
    
    speed1 = (r1 - lastR1)/PERIOD;          % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    
    diff = speed1 + speed2;                 % P controller
    mymotor1.Speed = (mymotor1.Speed - int8(diff * P))*0.1;
    
    lastR1 = r1;
    lastR2 = r2;
        else
            s=23;
            new_angle=-1000000;
            end
           
        end
    end
    
    if s ==23                                                                  %%%ANgle offset
        new_angle=readRotationAngle(mygyrosensor);
        NA = new_angle;
        while new_angle > (NA - 12)
            new_angle=readRotationAngle(mygyrosensor);
              r1 = readRotation(mymotor1) ;          % Read rotation counter in degrees
    r2 = readRotation(mymotor2)  ;         
    
    speed1 = (r1 - lastR1)/PERIOD;          % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    
    diff = speed1 + speed2;                 % P controller
    mymotor1.Speed = (mymotor1.Speed - int8(diff * P))*0.1;
    
    lastR1 = r1;
    lastR2 = r2;
        end
        s=24;
    end
    
    if s==24                                                                   %%%Move towards can
           distance = readDistance(mysonicsensor);
           
       IR1=r1;
       while distance > 0.045
           
           
           disp('in > 0.22');
           distance = readDistance(mysonicsensor)
           r1 = readRotation(mymotor1)    ;       % Read rotation counter in degrees
    r2 = readRotation(mymotor2)   ;        
    
    speed1 = (r1 - lastR1)/PERIOD;         % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    diff = speed1 - speed2;                 % P controller
    mymotor1.Speed = mymotor1.Speed - int8(diff * P);
    mymotor2.Speed = SPEED;
    
    lastR1 = r1;
    lastR2 = r2;
     distance = readDistance(mysonicsensor);
     color = readColor(mycolorsensor);
     if strcmp(color, 'black')
         
               distance = 0.01;
           end
           
           
       end
       disp('in s==24');

       s=25
       
       end
        
      %Grip can  
     if s == 25                                                              %%%Grip the Can
         disp('in loop');
         mymotor1.Speed = 0;
         mymotor2.Speed = 0; 
         
pause(1);
         resetRotation(mymotor3);
         r3 = readRotation(mymotor3); 
         lastR3 = r3;
         while r3 > (lastR3 - 1200)
             disp("gripper loop")
             r3 = readRotation(mymotor3);
             SPEED = -90;
             mymotor3.Speed = SPEED; 
%              pause(0.1);
         end
      s = 26;   
         mymotor3.Speed = 0;
  
     end 
 
     if s==26                                                                %%%Move back with the can
         
          disp('in s==4')
                      % Set motor speed
SPEED = SPEED2;
 mymotor1.Speed = SPEED2;
  mymotor2.Speed = SPEED2;
  
  RR=r1;

           
    while r1 > IR1
        disp('in loop')
        
           r1 = readRotation(mymotor1)  ;          % Read rotation counter in degrees
    r2 = readRotation(mymotor2);            
    
    speed1 = (r1 - lastR1)/PERIOD;         % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    diff = speed1 - speed2;                 % P controller
    mymotor1.Speed = mymotor1.Speed - int8(diff * P);
    
    
    lastR1 = r1;
    lastR2 = r2;
    pause(PERIOD);
    
    end
    s=27;               
    mymotor1.Speed=0;
        mymotor2.Speed=0;
        SPEED = 20;
 mymotor1.Speed = SPEED;
  mymotor2.Speed = SPEED;
        
     end
     
     if s == 27                                                                    %%%Turn towards first red area
      
  mymotor1.Speed = 30;
    mymotor2.Speed = 30;
%         while s ==1
        disp('inside s27')
        new_angle=readRotationAngle(mygyrosensor);
        new_angle
%         while new_angle > -540-180-360
        while new_angle > -540-180-360+10
            new_angle=readRotationAngle(mygyrosensor)
           
            r1 = readRotation(mymotor1) ;          % Read rotation counter in degrees
    r2 = readRotation(mymotor2)  ;         
    
    speed1 = (r1 - lastR1)/PERIOD;          % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    
    diff = speed1 + speed2;                 % P controller
    mymotor1.Speed = (mymotor1.Speed - int8(diff * P))*0.1;
    
    lastR1 = r1;
    lastR2 = r2;
           
        end
           s=28;
     end
     
    if s == 28                                                                 %%% Move towards first red are
    mymotor2.Speed = 30;
         i = 0;
        while i == 0
            color = readColor(mycolorsensor)
      r1 = readRotation(mymotor1)   ;        % Read rotation counter in degrees
    r2 = readRotation(mymotor2)   ;        
    
    speed1 = (r1 - lastR1)/PERIOD;         % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    diff = speed1 - speed2;                 % P controller
    mymotor1.Speed = mymotor1.Speed - int8(diff * P);
    mymotor2.Speed = SPEED;
    
    lastR1 = r1;
    lastR2 = r2;
      if strcmp(color, 'red')
          i=1;
        end
        
        s=29
        end
         
    end
     
    if s ==29                                                               %% Move back from red
      lastR1 = 0;
lastR2 = 0;
        RR1=r1;
        RR2=r2;
        while lastR1 < 250 & lastR2 < 250
    
    r1 = readRotation(mymotor1)          % Read rotation counter in degrees
    r2 = readRotation(mymotor2)           
    
                  % P controller
    mymotor1.Speed = -SPEED;
    mymotor2.Speed = -SPEED;
    
    lastR1 = RR1-r1;
    lastR2 = RR2-r2;
end
        
        s=30;
    end
  
     if s == 30                                                             %%turn towards black line next to bridge
      
  mymotor1.Speed = 30;
    mymotor2.Speed = 30;
%         while s ==1
        disp('inside s27')
        new_angle=readRotationAngle(mygyrosensor);
        new_angle
%         while new_angle > -540-180-450
while new_angle > -540-180-450+10
            new_angle=readRotationAngle(mygyrosensor)
           
            r1 = readRotation(mymotor1) ;          % Read rotation counter in degrees
    r2 = readRotation(mymotor2)  ;         
    
    speed1 = (r1 - lastR1)/PERIOD;          % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    
    diff = speed1 + speed2;                 % P controller
    mymotor1.Speed = (mymotor1.Speed - int8(diff * P))*0.1;
    
    lastR1 = r1;
    lastR2 = r2;
           
        end
           s=31;
     end
     
     if s == 31                                                             %%% Detect black line of bridge
        mymotor1.Speed = 30;
    mymotor2.Speed = 30;
         i = 0;
        while i == 0
            color = readColor(mycolorsensor)
      r1 = readRotation(mymotor1)   ;        % Read rotation counter in degrees
    r2 = readRotation(mymotor2)   ;        
    
    speed1 = (r1 - lastR1)/PERIOD;         % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    diff = speed1 - speed2;                 % P controller
    mymotor1.Speed = mymotor1.Speed - int8(diff * P);
    mymotor2.Speed = SPEED;
    
    lastR1 = r1;
    lastR2 = r2;
      if strcmp(color, 'black')
          i=1;
        end
        
        s=32
        end
         
     end
    
     if s == 32
      
  mymotor1.Speed = -30;                                                     %%%Turn towards bridge entrance
    mymotor2.Speed = -30;
%         while s ==1
        disp('inside s27')
        new_angle=readRotationAngle(mygyrosensor);
        new_angle
%         while new_angle < -540-180-360
while new_angle < -540-180-360+10
            new_angle=readRotationAngle(mygyrosensor)
           
            r1 = readRotation(mymotor1) ;          % Read rotation counter in degrees
    r2 = readRotation(mymotor2)  ;         
    
    speed1 = (r1 - lastR1)/PERIOD;          % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    
    diff = speed1 + speed2;                 % P controller
    mymotor1.Speed = (mymotor1.Speed - int8(diff * P))*0.1;
    
    lastR1 = r1;
    lastR2 = r2;
           
        end
           s=33;
     end
     
     if s == 33                                                               %%%Move a little forward to clear edge of bridge
        lastR1 = 0;
lastR2 = 0;
        RR1=r1;
        RR2=r2;
        while lastR1 > -220 & lastR2 > -220
    
    r1 = readRotation(mymotor1)          % Read rotation counter in degrees
    r2 = readRotation(mymotor2)           
    
                  % P controller
    mymotor1.Speed = SPEED;
    mymotor2.Speed = SPEED;
    
    lastR1 = RR1-r1;
    lastR2 = RR2-r2;
end
        
        s=34;                              
     end
     
    if s == 34                                                             %%%Enter bridge
      
  mymotor1.Speed = 30;
    mymotor2.Speed = 30;
%         while s ==1
        disp('inside s27')
        new_angle=readRotationAngle(mygyrosensor);
        new_angle
%         while new_angle > -540-180-450
while new_angle > -540-180-450+10
            new_angle=readRotationAngle(mygyrosensor)
           
            r1 = readRotation(mymotor1) ;          % Read rotation counter in degrees
    r2 = readRotation(mymotor2)  ;         
    
    speed1 = (r1 - lastR1)/PERIOD;          % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    
    diff = speed1 + speed2;                 % P controller
    mymotor1.Speed = (mymotor1.Speed - int8(diff * P))*0.1;
    
    lastR1 = r1;
    lastR2 = r2;
           
        end
           s=35;
    end
     
    if s == 35                                                               %%% Move towards black line at exit
        mymotor1.Speed = 30;
    mymotor2.Speed = 30;
         i = 0;
        while i == 0
            color = readColor(mycolorsensor)
      r1 = readRotation(mymotor1)   ;        % Read rotation counter in degrees
    r2 = readRotation(mymotor2)   ;        
    
    speed1 = (r1 - lastR1)/PERIOD;         % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    diff = speed1 - speed2;                 % P controller
    mymotor1.Speed = mymotor1.Speed - int8(diff * P);
    mymotor2.Speed = SPEED;
    
    lastR1 = r1;
    lastR2 = r2;
      if strcmp(color, 'black')
          i=1;
        end
        
        s=36
        end
         
    end
     
    
    
     if s ==36                                                             %%%Move back a little to clear edge and get ready to turn to yellow
      lastR1 = 0;
lastR2 = 0;
        RR1=r1;
        RR2=r2;
        while lastR1 < 250 & lastR2 < 250
    
    r1 = readRotation(mymotor1)          % Read rotation counter in degrees
    r2 = readRotation(mymotor2)           
    
                  % P controller
    mymotor1.Speed = -SPEED;
    mymotor2.Speed = -SPEED;
    
    lastR1 = RR1-r1;
    lastR2 = RR2-r2;
end
        
        s=37;
  end
     
    
    
    
    if s == 37                                                               %%%Rotate towards yellow
      
  mymotor1.Speed = 30;
    mymotor2.Speed = 30;
%         while s ==1
        disp('inside s27')
        new_angle=readRotationAngle(mygyrosensor);
        new_angle
%         while new_angle > -540-180-540
while new_angle > -540-180-540+10
            new_angle=readRotationAngle(mygyrosensor)
           
            r1 = readRotation(mymotor1) ;          % Read rotation counter in degrees
    r2 = readRotation(mymotor2)  ;         
    
    speed1 = (r1 - lastR1)/PERIOD;          % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    
    diff = speed1 + speed2;                 % P controller
    mymotor1.Speed = (mymotor1.Speed - int8(diff * P))*0.1;
    
    lastR1 = r1;
    lastR2 = r2;
           
        end
           s=38;
    end
       
    if s == 38                                                                %%%Move towards yellow
        mymotor1.Speed = 30;
    mymotor2.Speed = 30;
         i = 0;
        while i == 0
            color = readColor(mycolorsensor)
      r1 = readRotation(mymotor1)   ;        % Read rotation counter in degrees
    r2 = readRotation(mymotor2)   ;        
    
    speed1 = (r1 - lastR1)/PERIOD;         % Calculate the real speed in d/s
    speed2 = (r2 - lastR2)/PERIOD;
    diff = speed1 - speed2;                 % P controller
    mymotor1.Speed = mymotor1.Speed - int8(diff * P);
    mymotor2.Speed = SPEED;
    
    lastR1 = r1;
    lastR2 = r2;
      if strcmp(color, 'yellow')
          i=1;
        end
        
        s=39
        end
         
    end
     
    if s ==39                                                                  %%%Relaease can
        resetRotation(mymotor3);
        r3 = readRotation(mymotor3); 

lastR3 = r3; 
    
while r3 < (lastR3 + 1200)
     mymotor1.Speed=0;
        mymotor2.Speed=0;
    r3 = readRotation(mymotor3); 
    SPEED = 85;  
    mymotor3.Speed = SPEED; 
    r3 
end 
mymotor3.Speed = 0;
s=40;
    end
    
   
     
       if s ==40                                                            %%%Move inreverse towards exit
      lastR1 = 0;
lastR2 = 0;
        RR1=r1;
        RR2=r2;
        while lastR1 < 1000 & lastR2 < 1000
    
    r1 = readRotation(mymotor1)          % Read rotation counter in degrees
    r2 = readRotation(mymotor2)           
    
                  % P controller
    mymotor1.Speed = -SPEED;
    mymotor2.Speed = -SPEED;
    
    lastR1 = RR1-r1;
    lastR2 = RR2-r2;
end
        
        s=41;
  end
    
    if s==41                                                                  %%%Program ends 

    mymotor1.Speed=0;
        mymotor2.Speed=0;  
        disp('in last if')
    end
    
                             % Wait for next sampling period
end

%% Clean up %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stop(mymotor1);                             % Stop motor 
stop(mymotor2);


