function [ output_args ] = main_GMM( input_args )
%  MAIN_GMM Summary of this function goes here
%   Detailed explanation goes here
% % % %����MIT  FULL HRIR ���ݾ�����ɵ� ����������ITD��IID
clear all;
clc
fs = 44100;
frameSize = fs*0.06;%һ֡Ϊ60ms
L = frameSize*2;
Offset = frameSize;
frameShift = frameSize/2;%֡��Ϊ30ms
MaxLag = 44;


for azimuth =0:5:180
    
    inPutFilePath = sprintf('F:\\����\\�о�����\\2009����Դ��λ\\����\\data\\Speech\\��λ������\\WhiteNoise%03d.wav',azimuth);
    [y fs] = wavread(inPutFilePath);
    x_L = y(:,1);
    x_R = y(:,2);
    
    x_L = PreProccess(x_L,frameSize,frameShift);
    x_R = PreProccess(x_R,frameSize,frameShift);
    
    
    frameAmount = size(x_L,2);
    
    for n = 1:frameAmount
        
        Pxx = fft(x_L(:,n),L) ;
        Pyy = fft(x_R(:,n),L) ;
        Pxy = Pxx.*conj(Pyy);
        
        
        [G,t,R] = GCC('PHAT',Pxx,Pyy,Pxy,fs,L,L);
        G_new = G(Offset-MaxLag:Offset+MaxLag );
        [R_max,index] = max(G_new);
        ITD(azimuth/5+1,n)  = index - MaxLag-1;
        IID(azimuth/5+1,n) =20*log10(sum(abs(Pyy).^2)/sum(abs(Pxx).^2));
        
    end
    
    
    azimuth
    
end


mean_ITD = mean(ITD,2);
mean_IID = mean(IID,2);
var_ITD = var(ITD,0,2);
var_IID = var(IID,0,2)
save F:\\����\\�о�����\\2009����Դ��λ\\����\\program(�ܷƷ�)\\ITD_IID  mean_ITD  mean_IID  var_ITD  var_IID

end

