function [y1 y2] = name_for_trend(f)
%tt = num2str(t1);
global trendPanel
y1=uicontrol(trendPanel,'Style','text',...
            'String','00.00','backgroundcolor',[1 1 1], 'foregroundcolor',[1 0 0], 'Units', 'points',...
            'fontsize',11,'Position',[30 50 50 20],'visible','off');
        
y2 = get(y1,'Extent');