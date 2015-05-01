% % % %����MIT  HRIR ���ݾ�����ɵ� ����������ITD��IID
clear all;
clc
fs = 44100;
frameSize = fs*0.06;%һ֡Ϊ60ms
L = frameSize*2;
Offset = frameSize;
frameShift = frameSize/3;%֡��Ϊ20ms
MaxLag = 44;
onesample=1000000/fs;

for azimuth =0:5:90
    
    inPutFilePath = sprintf('E:\\Document\\�������\\������\\data\\Speech\\��λ������\\WhiteNoise%03d.wav',azimuth);
    [y fs_read] = wavread(inPutFilePath);
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
        delay_index=Offset-MaxLag:Offset+MaxLag;
        delay_us=delay_index/fs*1000000;
        predxaixs=delay_us(1):1:delay_us(end);
        predcurve=spline(delay_us,G_new,predxaixs);
        [R_max,index] = max(predcurve);
        ITD(azimuth/5+1,n) = index - (MaxLag+1)*onesample;
        % IID(azimuth/5+1,n,:) =20*log10(abs(Pyy./Pxx));
        
    end
    
    azimuth
    
end

mean_ITD = mean(ITD,2);
%mean_ITD = round(mean_ITD/onesample);
save E:\\MatlabCode\\train\\ITD_GCC_441  mean_ITD

% a=size(IID);
% mean_IID=ones(a(1),a(3));
% mean_IID(:,:)= mean(IID,2);
% save  F:\\����\\�о�����\\2009����Դ��λ\\����\\program(�ܷƷ�)\\IID_GCC  mean_IID


% %===================================================
% %===================================================
% %===================================================

% % % % % %ֱ����MIT FULL HRIR ���ݹ���ITD��IID�������������ɵķ����Եİ������źŹ���ITD��IID
% clear all;
% clc
% fs = 44100;
% frameSize = fs*0.06;%һ֡Ϊ60ms
% L = frameSize*2;
% Offset = frameSize;
% frameShift = round(frameSize/2);% ֡��
% MaxLag = 44;
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
%     inPutFilePath = sprintf('E:\\Document\\�������\\������\\data\\Speech\\��λ������\\WhiteNoise%03d.wav',azimuth);
%     [y fs_original] = wavread(inPutFilePath);
%     x_L = y(:,1);
%     %�Ҷ���HRIR
%     x_R = y(:,2);
%     
%     %����GCC����ITD
%     Pxx = fft(x_L,L) ;
%     Pyy = fft(x_R,L) ;
%     Pxy = Pxx.*conj(Pyy);
%     
%     [G,t,R] = GCC('PHAT',Pxx,Pyy,Pxy,fs,L,L);
%     G_new = G(Offset-MaxLag:Offset+MaxLag );
%     [R_max,index] = max(G_new);
%     ITD(azimuth/5+1) = index - MaxLag-1;
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
% % for azimuth = 95:5:180
% %     %�����HRIR
% %     inPutFilePath = sprintf('F:\\����\\�о�����\\2009����Դ��λ\\����\\data\\MITFullHRIR\\elev0\\L0e%03da.wav',azimuth);
% %     x_L = wavread(inPutFilePath);
% %     %�Ҷ���HRIR
% %     inPutFilePath = sprintf('F:\\����\\�о�����\\2009����Դ��λ\\����\\data\\MITFullHRIR\\elev0\\R0e%03da.wav',azimuth);
% %     x_R = wavread(inPutFilePath);
% %     
% %     
% %     %����GCC����ITD
% %     Pxx = fft(x_L,L) ;
% %     Pyy = fft(x_R,L) ;
% %     Pxy =Pxx.*conj(Pyy).*FreqRange;
%     
%     [G,t,R] = GCC('PHAT',Pxx,Pyy,Pxy,fs,L,L);
%     G_new = G(Offset-MaxLag:Offset+MaxLag );
%     [R_max,index] = max(G_new);
%     ITD(azimuth/5+1) = index - MaxLag-1;
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
% save E:\\MatlabCode\\train\\ITD_HRIR  mean_ITD
% 
% mean_IID=IID';
% save  F:\\����\\�о�����\\2009����Դ��λ\\����\\program(�ܷƷ�)\\IID_HRIR mean_IID



