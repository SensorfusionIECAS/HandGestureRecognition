function [ isCircle,outTheta ] = funCheckCircle( sample )
%FUNCHECKCIRCLE Summary of this function goes here
%   1. ѡȡ�˶��������������ᣬ��Ϊaxis1, axis2;
%   2. ����axis1��axis2ƽ���ڣ��������ԭ��ľ��룬��ΪdistR
%   3. ���distR>(max(distR)-min(distR))/2���������mean(distR)�ĵ���countR>cth�����ж�ΪתȦ����

%%   1. ѡȡ�˶��������������ᣬ��Ϊaxis1, axis2;
ppX=max(sample(:,1))-min(sample(:,1));
ppY=max(sample(:,2))-min(sample(:,2));
ppZ=max(sample(:,3))-min(sample(:,3));

if((ppX<ppY) && (ppX<ppZ))
    axis1=2;
    axis2=3;
end

if((ppY<ppX) && (ppY<ppZ))
    axis1=1;
    axis2=3;
end

if((ppZ<ppX) && (ppZ<ppY))
    axis1=1;
    axis2=2;
end

%%   2. ����axis1��axis2ƽ���ڣ��������ԭ��ľ��룬��ΪdistR
org1=min(sample(:,axis1))+(max(sample(:,axis1))-min(sample(:,axis1)))/2;
org2=min(sample(:,axis2))+(max(sample(:,axis2))-min(sample(:,axis2)))/2;

distR=sqrt((sample(:,axis1)-org1).^2+(sample(:,axis2)-org2).^2);
% �ҵ�һ������R���Ժ�Ҫ������ɸѡ���õ�ʸ��
maxDistR=max(distR);
%     disp([axis1,axis2,org1,org2,maxDistR]);

%% 3. ��������������ԭ��֮��ļн�theta
theta=[0];
codeStream=[0];
vidObj = VideoWriter('video.avi');
open(vidObj);
%figure(2);
%clf;
curTheta=0;
dirCode=0;
gesCode=[0 0 0 0];
for i=1:length(sample)
    if((sample(i,1)+sample(i,2)+sample(i,3))~=0)
        if(distR(i)>maxDistR*0.5)    % 0.5��������������ص�
            curTheta=atan2(sample(i,axis2)-org2,sample(i,axis1)-org1)*180/pi;
            lastTheta=theta(end);
            theta=[theta;curTheta]; % ÿ��ѭ��,theta������β����������һ����
            
            % newDir=GetCrossQuadrant(theta(i),theta(i+1));
            % ƾɶ��ʾ�ҳ�����������ά�Ȱ���
            newDir=GetCrossQuadrant(lastTheta,curTheta);
            codeStream=[codeStream;newDir];
            if newDir~=0
                gesCode(1)=gesCode(2);
                gesCode(2)=gesCode(3);
                gesCode(3)=gesCode(4);
                gesCode(4)=newDir;
                dirCode=gesCode(1)*1000+gesCode(2)*100+gesCode(3)*10+gesCode(4);
            end
            % disp(dirCode);
            
            % figure(2);
            if (0)
                subplot(311);
                line([org1,sample(i,axis1)],[org2,sample(i,axis2)],'Color',[0.2,0.3,0.6]);
                xlabel('(a) Axis Y','FontSize',15);
                ylabel('Axis Z','FontSize',15);
                box on;
                set(gca,'FontName','Times New Roman','FontSize',12,'LineWidth',0.5);
                subplot(312);
                %figure(3);
                plot([0.005:0.005:size(theta)*0.005],theta,'Color',[0.2,0.3,0.6],'LineWidth',1.5);
                xlabel('(b) Time(t/s)','FontSize',15);
                ylabel('Direction Angle(\theta\it/\circ)','FontSize',15);
                axis([0 1.52 -180 180]);
                set(gca,'FontName','Times New Roman','FontSize',12,'LineWidth',0.5);
                
                subplot(313);
                plot([0.005:0.005:size(codeStream)*0.005],codeStream,'Color',[0.2,0.3,0.6],'LineWidth',1.5);
                xlabel('(c) Time(t/s)','FontSize',15);
                ylabel('Axis-crossing code stream','FontSize',15);
                % axis([0 1.52 0 4]);
                set(gca,'FontName','Times New Roman','FontSize',12,'LineWidth',0.5);
            else
                subplot(121);
                line([org1,sample(i,axis1)],[org2,sample(i,axis2)],'Color',[0.2,0.3,0.6]);
                xlabel('(a) Axis Y','FontSize',15);
                ylabel('Axis Z','FontSize',15);
                box on;
                set(gca,'FontName','Times New Roman','FontSize',12,'LineWidth',0.5);
                subplot(122);
                plot([0.005:0.005:size(theta)*0.005],theta,'Color',[0.2,0.3,0.6],'LineWidth',1.5);
                xlabel('(b) Time(t/s)','FontSize',15);
                ylabel('Direction angle (\theta\it/\circ)','FontSize',15);
                axis([0 1.52 -180 180]);
                set(gca,'FontName','Times New Roman','FontSize',12,'LineWidth',0.5);
                
            end
            
            % pause(0.001);
            
            h=gcf;
            currFrame = getframe(h);
            writeVideo(vidObj,currFrame);
        end
    end
end
close(vidObj);

%% 4. ��¼theta�Ĳ��dtheta������dbinary����¼dbinary�е�1������len,len==1����2ʱ���ж�ΪתȦ
outTheta=theta;
dtheta=diff(theta);

for i=1:length(dtheta)
    if(abs(dtheta(i)))>50
        dtheta(i)=0;
    end
end
sumDtheta=sum((dtheta));
% ��С��50��dtheta��������ʲô��˼��

dbinary=(dtheta>0);
isCircle=false;

disp(sumDtheta);


%% plot ���
%     plot((theta));
%
%     plot(distR>((max(distR)-min(distR))/2),'r');hold on;plot(distR,'b');hold off;
%
%     hold on;
%     for i=1:length(sample)
%        line([org1,sample(i,axis1)],[org2,sample(i,axis2)]);
%        pause(0.1);
%     end
%     hold off;
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

