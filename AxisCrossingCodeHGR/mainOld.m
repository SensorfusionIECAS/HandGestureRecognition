% proccesing raw data
% find (ctrl+F) NOTICE before proccessing
% Not used
clear;
addpath F:\IEEE_SENSORS_J\GestureCode\dataset\train
addpath f:\IEEE_SENSORS_J\GestureCode\dataset\test

%% load raw data
% NOTICE: data format:
% [time ax ay az gx gy gz]
load CWV.txt;
test=CWV;
len=size(test,2);

%% coordinate transformation
% aES: a in the earth frame
linAccES=Sensor2Earth(test);
plotlinAccES(linAccES);

%% Segmentation
cellAcc=SegmentCutAcc(linAccES);

%% HGR
tic;
for i=1:len
    sample=cellAcc{i};
    [dirCode,plane] = funGesCode(sample);
    [isGesture,GesName]=funCheckGesture(dirCode,plane);
    index(i)=isGesture;
    
end
toc;

%% functions
function linAccES=Sensor2Earth(data)
time=data(:,1);
ax=data(:,2);
ay=data(:,3);
az=data(:,4);
gx=data(:,5)*pi/180;
gy=data(:,6)*pi/180;
gz=data(:,7)*pi/180;
len=size(data,1);
% qSE
q.q0=1; q.q1=0; q.q2=0; q.q3=0;

% gyro bias
normOld=0;
bStationary=0;
uStationaryCnt=0;
deltaNorm=0;
dcGx=0; dcGy=0; dcGz=0;

% LPFilter
linAcc.X=0; linAcc.Y=0; linAcc.Z=0;

linAccX=zeros(len,1);
linAccY=zeros(len,1);
linAccZ=zeros(len,1);

for i=1:len
    % gyro bias
    normNew=sqrt(gx(i)*gx(i) + gy(i)*gy(i) + gz(i)*gz(i));
    deltaNorm=deltaNorm*0.95+abs(normNew-normOld)*0.05;
    normOld=normNew;
    if deltaNorm<0.004
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
    
    [qo,linAcc,cutlinAcc,eulerAngle]=ComplementaryFilter(ax(i),ay(i),az(i),gx1(i),gy1(i),gz1(i),q,linAcc);
    q=qo;
    
    % you can switch between linAcc and cutlinAcc, "cut" means small value
    % cut in yo zero
    linAccX(i)=cutlinAcc.X;
    linAccY(i)=cutlinAcc.Y;
    linAccZ(i)=cutlinAcc.Z;
    
    yaw(i)=eulerAngle.X;
    pitch(i)=eulerAngle.Y;
    roll(i)=eulerAngle.Z;
end
linAccES=[linAccX linAccY linAccZ];
end

function [qo,linAcc,cutlinAcc,eulerAngle]=ComplementaryFilter(ax,ay,az,gx,gy,gz,q,linAcc)

q0=q.q0;
q1=q.q1;
q2=q.q2;
q3=q.q3;

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

% NOTICE!!! half of the sampling time, must be modified before processing
halfT=0.005;

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

qo.q0=q0;
qo.q1=q1;
qo.q2=q2;
qo.q3=q3;

% Low Pass Filter
linAcc.X=0.95*linAcc.X+0.05*linAccX;
linAcc.Y=0.95*linAcc.Y+0.05*linAccY;
linAcc.Z=0.95*linAcc.Z+0.05*linAccZ;

% % hpFilterForAcc (not much helpful)
% persistent meanVal;
% if isempty(meanVal)
% meanVal=[0;0;0];
% end
% alpha=0.999;
% meanVal=alpha*meanVal+(1-alpha)*[linAcc.X;linAcc.Y;linAcc.Z];
% linAcc.X=linAcc.X-meanVal(1);
% linAcc.Y=linAcc.Y-meanVal(2);
% linAcc.Z=linAcc.Z-meanVal(3);

