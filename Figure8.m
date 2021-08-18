% figure 8
addpath ../dataset

load cwv.mat;
figure(1);
set(gcf,'position',[0,0,1280,640]);

h11=subplot(3,5,1); plot(cwv{1,151},'LineWidth',1.0); axis on;
xlabel('Sample time / 5ms'); ylabel('Linear acceleration / \itG');
set(gca,'FontName','Times New Roman','FontSize',12);
box off;
legend1=legend('x','y','z'); set(legend1,'Position',[0.21 0.84 0.040 0.083]);
h12=subplot(3,5,2); plot(cwv{1,152},'LineWidth',1.0); axis off;
h13=subplot(3,5,3); plot(cwv{1,153},'LineWidth',1.0); axis off;
h14=subplot(3,5,4); plot(cwv{1,154},'LineWidth',1.0); axis off;
h15=subplot(3,5,5); plot(cwv{1,155},'LineWidth',1.0); axis off;
h21=subplot(3,5,6); plot(cwv{1,156},'LineWidth',1.0); axis off;
h22=subplot(3,5,7); plot(cwv{1,157},'LineWidth',1.0); axis off;
h23=subplot(3,5,8); plot(cwv{1,158},'LineWidth',1.0); axis off;
h24=subplot(3,5,9); plot(cwv{1,159},'LineWidth',1.0); axis off;
h25=subplot(3,5,10); plot(cwv{1,160},'LineWidth',1.0); axis off;
h31=subplot(3,5,11); plot(cwv{1,161},'LineWidth',1.0); axis off; 
h32=subplot(3,5,12); plot(cwv{1,162},'LineWidth',1.0); axis off;
h33=subplot(3,5,13); plot(cwv{1,163},'LineWidth',1.0); axis off;
h34=subplot(3,5,14); plot(cwv{1,164},'LineWidth',1.0); axis off;
h35=subplot(3,5,15); plot(cwv{1,165},'LineWidth',1.0); axis off;

set([h12,h13],'Xcolor','w','XTick',[]);

