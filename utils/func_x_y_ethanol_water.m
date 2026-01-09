function y=func_x_y_ethanol_water(pe12,Eff,x)

% Eff is .7 which murphy coefficient for tray efficieny
len=length(x);
a=find(x<0);
x(a)=0;
a=find(x>0.894);
x(a)=0.894;

A=zeros(len,len);
ystar=polyval(pe12,x);

for i=1:len
    if (i==1)|(i==len)
        A(i,i)=1;
    else
        A(i,i)=1/Eff;
        A(i,i+1)=1-(1/Eff);   
     end
end

y = inv(A)*ystar;
y=y';

a=find(y<0);
y(a)=0;
a=find(y>0.894);
y(a)=0.894;