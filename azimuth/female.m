%% ����MIT��HRTR���ݺͰ������ź����ɾ��з����Ե������źţ�0-360��
clear
clc
%����İ������ź�
fs = 16000;

inPutFilePath = 'E:\SPEECH\binauralCS\Source_Filter_based\FE2-MA1\orig1_lwwy2a_pbbv6n.wav';
inPutData = wavread(inPutFilePath);

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
    outPutFilePath = sprintf('E:\\SPEECH\\binauralCS\\FE2\\FE2_lwwy2a%03d.wav',azimuth);
    wavwrite(y,fs,outPutFilePath);
end