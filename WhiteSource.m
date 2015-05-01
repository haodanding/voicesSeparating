% ����MIT��HRTR���ݺͰ������ź����ɾ��з����Ե������źţ�0-180�ȣ���ǰ��������

%����İ������ź�
inPutFilePath = 'F:\����\�о�����\2009����Դ��λ\����\data\Speech\white.wav';
[inPutData fs] = wavread(inPutFilePath);

for azimuth = 0:5:180
    %����MIT Compact HRTF���ݣ�0��180��
    inPutFilePath = sprintf('F:\\����\\�о�����\\2009����Դ��λ\\����\\data\\MITHRIR\\elev0\\H0e%03da.dat',azimuth);
    hrir = readraw(inPutFilePath);
    hrir_L = hrir(:,1);
    hrir_R = hrir(:,2);
    x_L = conv(inPutData,hrir_L);
    x_R = conv(inPutData,hrir_R);
    
    %�����źŵķ�Χ[-1  1]
    MaxValue = max(max(abs(x_L)),max(abs(x_R)));
    MaxValue = MaxValue + MaxValue/1000;
    x_L = x_L/MaxValue;
    x_R = x_R/MaxValue;

    y = [x_L,x_R];
    %�����Ե������ź�
    outPutFilePath = sprintf('F:\\����\\�о�����\\2009����Դ��λ\\����\\data\\Speech\\��λ������\\WhiteNoise%03d.wav',azimuth);
    wavwrite(y,fs,outPutFilePath);
end