cutlinAcc.X=linAcc.X;
cutlinAcc.Y=linAcc.Y;
cutlinAcc.Z=linAcc.Z;

STATIONARY_THRESHOLD=0.03;
if (abs(linAcc.X)<STATIONARY_THRESHOLD && abs(linAcc.Y)<STATIONARY_THRESHOLD ...
        && abs(linAcc.Z)<STATIONARY_THRESHOLD)
    cutlinAcc.X=0;
    cutlinAcc.Y=0;
    cutlinAcc.Z=0;
end
end

function plotlinAccES(linAccES)
len=size(linAccES,1);
% NOTICE!! sampling time
t=0.005:0.005:0.005*len;
figure;
plot(t,linAccES(:,1));
hold on;
plot(t,linAccES(:,2));
plot(t,linAccES(:,3));
ylabel('linAccES');
xlabel('time/s');
end

function cellData=SegmentCutAcc(data)
% segment cut(ted) acc by determining zero
len=100;
window=zeros(len,3);
THRE_AMPLITUDE=0.005; % 多大的幅值用来判静止
startTime=1;
endTime=2;
THRE_GESLEN=300;
reset=0;
CircleCnt=0;
j=1;
for i=1:size(data,1)
    lastMean=[mean(window(:,1)) mean(window(:,2)) mean(window(:,3))];
    isStaticPre=abs(lastMean(1))<THRE_AMPLITUDE && abs(lastMean(2))<THRE_AMPLITUDE  ...
        && abs(lastMean(3))<THRE_AMPLITUDE;
    
    % 窗口滑动一下，尾部进来
    window=[window(2:end,1) window(2:end,2) window(2:end,3);
        data(i,1) data(i,2) data(i,3)];
    
    nowMean=[mean(window(:,1)) mean(window(:,2)) mean(window(:,3))];
    isStaticPost=abs(nowMean(1))<THRE_AMPLITUDE && abs(nowMean(2))<THRE_AMPLITUDE  ...
        && abs(nowMean(3))<THRE_AMPLITUDE;
    
    % 刚才静止 现在不静止，记为一个开始点
    if (isStaticPre && ~isStaticPost)
        if (i<=len)
            startTime=i;
        else
            startTime=i-len;
        end
    end
    % 刚才不静止 现在静止，记为一个结束点
    if (~isStaticPre && isStaticPost)
        endTime=i;
    end
    % endTime==i 是为了使一个sample段只画一次，否则一段会重复画很多遍
    if (endTime==i && endTime-startTime-len>THRE_GESLEN)
        
        sampleX=data(startTime:endTime,1);
        sampleY=data(startTime:endTime,2);
        sampleZ=data(startTime:endTime,3);
        sample=[sampleX sampleY sampleZ];
        
        cellData{j}=sample;
        j=j+1;
        
        figure;
        plot(sampleX);
        hold on;
        plot(sampleY);
        plot(sampleZ);
    end
end

end

function [dirCode,plane] = funGesCode( sample )
%%   1. 选取运动幅度最大的两个轴，记为axis1, axis2;
ppX=max(sample(:,1))-min(sample(:,1));
ppY=max(sample(:,2))-min(sample(:,2));
ppZ=max(sample(:,3))-min(sample(:,3));

plane='None';

if((ppX<ppY) && (ppX<ppZ))
    axis1=2;
    axis2=3;
    plane='Vertical';
end

if((ppY<ppX) && (ppY<ppZ))
    axis1=1;
    axis2=3;
    plane='Vertical';
end

if((ppZ<ppX) && (ppZ<ppY))
    axis1=1;
    axis2=2;
    plane='Horizona';
end

%%   2. 计算axis1和axis2平面内，各点距离原点的距离，记为distR
org1=min(sample(:,axis1))+(max(sample(:,axis1))-min(sample(:,axis1)))/2;
org2=min(sample(:,axis2))+(max(sample(:,axis2))-min(sample(:,axis2)))/2;

