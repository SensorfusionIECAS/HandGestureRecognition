% Figure 1,2 
% or make video abstract
clear;
data=load('PerfectCW.csv');
time=data(:,2);
ax=data(:,4);
ay=data(:,5);
az=data(:,6);
gx=data(:,7)*pi/180;
gy=data(:,8)*pi/180;
gz=data(:,9)*pi/180;

%% Transfer aS to aE

% qSE
q.q0=1;
q.q1=0;
q.q2=0;
q.q3=0;

% dcG
normOld=0;
bStationary=0;
uStationaryCnt=0;
deltaNorm=0;
dcGx=0;
dcGy=0;
dcGz=0;

% LPFilter
linAcc.X=0;
linAcc.Y=0;
linAcc.Z=0;


for i=1:size(data,1)
    
    % dcGyro
    normNew=sqrt(gx(i)*gx(i) + gy(i)*gy(i) + gz(i)*gz(i));
    deltaNorm=deltaNorm*0.9+abs(normNew-normOld)*0.1;
    normOld=normNew;
    if deltaNorm<0.01
        if uStationaryCnt<100
            uStationaryCnt=uStationaryCnt+1;
        end
    else
        bStationary=0;
    end
    if uStationaryCnt==100
        bSationary=1;
    end
    if bStationary==1
        dcGx=dcGx*0.99+gx(i)*0.01;
        dcGy=dcGy*0.99+gy(i)*0.01;
        dcGz=dcGz*0.99+gz(i)*0.01;
    end
    gx1(i)=gx(i)-dcGx;
    gy1(i)=gy(i)-dcGy;
    gz1(i)=gz(i)-dcGz;
    % ---------------------------------------------------------------------
    % AccEarth
    [qo,linAcc,eulerAngle]=S2E(ax(i),ay(i),az(i),gx1(i),gy1(i),gz1(i),q,linAcc);
    linAccX(i,:)=linAcc.X;
    linAccY(i,:)=linAcc.Y;
    linAccZ(i,:)=linAcc.Z;
    q=qo;
    yaw(i)=eulerAngle.X;
    pitch(i)=eulerAngle.Y;
    roll(i)=eulerAngle.Z;
    % ---------------------------------------------------------------------
    % 
    
end

%% Figure 1 (need to cut out 10.4s-15.0s)

figure(1);
plot([0.005:0.005:size(linAccX)*0.005],linAccX,'k','LineWidth',1.5);
hold on;
grid on;
plot([0.005:0.005:size(linAccY)*0.005],linAccY,'b--','LineWidth',1.5);
plot([0.005:0.005:size(linAccZ)*0.005],linAccZ,'r-.','LineWidth',1.5);
legend('Linear Acceleration X','Linear Acceleration Y','Linear Acceleration Z');
xlabel('Time(t/s)');ylabel('Acceleration(G/N)');
set(gca,'FontName','Times New Roman','FontSize',12,'LineWidth',0.5);

%% Figure 2 and video(in funCheckCircle)
figure(2);
% set(gcf,'position',[500,30,600,800]) % 做视频的时候用这个
set(gcf,'position',[0,0,960,360]) % 做图的时候用这个
sample=[linAccX(2320:2620,:) linAccY(2320:2620,:) linAccZ(2320:2620,:)];
[ isCircle,outTheta ] = funCheckCircle( sample );


%% Functions
function [qo,linAcc,eulerAngle]=S2E(ax,ay,az,gx,gy,gz,q,linAcc)

%qSE
q0=q.q0;
q1=q.q1;
q2=q.q2;
q3=q.q3;

% 鍏充簬涓轰粈涔堣瀵筧cc褰掍竴鍖?
% 鎰忎箟浠呭湪浜庣畻鍙変箻鐨勮搴﹁宸紝鎺掗櫎澶у皬鐨勫奖鍝?
% 鍚庢潵绠條inacc鐨勬椂鍊欑敤鐨勮繕鏄湭褰掍竴鍖栫殑acc
norm = sqrt(ax * ax + ay * ay + az * az);
ax1 = ax / norm;
ay1 = ay / norm;
az1 = az / norm;

vx=2*(q1*q3-q0*q2);
vy=2*(q0*q1+q2*q3);
vz=q0*q0-q1*q1-q2*q2+q3*q3;

ex = (ay1*vz - az1*vy);
ey = (az1*vx - ax1*vz);
ez = (ax1*vy - ay1*vx);

CoffKp=1;
refx = gx + CoffKp*ex ;
refy = gy + CoffKp*ey ;
refz = gz + CoffKp*ez ;

halfT=0.0025;
temp_q0 = q0 + (-q1*refx - q2*refy - q3*refz)*halfT;
temp_q1 = q1 + (q0*refx + q2*refz - q3*refy)*halfT;
temp_q2 = q2 + (q0*refy - q1*refz + q3*refx)*halfT;
temp_q3 = q3 + (q0*refz + q1*refy - q2*refx)*halfT;

