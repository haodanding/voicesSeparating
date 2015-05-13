
%MIAN_16K Summary of this function goes here
%   Detailed explanation goes here
clear all;
clc
fs = 16000;
frameSize = 512;%һ֡Ϊ60ms
Offset = frameSize;
frameShift = 128;%֡��Ϊ20ms
MaxLag = 44;
onesample = 1000000/fs;


for azimuth =0:5:90
    
    inPutFilePath = sprintf('E:\\Document\\�������\\������\\data\\Speech\\��λ������\\WhiteNoise%03d.wav',azimuth);
    [y, fs_original] = audioread(inPutFilePath);
    x_L = resample(y(:,1),16000,44100);
    x_R = resample(y(:,2),16000,44100);
%     x_L = y(:,1);
%     x_R = y(:,2);
    
    awin=hamming(frameSize);
    tf_L=tfanalysis(x_L,awin,frameShift,frameSize); % time-freq domain
    tf_R=tfanalysis(x_R,awin,frameShift,frameSize) ; % time-freq domain
    
    
    frameAmount = size(tf_L,2);
    
    for n = 1:frameAmount
        Pxx = tf_L(:,n);
        Pyy = tf_R(:,n);
        Pxx1 = fft(ifft(tf_L(:,n)),2*frameSize);
        Pyy1 = fft(ifft(tf_R(:,n)),2*frameSize);
        Pxy1 = Pxx1.*conj(Pyy1);
        
        
        [G,t,R] = GCC('PHAT',Pxx1,Pyy1,Pxy1,fs,2*frameSize,2*frameSize);
        delay_index=Offset-MaxLag:Offset+MaxLag;
        delay_us=delay_index/fs*1000000;
        G_new = G(delay_index);
        predxaxis=delay_us(1):1:delay_us(end);
        predcure=spline(delay_us,G_new,predxaxis);
        
%         cc1 = correlogram(G_new, -1000, 1000, 'power', 'cc', x_L(:,n)', x_R(:,n)', fs, round(fs/4), 0);   
%          cur_itd = ccgrampeak(cc1, 'largest', 0);
         [~,cur_itd]=max(predcure);
         ITD(azimuth/5+1,n) =cur_itd-(MaxLag+1)*onesample;    
        
         R21=(Pyy+eps)./(Pxx+eps);
         a=abs(R21);
         IID(azimuth/5+1,n,:) = a;
        
    end
    
    azimuth
    
end

mean_ITD = mean(ITD,2);
% mean_ITD = mean_ITD';
mean_ITD = [-1*mean_ITD(end:-1:2);mean_ITD]';

temp=size(IID);
mean_IID=ones(temp(1),temp(3));
mean_IID(:,:)=mean(IID,2);
mean_IID = mean_IID';
mean_IID = [1./mean_IID(:,end:-1:2),mean_IID];

save E:\\MatlabCode\\seperation\\shu\\trainData\\ITD_GCC_16k  mean_ITD
save E:\\MatlabCode\\seperation\\shu\\trainData\\IID_GCC_16k  mean_IID





