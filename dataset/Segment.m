% segment cut(ted) acc and plot all the segmented samples

%% load data
clear;
addpath ./raw
data=load('l5.txt');
x=data(:,8);
y=data(:,9);
z=data(:,10);

%% segmentation
% length of the sliding window
len=10;
window=zeros(len,3);

% the amplitude threshold to determine whether static 
THRE_AMPLITUDE=0.0001;

% initialize the start and end points
startTime=1;
endTime=2;

% the minimum gesture length
THRE_GESLEN=80;

j=1;
for i=1:size(data,1)
    lastMean=[mean(window(:,1)) mean(window(:,2)) mean(window(:,3))];
    isStaticPre=abs(lastMean(1))<THRE_AMPLITUDE && abs(lastMean(2))<THRE_AMPLITUDE  ...
        && abs(lastMean(3))<THRE_AMPLITUDE;
    
    % 窗口滑动一下，尾部进来
    window=[window(2:end,1) window(2:end,2) window(2:end,3);
        x(i) y(i) z(i)];
    
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
        
        sampleX=data(startTime:endTime,8);
        sampleY=data(startTime:endTime,9);
        sampleZ=data(startTime:endTime,10);
        sample=[sampleX sampleY sampleZ];
        
        % NOTICE
        l5{j}=sample;
        j=j+1;
        
        figure;
        plot(sampleX);
        hold on;
        plot(sampleY);
        plot(sampleZ);
    end
end


%% save1
% 使用c{2}=[]可以将相应元素置零，不改变cell中元素的个数，
% 而使用 c(2)=[]则删除相应元素，改变了cell中元素的个数。
%% 


% l5([1 2])=[];
% save('l5.mat','l5'); 

% r3([1 2 3 88])=[];
% save('r3.mat','r3'); 

% l4([1 7 15 17])=[];
% save('l4.mat','l4'); 

% l3([1 3 6 50 78])=[];
% save('l3.mat','l3'); 

% d3([1 2])=[];
% save('d3.mat','d3'); 
% d3(100)=[];
% save('d3.mat','d3'); 

% u3(1)=[];
% save('u3.mat','u3'); 

% ccwh3([1 2 24 69 77])=[];
% save('ccwh3.mat','ccwh3'); 
% ccwh3(45)=[];
% save('ccwh3.mat','ccwh3'); 

% cwh3([1 2 3])=[];
% save('cwh3.mat','cwh3'); 
% cwh3(6)=[];
% save('cwh3.mat','cwh3'); 

% ccwv5([1 2])=[];
% save('ccwv5.mat','ccwv5'); 

% ccwv4([1 2])=[];
% save('ccwv4.mat','ccwv4'); 
% ccwv4([60 63:end])=[];
% save('ccwv4.mat','ccwv4'); 

% md ccwv3.txt废了，一半都不能用
% ccwv3(1)=[];
% save('ccwv3.mat','ccwv3'); 
% ccwv3(32:end)=[];
% save('ccwv3.mat','ccwv3'); 
% ccwv3([10 19 23])=[];
% save('ccwv3.mat','ccwv3'); 

% cwv3([1 2])=[];
% save('cwv3.mat','cwv3'); 

% r2([23 24])=[];
% save('r2.mat','r2'); 

% l2([1 2])=[];
% save('l2.mat','l2'); 
% l2([3 12 14 20 22])=[];
% save('l2.mat','l2'); 


% u2([1 2 3 4 5])=[];
% save('u2.mat','u2'); 
% u2(42)=[];
% save('u2.mat','u2'); 

% d2([1 2 3])=[];
% save('d2.mat','d2'); 
% d2([2 4 5 12 16 28 31 42])=[];
% save('d2.mat','d2'); 

% down_1([1 4 8 11 15 16 19 30])=[];
% save('down_1.mat','down_1');

% right_1([1 2 3 6 8 22 31 34 39 50])=[];
% right_1([43 46 52])=[];
% save('right_1.mat','right_1');

% save('cwv_2.mat','cwv_2');

% ccwv_1: 52个 C++的第39没有识别出来 10 11 12 13 35 有截0,但是准确率1
% save('ccwv_2.mat','ccwv_2');

% 45个:7 42 识别不出来，删了.剩43个
% cwh_2([7 42])=[];
% save('cwh_2.mat','cwh_2');

% ccwh_2([3 10 11 21 33 37])=[];
% ccwh_2([26 36])=[];
% save('ccwh_2.mat','ccwh_2');

