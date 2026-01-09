classdef valve
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        valvepos
        setpoint
        flowin % its the flow coming into valve
        flowout % going out from valve
        flowfinal % final flow into tank
        
    end
    
    methods
           
        function obj_valve =  manualcontrol(obj,temp)
%             obj.valvepos = temp;
%             obj.flowout = obj.valvepos*obj.flowin;
%             flow_out=obj.flowout;
            obj_valve = obj;
            obj_valve.valvepos = temp;
            obj_valve.flowout = obj_valve.valvepos*obj_valve.flowin;
            
            
            
        end
            
        function obj_valve = autocontrol(obj,err_array)
           obj_valve = obj;
            obj_valve.valvepos = obj.valvepos + (.18*err_array(end)) + ((.018)*sum(err_array(1:end)));
            if obj_valve.valvepos > 1
               obj_valve.valvepos = 1;
            end
            if obj_valve.valvepos<0
                obj_valve.valvepos  = 0;
            end
               obj_valve.flowout = obj_valve.valvepos * obj_valve.flowin;
            obj_valve.flowfinal = obj_valve.flowout;
%            obj_valve.flowout = obj_.flowout;
         
            
            
        end
            
                   
        
    end
    
end

