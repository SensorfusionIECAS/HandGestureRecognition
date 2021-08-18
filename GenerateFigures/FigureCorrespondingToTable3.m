% DTW: draw different template selecting methods

% royal blue 0.2549 0.4117 0.8823
% violet 0.9333 0.5098 0.9333
% violet red 0.8156 0.1254 0.5647
% dark green 0 0.3922 0
% maroon 0.6902 0.1882 0.3764

minIntra_accuracy=[52 63.5 54 45 99.5 38.5 63.5 58.5 59.3];
minIntramaxInter_accuracy=[34.5 71.5 37 68 16 38.5 20.5 10.5 37.0];
interDIntra_accuracy=[73 68.5 71 51 74 51.5 31.5 51 58.9];

figure(1);
set(gcf,'position',[0,0,1280,560]);

plot(minIntra_accuracy,'color',[0.2549 0.4117 0.8823],'Marker','*','MarkerSize',15,'LineWidth',2.0);
hold on;
plot(minIntramaxInter_accuracy,'color',[0.69 0.188 0.376],'Marker','o','MarkerSize',15,'LineWidth',2.0);
plot(interDIntra_accuracy,'color',[0 0.3922 0],'Marker','s','MarkerSize',15,'LineWidth',2.0);

axis([1 9 0 100]);
legend('min-intra','min-intra and max-inter','max-inter/intra');

box off;

set(gca,'XTick',1:9)
set(gca,'XTickLabel',{'cwv','ccwv','cwh','ccwh','up','down','left','right','average'})

ylabel('Accuracy(%)');
set(gca,'FontName','Times New Roman','FontSize',18,'LineWidth',0.5);

% 59.3
text(8.7,minIntra_accuracy(9),num2str(minIntra_accuracy(9),'%g%%'),...
    'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',18,...
    'FontName','Times New Roman')
% 37.0
text(8.7,minIntramaxInter_accuracy(9),num2str(minIntramaxInter_accuracy(9),'%g%%'),...
    'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',18,...
    'FontName','Times New Roman')
% 58.9
text(8.7,interDIntra_accuracy(9),num2str(interDIntra_accuracy(9),'%g%%'),...
    'HorizontalAlignment','center','VerticalAlignment','top','FontSize',18,...
    'FontName','Times New Roman')



