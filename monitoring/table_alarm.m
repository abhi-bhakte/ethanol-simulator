function hh= table_alarm(axes_img)
x = [0,235];
x1 = [0,235];
c_co = [127 127 127]./255;

hh= plot(axes_img, x1,[0 0],'k'); hold on
hh= plot(axes_img, x,[5 5],'Color',c_co); hold on
hh= plot(axes_img, x,[10 10],'Color',c_co); hold on
hh= plot(axes_img, x,[15 15],'Color',c_co); hold on
hh= plot(axes_img, x,[20 20],'Color',c_co); hold on
hh= plot(axes_img, x,[25 25],'Color',c_co); hold on
hh= plot(axes_img, x,[30 30],'Color',c_co); hold on
hh= plot(axes_img, x,[35 35],'Color',c_co); hold on
hh= plot(axes_img, x,[40 40],'Color',c_co); hold on

hh= plot(axes_img, x1,[45 45],'Color',c_co); hold on
hh= plot(axes_img, x1,[50 50],'Color',c_co); hold on
hh= plot(axes_img, x1,[55 55],'Color',c_co); hold on
hh= plot(axes_img, x, [60 60],'Color',c_co); hold on
hh= plot(axes_img, x, [65 65],'Color',c_co); hold on
hh= plot(axes_img, x1,[70 70],'k'); hold on
hh= plot(axes_img, x1,[75 75],'k'); hold on
hh= plot(axes_img, x1,[80 80],'k'); hold on




axis([0 235 0 80]);
set(gca,'XTick',[0 60 120 180 235],'YTick',[0:5:75 80]);
set(gca,'YTickLabel',{'';'';'';'';'';'';'';'';'';'';'';''},'XTickLabel',{'';'';'';'';'';''});
set(gca,'XDir','reverse');
hold on
plot(axes_img, [235  235],[0 80],'k'); hold on;

% plot(axes_img, [135  135],[0 45],'Color',c_co*ones(1,3)); hold on;
% plot(axes_img, [135  135],[45 50],'k'); hold on; 0 60
% 120 180 240
% plot(axes_img, [135  135],[50 55],'Color',[1 1 1]); hold on;

% plot(axes_img, [190  190],[0 70],'Color',c_co*ones(1,3)); hold on;
% plot(axes_img, [190  190],[70 75],'k'); hold on;
% plot(axes_img, [190  190],[75 80],'Color',[1 1 1]); hold on;

plot(axes_img, [180 180],[0 70],'Color',c_co); hold on;
plot(axes_img, [180 180],[70 75],'k'); hold on;
% plot(axes_img, [180 180],[75 80],'Color',[1 1 1]); hold on;

plot(axes_img, [120 120],[0 70],'Color',c_co); hold on;
plot(axes_img, [120 120],[70 75],'k'); hold on;
% plot(axes_img, [120 120],[75 80],'Color',[1 1 1]); hold on;

plot(axes_img, [60 60],[0 70],'Color',c_co); hold on;
plot(axes_img, [60 60],[70 75],'k'); hold on;
% plot(axes_img, [60 60],[75 80],'Color',[1 1 1]); hold on;

plot(axes_img, [0 0],[0 80],'k'); hold on;

% plot(axes_img, [120 120],[0 25],'Color',c_co*ones(1,3)); hold on;
% plot(axes_img, [100 100],[0 25],'Color',c_co*ones(1,3)); hold on;
% 
% plot(axes_img, [80 80],[0 25], 'Color',c_co*ones(1,3)); hold on;
% 
% plot(axes_img, [60 60],[0 25], 'Color',[0.4 0.4 0.4],'Linewidth',1.7); hold on;
% 
% for i = 10:10:50
%     plot(axes_img, [i i],[0 25], 'Color',c_co*ones(1,3)); hold on;
% end

% for i = 8:8:40
%     plot(axes_img, [i i],[0 25], 'Color',c_co*ones(1,3)); hold on;
% end
%plot(axes_img, [60 60],[0 25], 'Color',c_co*ones(1,3)); hold on;

%plot(axes_img, [40 40],[0 25], 'Color',c_co*ones(1,3)); hold on;

%plot(axes_img, [20 20],[0 25], 'Color',c_co*ones(1,3)); hold on;

%plot(axes_img, [40 40],[0 25], 'Color',c_co*ones(1,3)); hold on;

% plot(axes_img, [-70 -70],[0 28], 'Color',[0.2 0.2 0.2]); hold on;
% 
% plot(axes_img, [0 0],[0 28],'k','Linewidth',2); hold on;
% 
% %plot(axes_img, [80 80],[0 25],'Color',c_co*ones(1,3)); hold on;
% 
% cc=[-60:10:-10];
% 
% for i= 1:length(cc)
%     plot(axes_img, [cc(i) cc(i)],[0 25], 'Color',c_co*ones(1,3)); hold on;
%end

plot(axes_img,x,[0 0],'k'); hold off
end


% for i =10:10:50
% hh= plot(x,[i i],'Color',[0.75 0.75 0.75]); hold on
% end
% plot(
% box(gca,'Color',[0.75 0.75 0.75])
