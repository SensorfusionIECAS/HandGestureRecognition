% 对识别错的样本，看他们的码流是什么
clear;
addpath ./1
load down_1.mat
test=down_1{53};
[codes,plane] = funGesDir(test);
plot(codes);
% save('cwv_1_codes.mat','codes');

%% functions
function [dir,plane] = funGesDir( sample )

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

% 2. 计算axis1和axis2平面内，各点距离原点的距离，记为distR
% org1=min(sample(:,axis1))+(max(sample(:,axis1))-min(sample(:,axis1)))/2;
% org2=min(sample(:,axis2))+(max(sample(:,axis2))-min(sample(:,axis2)))/2;
org1=0;
org2=0;

distR=sqrt((sample(:,axis1)-org1).^2+(sample(:,axis2)-org2).^2);
% 找到一个最大的R，以后要用它来筛选可用的矢量
maxDistR=max(distR);
% disp([axis1,axis2,org1,org2,maxDistR]);

% 3. 逐点计算样本点与原点之间的夹角theta
theta=[0];
curTheta=0;
len=size(sample,1);
dir=[0];
for i=1:len
    if((sample(i,1)+sample(i,2)+sample(i,3))~=0)
        if(distR(i)>maxDistR*0.001)
            curTheta=atan2(sample(i,axis2)-org2,sample(i,axis1)-org1)*180/pi;
            lastTheta=theta(end);
            theta=[theta;curTheta];
            
            newDir=GetCrossQuadrant(lastTheta,curTheta);
            dir=[dir;newDir];
%             if newDir~=0
%                 dir=[dir;newDir];
%             end
        else
            disp('aloha!');
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
    for i=1:size(TEMPLATE_RIGHT,2)
        if (dirCode==TEMPLATE_RIGHT(i))
            isGesture=5;
            GesName='RIGHT';
        end
    end
    
    for i=1:size(TEMPLATE_RIGHT,2)
        if (dirCode==TEMPLATE_RIGHT(i))
            isGesture=6;
            GesName='RIGHT';
        end
    end
end

if plane=='Horizona'
    for i=1:size(TEMPLATE_RIGHT,2)
        if (dirCode==TEMPLATE_RIGHT(i))
            isGesture=7;
            GesName='RIGHT';
        end
    end
    
    for i=1:size(TEMPLATE_RIGHT,2)
        if (dirCode==TEMPLATE_RIGHT(i))
            isGesture=8;
            GesName='RIGHT';
        end
    end
end

end