norm = sqrt(temp_q0*temp_q0 + temp_q1*temp_q1 + temp_q2*temp_q2 + temp_q3*temp_q3);
q0 = temp_q0 / norm;
q1 = temp_q1 / norm;
q2 = temp_q2 / norm;
q3 = temp_q3 / norm;

% qES
q0=q0;
q1=-q1;
q2=-q2;
q3=-q3;

eulerAngle.X = atan2(2*q1*q2 - 2*q0*q3, 2 * q0 * q0 + 2 * q1 * q1 - 1) * 180/pi; %Yaw
if eulerAngle.X < 0
    eulerAngle.X = eulerAngle.X + 360;
end

if eulerAngle.X > 360
    eulerAngle.X = eulerAngle.X - 360;
end

eulerAngle.Y = -asin(2*q1*q3 + 2*q0*q2) * 180/pi;                  %Pitch
eulerAngle.Z = atan2(2*q2*q3 - 2*q0*q1, 2 * q0 * q0 + 2 * q3* q3 - 1) * 180/pi; %Roll

% qSE
q0=q0;
q1=-q1;
q2=-q2;
q3=-q3;

% calculate linear acc by qSE
linAccX = 2 * ax * (0.5 - q2 * q2 - q3 * q3) + 2 * ay * (q1 * q2 - q0 * q3) + 2 * az * (q1 * q3 + q0 * q2);
linAccY = 2 * ax * (q1 * q2 + q0 * q3) + 2 * ay * (0.5 - q1 * q1 - q3 * q3) + 2 * az * (q2 * q3 - q0 * q1);
linAccZ = 2 * ax * (q1 * q3 - q0 * q2) + 2 * ay * (q2 * q3 + q0 * q1) + 2 * az * (0.5 - q1 * q1 - q2 * q2) - 1;

% LPFilter
linAcc.X=0.95*linAcc.X+0.05*linAccX;
linAcc.Y=0.95*linAcc.Y+0.05*linAccY;
linAcc.Z=0.95*linAcc.Z+0.05*linAccZ;

qo.q0=q0;
qo.q1=q1;
qo.q2=q2;
qo.q3=q3;


end
function quad=GetQuadrant(angle)
quad=0;
if angle>=0 && angle<90
    quad=1;
end
if angle>=90 && angle<180
    quad=2;
end
if angle>=-180 && angle<-90
    quad=3;
end
if angle>=-90 && angle<0
    quad=4;
end
end
function dir=GetCrossQuadrant(a1,a2)
dir=0;
quad1=GetQuadrant(a1);
quad2=GetQuadrant(a2);
if angle1 == 0 || angle2 == 0
    dir = 0;
elseif (quad1 == 1) && (quad2 == 4)
    dir = 1;
elseif (quad1 == 2) && (quad2 == 1)
    dir = 2;
elseif (quad1 == 3) && (quad2 == 2)
    dir = 3;
elseif (quad1 == 4) && (quad2 == 3)
    dir = 4;
elseif (quad1 == 4) && (quad2 == 1)
    dir = -1;
elseif (quad1 == 1) && (quad2 == 2)
    dir = -2;
elseif (quad1 == 2) && (quad2 == 3)
    dir = -3;
elseif (quad1 == 3) && (quad2 == 4)
    dir = -4;
else
    dir = 0;
end
end
function [dirCode,lastTheta]=calcDirCode1(lastTheta,ay,az)
newDir=0;
dirCode=0;
if abs(az)>0.1
    curTheta=atan2(az,ay)*180/pi;
    newDir=GetCrossQuadrant(lastTheta,curTheta);
    if newDir~=0
        gesCode(1)=gesCode(2);
        gesCode(2)=gesCode(3);
        gesCode(3)=gesCode(4);
        gesCode(4)=newDir;
        dirCode=gesCode(1)*1000+gesCode(2)*100+gesCode(3)*10+gesCode(4);
    end
    lastTheta=curTheta;
end
end
function [dirCode,lastTheta]=calcDirCode2(lastTheta,ax,az)
newDir=0;
dirCode=0;
if abs(az)>0.1
    curTheta=atan2(az,ax)*180/pi;
    newDir=GetCrossQuadrant(lastTheta,curTheta);
    if newDir~=0
        gesCode(1)=gesCode(2);
        gesCode(2)=gesCode(3);
        gesCode(3)=gesCode(4);
        gesCode(4)=newDir;
        dirCode=gesCode(1)*1000+gesCode(2)*100+gesCode(3)*10+gesCode(4);
    end
    lastTheta=curTheta;
end
end
function [dirCode,lastTheta]=calcDirCode3(lastTheta,ax,ay)
newDir=0;
dirCode=0;
if abs(ay)>0.1
    curTheta=atan2(ay,ax)*180/pi;
    newDir=GetCrossQuadrant(lastTheta,curTheta);
    if newDir~=0
        gesCode(1)=gesCode(2);
        gesCode(2)=gesCode(3);
        gesCode(3)=gesCode(4);
        gesCode(4)=newDir;
        dirCode=gesCode(1)*1000+gesCode(2)*100+gesCode(3)*10+gesCode(4);
    end
    lastTheta=curTheta;
end
end




