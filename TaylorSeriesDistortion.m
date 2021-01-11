clear; close all;
 
 fs = 44000; % Sampling frequency (samples per second) 
 dt = 1/fs; % seconds per sample 
 StopTime = 1; % seconds 
 t = (0:dt:StopTime)'; % seconds 
 F = 10; % Sine wave frequency (hertz) 
 data = sin(2*pi*F*t);
 %  figure(1)
 %  plot(t,data)
 %%For one cycle get time period
 T = 4/F ;
 % time step for one time period 
 tt = 0:dt:T+dt ;
 d = sin(2*pi*F*tt) ;
    
    p=zeros(length(d),1);
    q=zeros(length(d),1);
    gain = 6;
    order = 100;
    for ii = 1 : length(d)-1
       sum = 1;
        if (d(ii) < 0) % exp(sum*gain) - 1
             for i = order : -1 : 1
                sum = 1+(d(ii)*sum*gain)/i;
             end 
             q(ii,1) = sum-1;
             p(ii,1) = exp(d(ii)*gain) - 1;
        else % 1 - exp(-sum*gain), Greater than 0
            sign = 1;
             for i = order : -1 : 1
                sum = 1-((d(ii)*sum*gain)/i);
             end 
             q(ii,1) = 1 -sum;
             p(ii,1) = 1- exp(-1*d(ii)*gain);
        end
    end 
    
    figure(2)
    hold on
    plot(tt,q) % Approximated distortion
    plot(tt,d) % Initial waveform
   % plot(tt,p) % distortion using exp()
    
