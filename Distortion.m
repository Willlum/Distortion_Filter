 clear; close all;
  
 [x,fs] = audioread('cmaj.wav');
 A1a = audioplayer(x,fs);
 A1a.play;
 disp('Original...');
 pause(5);
    p=zeros(length(x),1);
    q=zeros(length(x),1);
    gain = 10;
    order = 2*gain; % Order should be around 2x bigger than desired gain
    for ii = 1 : length(x)-1
       sum = 1;
        if (x(ii) < 0) % q(x) = exp(sum*gain) - 1, Less than 0
             for i = order : -1 : 1
                sum = 1+(x(ii,1)*sum*gain)/i;
             end 
             q(ii,1) = -sum+1;
             p(ii,1) = exp(x(ii,1)*gain) - 1;
        else % q(x) = 1 - exp(-sum*gain), Greater than 0
             for i = order : -1 : 1
                sum = -1-((x(ii,1)*sum*gain)/i);
             end 
             q(ii,1) = -1-sum;
             p(ii,1) = 1- exp(-1*x(ii,1)*gain);
        end
    end 
    
 plot(q);
 hold on 
 plot(p);
 plot(x);
 A1a = audioplayer(q,fs);
 A1a.play;
 disp(' Approximated distortion...');
 pause(5)
 A1a = audioplayer(p,fs);
 A1a.play;
 disp('Unappoximated distortion...');

