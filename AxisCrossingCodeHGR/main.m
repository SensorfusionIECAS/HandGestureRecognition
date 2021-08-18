
clear;
addpath ../dataset
% addpath ./1
% addpath ./2
% addpath ./3
% addpath F:\IEEE_SENSORS_J\GestureCode\dataset\2021.3.25

%% load segmented data
load cwv.mat;
test=cwv;
len=size(test,2);
index=zeros(1,len);

%% HGR
tic;
for i=1:len
    sample=test{i};
    [isGesture] = HGR(sample);
%     [isGesture,GesName]=funCheckGesture(dirCode,plane);
    index(i)=isGesture;
    % cwv 1
    % ccwv 2
    % cwh 3
    % ccwh 4
    % up 5
    % down 6
    % left 7
    % right 8
end
timeTotal=toc;
timeAverage=timeTotal*5000
accuracy=size(find(index==8),2)/size(index,2)

%% accuracy time
% cwv 1 133.3us
% ccwv 98.5%(13 20 28 是5 ) 123.0us
% cwh 1 125.8us
% ccwh 1 133.4us
% up: 1 86.5us
% dwon 1 96.8us
% left 1 88.0us
% right 1 95.5us


%% functions
function [isGesture] = HGR( sample )
%%   1. main axia: axis1, axis2
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
% org1=min(sample(:,axis1))+(max(sample(:,axis1))-min(sample(:,axis1)))/2;
% org2=min(sample(:,axis2))+(max(sample(:,axis2))-min(sample(:,axis2)))/2;
org1=0;
org2=0;
distR=sqrt((sample(:,axis1)-org1).^2+(sample(:,axis2)-org2).^2);
% 找到一个最大的R，以后要用它来筛选可用的矢量
maxDistR=max(distR);
% disp([axis1,axis2,org1,org2,maxDistR]);

%% 3. vector angle (theta)
theta=[0];
curTheta=0;
dirCode=0;
gesCode=[0 0 0 0];
CirclePrepare=0;
for i=1:length(sample)
    if((sample(i,1)+sample(i,2)+sample(i,3))~=0)
        if(distR(i)>maxDistR*0.1)    % 0.5 is too large
            % 0.1 对于down来说比较合适，0.001对于left比较合适，选择0.1删掉left的不良吧
            curTheta=atan2(sample(i,axis2)-org2,sample(i,axis1)-org1)*180/pi;
            lastTheta=theta(end);
            theta=[theta;curTheta]; % add one curTheta after every loop
            
            newDir=GetCrossQuadrant(lastTheta,curTheta);
            if newDir~=0
                gesCode(1)=gesCode(2);
                gesCode(2)=gesCode(3);
                gesCode(3)=gesCode(4);
                gesCode(4)=newDir;
                dirCode=gesCode(1)*1000+gesCode(2)*100+gesCode(3)*10+gesCode(4);
                [isGesture,isCircleCode]=checkGesture(dirCode,plane,ppX,ppY,ppZ,CirclePrepare);
                CirclePrepare=isCircleCode;
                if isGesture~=0
                    return
                end
            end
        end
    end
end


end

function [isGesture,isCircleCode]=checkGesture(dirCode,plane,ppX,ppY,ppZ,CirclePrepare)
% TEMPLATE_CIRCLE=[-1234, -2341, -3412, -4123, 1432, 4321, 3214, 2143];
TEMPLATE_CW=[1432, 4321, 3214, 2143];
TEMPLATE_CCW=[-1234, -2341, -3412, -4123];
TEMPLATE_UP=    [-2336, 2136, -3357, 1359,   3588, -3568, 1427, 4266, 2659, -3409, -857, -2338, -912, 877];
TEMPLATE_DOWN=  [-4118,4318,-409,-4086, 427, -1179, 3177, 1766, -1179, -1786];
TEMPLATE_LEFT=  [2088,1359,4266,3177,  3209,4318,1427,2136, -2679,-1786,-857,-3568];
TEMPLATE_RIGHT= [-2268,-3357,-4086,-1179,  877,1766,2659,3588,  -4118,-1227,-2336,-3409];
isGesture=0;
isCircleCode=0;
isLeftCode=0;
ppUD=0.9;   % upper than this threshold can a U/D be recognized
ppLR=0.8;   % upper than this threshold can a L/R be recognized
% r2 need 0.8

for i=1:4
    if (dirCode==TEMPLATE_CW(i) && (ppX>0.1||ppY>0.1||ppZ>0.1))
        if (plane=='Vertical')
            if CirclePrepare==0
                isCircleCode=1;
                return
            else
                isGesture=1;
                isCircleCode=0;
            end
        elseif (plane=='Horizona')
            if CirclePrepare==0
                isCircleCode=1;
                return
            else
                isGesture=3;
                isCircleCode=0;
            end
        end
    end
end

for i=1:4
    if (dirCode==TEMPLATE_CCW(i) && (ppX>0.1||ppY>0.1||ppZ>0.1))
        if (plane=='Vertical')
            if CirclePrepare==0
                isCircleCode=1;
                return
            else
                isGesture=2;
                isCircleCode=0;
            end
        elseif (plane=='Horizona')
            if CirclePrepare==0
                isCircleCode=1;
                return
            else
                isGesture=4;
                isCircleCode=0;
            end
        end
    end
end

if plane=='Vertical'
    for i=1:14
        if (dirCode==TEMPLATE_UP(i) && (ppX>ppUD||ppY>ppUD||ppZ>ppUD))
            isGesture=5;
        end
    end
    
    for i=1:10
        if (dirCode==TEMPLATE_DOWN(i) && (ppX>ppUD||ppY>ppUD||ppZ>ppUD))
            isGesture=6;
        end
    end
end

if plane=='Horizona'
    for i=1:12
        if (dirCode==TEMPLATE_LEFT(i) && (ppX>ppLR||ppY>ppLR||ppZ>ppLR))
            isGesture=7;
        end
    end
    
    for i=1:12
        if (dirCode==TEMPLATE_RIGHT(i) && (ppX>ppLR||ppY>ppLR||ppZ>ppLR))
            isGesture=8;
        end
    end
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






