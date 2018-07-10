clear all;  
[x,Fs] = audioread('speech.wav');  
d = 0.15;% 0.15s delay  
a = 1.0; % alpha echo strength  
D = d*Fs;  %delay in time
Fn = Fs/2;

echo = zeros(size(x));  
echo(1:D) = x(1:D);  
for i=D+1:length(x)  
  echo(i) = a*x(i-D) + x(i) ;  
end  


noise = echo + randn(size(echo)) * (1/200);
b = fir1(46,[100/Fn 700/Fn]);
y = filter(b,1,noise); % filter signal

%y = y(:,1);
%dt = 1/Fs;
%t = 0:dt:(length(noise)*dt)-dt;
%plot(t,echo); xlabel('Seconds'); ylabel('Amplitude');

sound(y,Fs);
audiowrite('modified.wav',y,Fs);