% % % % % % %ֱ����MIT FULL HRIR ���ݹ���ITD��IID�������������ɵķ����Եİ������źŹ���ITD��IID
% % ��Ҫ��HRIR���н�����
% clear all;
% clc
% fs = 16000;
% frameSize = fs*0.06;%һ֡Ϊ60ms
% L = frameSize*2;
% Offset = frameSize;
% frameShift = round(frameSize/2);% ֡��
% MaxLag = 16;
% %���ں���ķ�λ�����õ�Ƶ���źŹ���ITD(f<8kHz)����Ϊ���ڸ�Ƶ�źŲ�����С��������ױ������ڵ�'
% LowF =round(1.5*L*1000/fs);
% FreqRange = zeros(L,1);
% FreqRange(1:LowF) = 1;
% FreqRange(L-LowF:L) = 1;
% 
% %����IIDʱ�������Ӵ�IID��ʽ��������ÿ��Ƶ�����IID
% %������Ӵ�����ѡ��Ϊ9
% NFreq = 9; % ÿ֡�е��Ӵ�����
% subframe = frameSize/NFreq;%ÿ���Ӵ���Ƶ����
% 
% 
% %ǰ��λ��ITD��IID����
% for azimuth = 0:5:90
%     %�����HRIR
%     inPutFilePath = sprintf('F:\\����\\�о�����\\2009����Դ��λ\\����\\data\\MITFullHRIR\\elev0\\L0e%03da.wav',azimuth);
%     x_L = wavread(inPutFilePath);
%     x_L = resample(x_L,fs,44100);
%     %�Ҷ���HRIR
%     inPutFilePath = sprintf('F:\\����\\�о�����\\2009����Դ��λ\\����\\data\\MITFullHRIR\\elev0\\R0e%03da.wav',azimuth);
%     x_R = wavread(inPutFilePath);
%     x_R = resample(x_R,fs,44100);
%     
%     %����GCC����ITD
%     Pxx = fft(x_L,L) ;
%     Pyy = fft(x_R,L) ;
%     Pxy = Pxx.*conj(Pyy);
%     
%     [G,t,R] = GCC('PHAT',Pxx,Pyy,Pxy,fs,L,L);
%     G_new = G(Offset-MaxLag:Offset+MaxLag );
%     cc1 = correlogram(G_new, -1000, 1000, 'power', 'cc', x_L', x_R', fs, round(fs/4), 0);   
%     cur_itd = ccgrampeak(cc1, 'largest', 0);
%       ITD(azimuth/5+1) =cur_itd;    
%     
%       %       [R_max,index] = max(G_new);
%       %     ITD(azimuth/5+1) = index - MaxLag-1;
%       %
%     IID(azimuth/5+1) =20*log10(sum(abs(Pyy).^2)./sum(abs(Pxx).^2));
%     
%     %     %�����Ӵ�IID
%     %     for subnum = 1:NFreq
%     %         index = subframe*(subnum-1)+1:subframe*subnum;
%     %         IID(azimuth/5+1,subnum) = 10*log10(sum(abs(Pyy(index)).^2)./sum(abs(Pxx(index)).^2));
%     %     end
%     
%     azimuth
% end
% 
% %����λ��ITD��IID����
% for azimuth = 95:5:180
%     %�����HRIR
%     inPutFilePath = sprintf('F:\\����\\�о�����\\2009����Դ��λ\\����\\data\\MITFullHRIR\\elev0\\L0e%03da.wav',azimuth);
%     x_L = wavread(inPutFilePath);
%      x_L = resample(x_L,fs,44100);
%     %�Ҷ���HRIR
%     inPutFilePath = sprintf('F:\\����\\�о�����\\2009����Դ��λ\\����\\data\\MITFullHRIR\\elev0\\R0e%03da.wav',azimuth);
%     x_R = wavread(inPutFilePath);
%      x_R = resample(x_R,fs,44100);
%     
%     
%     %����GCC����ITD
%     Pxx = fft(x_L,L) ;
%     Pyy = fft(x_R,L) ;
%     Pxy =Pxx.*conj(Pyy).*FreqRange;
%     
%     [G,t,R] = GCC('PHAT',Pxx,Pyy,Pxy,fs,L,L);
%     G_new = G(Offset-MaxLag:Offset+MaxLag );
%        cc1 = correlogram(G_new, -1000, 1000, 'power', 'cc', x_L',x_R', fs, round(fs/4), 0);   
%     cur_itd = ccgrampeak(cc1, 'largest', 0);
%       ITD(azimuth/5+1) =cur_itd;    
%       
% %     [R_max,index] = max(G_new);
% %     ITD(azimuth/5+1) = index - MaxLag-1;
%     
%      IID(azimuth/5+1) =20*log10(sum(abs(Pyy).^2)./sum(abs(Pxx).^2));
%     
%     %     %�����Ӵ�IID
%     %     for subnum = 1:NFreq
%     %         index = subframe*(subnum-1)+1:subframe*subnum;
%     %         IID(azimuth/5+1,subnum) = 10*log10(sum(abs(Pyy(index)).^2)./sum(abs(Pxx(index)).^2));
%     %     end
%     
%     azimuth
% end
% 
% mean_ITD = ITD';
% save F:\\����\\�о�����\\2009����Դ��λ\\����\\program(�ܷƷ�)\\ITD_HRIR  mean_ITD
% 
% mean_IID=IID';
% save  F:\\����\\�о�����\\2009����Դ��λ\\����\\program(�ܷƷ�)\\IID_HRIR mean_IID
% 
% 
% 
% 
% end

