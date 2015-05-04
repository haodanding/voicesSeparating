clear;clc;
addpath('E:\SPEECH\binauralCS\code\azimuth');
fs = 16000;
soursenum=1;
% azimuth=[5,40,330,280];
azimuth=0:5:355;
inPutFilePath ={'E:\SPEECH\binauralCS\code\azimuth\s1.wav',...
                'E:\SPEECH\binauralCS\code\azimuth\s1.wav',...
                'E:\SPEECH\binauralCS\code\azimuth\s2.wav',...
                'E:\SPEECH\binauralCS\code\azimuth\s9.wav'};
            
for i=1:72

% ��full���ݿ�
out=[];filename='';

    clear voice y x_L x_R x
    if azimuth(i) == 0
        inPutFilePathL = sprintf('E:\\SPEECH\\HRTF(MIT)\\full\\elev0\\L0e000a.dat');
        inPutFilePathR = sprintf('E:\\SPEECH\\HRTF(MIT)\\full\\elev0\\L0e000a.dat');
    else
        inPutFilePathL = sprintf('E:\\SPEECH\\HRTF(MIT)\\full\\elev0\\L0e%03da.dat',azimuth(i));
        inPutFilePathR = sprintf('E:\\SPEECH\\HRTF(MIT)\\full\\elev0\\L0e%03da.dat',360-azimuth(i));
    end
    hrir_L = readraw(inPutFilePathL);
    hrir_R = readraw(inPutFilePathR);
    
    x=wavread(char(inPutFilePath(1)));
    x_L = conv(x,hrir_L);
    x_R = conv(x,hrir_R);

    %�����źŵķ�Χ[-1  1]
    MaxValue = max(max(abs(x_L)),max(abs(x_R)));
    MaxValue = MaxValue + MaxValue/1000;
    x_L = x_L/MaxValue;
    x_R = x_R/MaxValue;
    
    y = [x_L,x_R];
    
    len=max(size(out,1),size(y,1));
    out=[out;zeros(len-size(out,1),2)];
    y=[y;zeros(len-size(y,1),2)];
    out=out+y;
    filename=[filename,'_',num2str(azimuth(i))];


wavwrite(out,fs,['E:\SPEECH\binauralCS\��λs1_16k\s1',filename]);

end


% %��������Ƕȵ���������һ�µ�ԭʼ��������
% clear;clc;
% addpath('E:\SPEECH\binauralCS\code\azimuth');
% fs = 16000;
% soursenum=1;
% inPutFilePath ={'E:\SPEECH\binauralCS\code\azimuth\s2.wav'};
% 
% % ��full���ݿ�
% out=[];filename='s2';
% for i=1:soursenum
%     clear voice y x_L x_R x
%     inPutFilePathL = sprintf('E:\\SPEECH\\HRTF(MIT)\\full\\elev0\\L0e000a.dat');
%     inPutFilePathR = sprintf('E:\\SPEECH\\HRTF(MIT)\\full\\elev0\\L0e000a.dat');
%     hrir_L = readraw(inPutFilePathL);
%     hrir_R = readraw(inPutFilePathR);
%     
%     x=wavread(char(inPutFilePath(i)));
%     x_L = conv(x,hrir_L);
%     %�����źŵķ�Χ[-1  1]
%     MaxValue = max(abs(x_L));
%     MaxValue = MaxValue + MaxValue/1000;
%     x_L = x_L/MaxValue;
%     y = x_L;
%     filename=[filename,'_',num2str(0)];
% end
% wavwrite(y,fs,['E:\SPEECH\binauralCS\code\selectedDUET\',filename]);