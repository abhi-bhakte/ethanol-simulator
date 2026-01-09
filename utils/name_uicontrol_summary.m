function [y1 y2] = name_uicontrol_summary(f)
%tt = num2str(t1);

y1=uicontrol(f,'Style','text',...
            'String','00.00.00','backgroundcolor',[0.5 0.5 0.5], 'foregroundcolor',[0 1 0], 'Units', 'points',...
            'fontsize',12,'Position',[30 50 50 20],'fontweight','bold');
        
y2 = get(y1,'Extent');