% %==============================================================
% %�������ɵķ���������ļ������������λ��ITD��IID����
% %==============================================================
% %
% clc
% clear all;
% fs = 44100;
% frameDura = 60;% ֡��Ϊ60ms
% frameSize  = frameDura*fs/1000;%һ֡��������
% L = frameSize*2;
% Offset = frameSize;
% frameShift = round(frameSize/2);% ֡��
% MaxLag = 44;
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
% % ============== ��ȡ�����ļ�========================
% testfileindex = strvcat('\\female\\female','\\male\\male','\\music\\music');
% testfilenumber = 1;
% 
% % VAD��ʾ
% VADFilePath = strcat('F:\\����\\�о�����\\2009����Դ��λ\\����\\data\\������',testfileindex(testfilenumber,:),'_',num2str(frameDura),'_index.mat');
% load (VADFilePath);
% 
% %ǰ��λ��ITD��IID����
% for azimuth =0:5:90
%     %��ȡ����λ�������ź�
%     inPutFilePath = strcat('F:\\����\\�о�����\\2009����Դ��λ\\����\\data\\������',testfileindex(testfilenumber,:),'_',num2str(azimuth),'.wav');
%     [y fs] = wavread(inPutFilePath);
%     x_L = y(:,1);
%     x_R = y(:,2);
%     
%     x_L = PreProccess(x_L,frameSize,frameShift);
%     x_R = PreProccess(x_R,frameSize,frameShift);
%     
%     
%     frameAmount = size(x_L,2);
%     frameNumSound = 0;
%     
%     for n = 1:frameAmount
%         if vad(n) == 1
%             
%               frameNumSound = frameNumSound+1;
%             
%             %����GCC����ITD
%             Pxx = fft(x_L(:,n),L) ;
%             Pyy = fft(x_R(:,n),L) ;
%             Pxy = Pxx.*conj(Pyy);
%             
%             [G,t,R] = GCC('PHAT',Pxx,Pyy,Pxy,fs,L,L);
%             G_new = G(Offset-MaxLag:Offset+MaxLag );
%             [R_max,index] = max(G_new);
%             ITD(azimuth/5+1,frameNumSound) = index - MaxLag-1;
%             
%             %�����Ӵ�IID
%             for subnum = 1:NFreq
%                 index = subframe*(subnum-1)+1:subframe*subnum;
%                 IID(azimuth/5+1,frameNumSound,subnum) =10*log10(sum(abs(Pyy(index)).^2)./sum(abs(Pxx(index)).^2));
%             end
%             
%         else
%             continue
%         end
%         
%     end
%     azimuth
% end
% 
% %����λ��ITD��IID����
% for azimuth = 95:5:180
%     %��ȡ����λ�������ź�
%     inPutFilePath = strcat('F:\\����\\�о�����\\2009����Դ��λ\\����\\data\\������',testfileindex(testfilenumber,:),'_',num2str(azimuth),'.wav');
%     [y fs] = wavread(inPutFilePath);
%     x_L = y(:,1);
%     x_R = y(:,2);
%     
%     x_L = PreProccess(x_L,frameSize,frameShift);
%     x_R = PreProccess(x_R,frameSize,frameShift);
%     
%     
%     frameAmount = size(x_L,2);
%      frameNumSound = 0;
%     
%     for n = 1:frameAmount
%         if vad(n) == 1
%             
%             frameNumSound = frameNumSound+1;
%             
%             %����GCC����ITD
%             Pxx = fft(x_L(:,n),L) ;
%             Pyy = fft(x_R(:,n),L) ;
%             Pxy = Pxx.*conj(Pyy).*FreqRange;
%             
%             [G,t,R] = GCC('PHAT',Pxx,Pyy,Pxy,fs,L,L);
%             G_new = G(Offset-MaxLag:Offset+MaxLag );
%             [R_max,index] = max(G_new);
%             ITD(azimuth/5+1,frameNumSound) = index - MaxLag-1;
%             
%             %�����Ӵ�IID
%             for subnum = 1:NFreq
%                 index = subframe*(subnum-1)+1:subframe*subnum;
%                 IID(azimuth/5+1,frameNumSound,subnum) =10*log10(sum(abs(Pyy(index)).^2)./sum(abs(Pxx(index)).^2));
%             end
%             
%         else
%             continue
%         end
%     end
%     azimuth
% end
% 
% mean_ITD = mean(ITD,2);
% save F:\\����\\�о�����\\2009����Դ��λ\\����\\program(�ܷƷ�)\\ITD_speech  mean_ITD
% 
% 
% a=size(IID);
% mean_IID=ones(a(1),a(3));
% mean_IID(:,:)= mean(IID,2);
% save  F:\\����\\�о�����\\2009����Դ��λ\\����\\program(�ܷƷ�)\\IID_speech mean_IID
% 
% 
% 
% %        
% %===================================================
% %===================================================
% %===================================================
% 
% %����CIPIC��HRTF���ݼ�����
% clear all;
% clc
% fs = 44100;
% frameSize = fs*0.03;
% L = frameSize*2;
% Offset = frameSize;
% frameShift = frameSize/3;
% MaxLag = 44;
% 
% 
% A = [0:5:45 55 65 80 ];  LA = length(A);
% azimuth = [ A, 180-A(LA:-1:1)]; % Azimuths
% E = -45:(360/64):235;                  LE = length(E);  % Elevation
% 
% for azi_index = 15:length(azimuth)
%     
%     inPutFilePath = sprintf('F:\\����\\�о�����\\2009����Դ��λ\\����\\data\\Speech\\��λ������\\WhiteNoise%03d.wav',azimuth(azi_index));
%     [y fs] = wavread(inPutFilePath);
%     x_L = y(:,1);
%     x_R = y(:,2);
%     
%     x_L = PreProccess(x_L,frameSize,frameShift);
%     x_R = PreProccess(x_R,frameSize,frameShift);
%     
%            
%     frameAmount = size(x_L,2);
%     
%     for n = 1:frameAmount
%         
%         Pxx = fft(x_L(:,n),L) ;
%         Pyy = fft(x_R(:,n),L) ;
%         Pxy = Pxx.*conj(Pyy);
%       
% 
%                
% %        [G,t,R] = GCC('PHAT',Pxx,Pyy,Pxy,fs,L,L);  
%        [G,t,R] = GCC('unfiltered',Pxx,Pyy,Pxy,fs,L,L);
%         G_new = G(Offset-MaxLag:Offset+MaxLag );
%         [R_max,index] = max(G_new);
%         ITD(azi_index,n) = index - MaxLag-1;    
%         IID(azi_index,n,:) =20*log10(abs(Pyy./Pxx));
%               
%     end
% 
%     azimuth(azi_index)
%     
% end
% save ITD  ITD 
% save IID  IID
% 
% mean_ITD = mean(ITD,2);
% save F:\\����\\�о�����\\2009����Դ��λ\\����\\program(�ܷƷ�)\\ITD_GCC  mean_ITD 
% 
% a=size(IID);
% mean_IID=ones(a(1),a(3));
% mean_IID(:,:)= mean(IID,2);
% save  F:\\����\\�о�����\\2009����Դ��λ\\����\\program(�ܷƷ�)\\IID_GCC  mean_IID 