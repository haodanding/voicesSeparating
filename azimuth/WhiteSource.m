
%% ����MIT��HRTR���ݺͰ������ź����ɾ��з����Ե������źţ�0-360��
clear
clc
%����İ������ź�
fs = 16000;

inPutFilePath = sprintf('E:\\SPEECH\\˫����Դ��λ\\wav\\white.wav');
inPutData = wavread(inPutFilePath,fs);

 %% ��compact���ݿ�
% for azimuth = 0:5:180
%     %����MIT Compact HRTF���ݣ�0��180�ȣ�����Ϊ0��
%     inPutFilePath = sprintf('E:\\SPEECH\\HRTF(MIT)\\compact\\elev0\\H0e%03da.dat',azimuth);
%     hrir = readrawc(inPutFilePath);
%     hrir_L = hrir(:,1);
%     hrir_R = hrir(:,2);
%     x_L = conv(inPutData,hrir_L);
%     x_R = conv(inPutData,hrir_R);
%     
%     %�����źŵķ�Χ[-1  1]
%     MaxValue = max(max(abs(x_L)),max(abs(x_R)));
%     MaxValue = MaxValue + MaxValue/1000;
%     x_L = x_L/MaxValue;
%     x_R = x_R/MaxValue;
% 
%     y = [x_L,x_R];
%     %�����Ե������ź�
%     outPutFilePath = sprintf('E:\\SPEECH\\binauralCS\\��λ������\\WhiteNoise%03d.wav',azimuth);
%     wavwrite(y,fs,outPutFilePath);
% end
%% ��full���ݿ�
for azimuth = 0:5:355
    %����MIT full HRTF���� ����Ϊ0��
    if azimuth == 0
        inPutFilePathL = sprintf('E:\\SPEECH\\HRTF(MIT)\\full\\elev0\\L0e000a.dat');
        inPutFilePathR = sprintf('E:\\SPEECH\\HRTF(MIT)\\full\\elev0\\L0e000a.dat');
    else
        inPutFilePathL = sprintf('E:\\SPEECH\\HRTF(MIT)\\full\\elev0\\L0e%03da.dat',azimuth);
        inPutFilePathR = sprintf('E:\\SPEECH\\HRTF(MIT)\\full\\elev0\\L0e%03da.dat',360-azimuth);
    end
    hrir_L = readraw(inPutFilePathL);
    hrir_R = readraw(inPutFilePathR);
    x_L = conv(inPutData,hrir_L);
    x_R = conv(inPutData,hrir_R);
    
    %�����źŵķ�Χ[-1  1]
    MaxValue = max(max(abs(x_L)),max(abs(x_R)));
    MaxValue = MaxValue + MaxValue/1000;
    x_L = x_L/MaxValue;
    x_R = x_R/MaxValue;

    y = [x_L,x_R];
    %�����Ե������ź�
    outPutFilePath = sprintf('E:\\SPEECH\\binauralCS\\��λ������16k\\WhiteNoise%03d.wav',azimuth);
    wavwrite(y,fs,outPutFilePath);
end