distR=sqrt((sample(:,axis1)-org1).^2+(sample(:,axis2)-org2).^2);
% 找到一个最大的R，以后要用它来筛选可用的矢量
maxDistR=max(distR);
% disp([axis1,axis2,org1,org2,maxDistR]);

%% 3. 逐点计算样本点与原点之间的夹角theta
theta=[0];
curTheta=0;
dirCode=0;
gesCode=[0 0 0 0];
for i=1:length(sample)
    if((sample(i,1)+sample(i,2)+sample(i,3))~=0)
        if(distR(i)>maxDistR*0.5)    % 0.5
            curTheta=atan2(sample(i,axis2)-org2,sample(i,axis1)-org1)*180/pi;
            lastTheta=theta(end);
            theta=[theta;curTheta]; % 每次循环,theta向量的尾部都会增加一个数
            
            % newDir=GetCrossQuadrant(theta(i),theta(i+1));
            % 为啥提示我超出矩阵索引维度啊？
            newDir=GetCrossQuadrant(lastTheta,curTheta);
            if newDir~=0
                gesCode(1)=gesCode(2);
                gesCode(2)=gesCode(3);
                gesCode(3)=gesCode(4);
                gesCode(4)=newDir;
                dirCode=gesCode(1)*1000+gesCode(2)*100+gesCode(3)*10+gesCode(4);
            end
        end
    end
end
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
if a1 == 0 || a2 == 0
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
function [isGesture,GesName]=funCheckGesture(dirCode,plane)
% TEMPLATE_CIRCLE=[-1234, -2341, -3412, -4123, 1432, 4321, 3214, 2143];
TEMPLATE_CW=[1432, 4321, 3214, 2143];    % ClockWise
TEMPLATE_CCW=[-1234, -2341, -3412, -4123];   % Counter ClockWise
TEMPLATE_UP=    [-2336, 2136, -3357, 1359,   3588, -3568, 1427, 4266, 2659, -3409, -857, -2338, -912, 877];
TEMPLATE_DOWN=  [-4118,4318,-409,-4086, 427, -1179, 3177, 1766, -1179, -1786];
TEMPLATE_LEFT=  [2088,1359,4266,3177,  3209,4318,1427,2136, -2679,-1786,-857,-3568];
TEMPLATE_RIGHT= [-2268,-3357,-4086,-1179,  877,1766,2659,3588,  -4118,-1227,-2336,-3409];
isGesture=0;
GesName='None';

for i=1:size(TEMPLATE_CW,2)
    if (dirCode==TEMPLATE_CW(i))
        if (plane=='Vertical')
            isGesture=1;
            GesName='Clockwise Circle (Vertical)';
        elseif (plane=='Horizona')
            isGesture=3;
            GesName='Clockwise Circle (Horizonal)';
        end
    end
end

for i=1:size(TEMPLATE_CCW,2)
    if (dirCode==TEMPLATE_CCW(i))
        if (plane=='Vertical')
            isGesture=2;
            GesName='Counter Clockwise Circle (Vertical)';
        elseif (plane=='Horizona')
            isGesture=4;
            GesName='Counter Clockwise Circle (Horizonal)';
        end
    end
end

if plane=='Vertical'
    for i=1:size(TEMPLATE_UP,2)
        if (dirCode==TEMPLATE_UP(i))
            isGesture=5;
            GesName='Up';
        end
    end
    
    for i=1:size(TEMPLATE_DOWN,2)
        if (dirCode==TEMPLATE_DOWN(i))
            isGesture=6;
            GesName='Down';
        end
    end
end

if plane=='Horizona'
    for i=1:size(TEMPLATE_LEFT,2)
        if (dirCode==TEMPLATE_LEFT(i))
            isGesture=7;
            GesName='Left';
        end
    end
    
    for i=1:size(TEMPLATE_RIGHT,2)
        if (dirCode==TEMPLATE_RIGHT(i))
            isGesture=8;
            GesName='Right';
        end
    end
end

end








