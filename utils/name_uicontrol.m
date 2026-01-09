function [y1 y2] = name_uicontrol(f)
%tt = num2str(t1);

y1=uicontrol(f,'Style','text',...
            'String','14.58','backgroundcolor',[127 127 127]./255, 'foregroundcolor',[0 0 0],'Units', 'points',... % [41 50 49]./255 change background to this
            'fontsize',16,'Position',[30 50 50 20],'fontweight','bold');
        
        
        
        % 127 127 127 for new image gui
        % [41 50 49] for reflux added third aspen again final color
        
        
y2 = get(y1,'Extent');


