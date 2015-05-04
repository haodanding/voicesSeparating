%% ����MIT��HRTR���ݺͰ������ź����ɾ��з����Ե������źţ�0-360��
clear
clc
%����İ������ź�
fs = 44100;

inPutData = wavread('E:\SPEECH\binauralCS\code\azimuth\wei.wav');
inPutData=inPutData(2000:8000,1);
y0=[];
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
    y0=[y0;y];
end
wavwrite(y0,fs,'E:\SPEECH\binauralCS\code\azimuth\123.wav');