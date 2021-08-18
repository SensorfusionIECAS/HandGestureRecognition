% figure 10
% RNN: draw BiLSTM GRU accu and time

% royal blue 0.2549 0.4117 0.8823
% violet 0.9333 0.5098 0.9333
% violet red 0.8156 0.1254 0.5647
% dark green 0 0.3922 0
% maroon 0.6902 0.1882 0.3764
% orange 1 0.647 0

BiLSTM_accuracy=[100 98.3 98.3 98.3 100 98.3 95 95];
GRU_accuracy=[98.33 95 98.3 98.3 100 98.3 96.67 95];


data=[1 1578.5 5469.1 3341.4 133.3
    2    1574.4  5352.3 3407.5 123.0
    3    1511.4  5352.3 3307.8 125.8
    4    1604.4  5385.5 3324.5 133.4
    5    1402.9  5319.1 3374.3 86.5
    6    1435.7  5352.8 3341.4 96.8
    7    1212.4  5386.0 3374.8 88.0
    8    1294.4  5452.6 3324.8 95.5];


if (0)
    figure(1);
    bar(data(:,2),'FaceColor',[0.2549 0.4117 0.8823])
    hold on;
    bar(data(:,3),'FaceColor',[0.6902 0.1882 0.3764])
    bar(data(:,4),'FaceColor',[0 0.3922 0])
    bar(data(:,5),'FaceColor',[1 0.647 0])
    
    set(gca,'fontname','times new roman')
    set(gca,'xticklabel',num2str(data(:,1)))
    
    for i=1:8
        text(i-0.3,data(i,2)+10,num2str(data(i,2),'%.1f'),'color','w','fontname','Times New Roman')
        text(i-0.3,data(i,3)+10,num2str(data(i,3),'%.1f'),'color','w','fontname','Times New Roman')
        text(i-0.3,data(i,3)+10,num2str(data(i,4),'%.1f'),'color','w','fontname','Times New Roman')
        text(i-0.3,data(i,3)+10,num2str(data(i,5),'%.1f'),'color','w','fontname','Times New Roman')
    end
    
    legend({'\fontname{times new roman}DTW','\fontname{times new roman}BiLSTM',...
        '\fontname{times new roman}GRU','\fontname{times new roman}Proposed'},...
        'Orientation','horizontal','Location','northeast')
    ylabel('\fontname{times noew roman}Time cost (¶Ãs)')
    % ylim([0 450])
    % xlabel('\fontname{times new roman}÷·±Í«©')
    
    
else
    figure(1);
    set(gcf,'position',[0,0,1280,560]);
    h=bar(data(:,2:5));
    set(h(1),'FaceColor',[0.2549 0.4117 0.8823]);
    set(h(2),'FaceColor',[0 0.3922 0]);
    set(h(3),'FaceColor',[1 0.647 0]);
    set(h(4),'FaceColor',[0.6902 0.1882 0.3764]);
    set(h,'edgecolor','none');
    legend({'\fontname{times new roman}DTW','\fontname{times new roman}BiLSTM',...
        '\fontname{times new roman}GRU','\fontname{times new roman}Proposed'},...
        'Orientation','horizontal','Location','northeast','edgecolor', [0.8,0.8,0.8])
    ylabel('\fontname{times new roman}Time cost (¶Ãs)')
    set(gca,'XTick',1:8)
    set(gca,'XTickLabel',{'cwv','ccwv','cwh','ccwh','up','down','left','right'})
    set(gca,'FontName','Times New Roman','FontSize',18,'LineWidth',0.5);    
    box off;
    
end


