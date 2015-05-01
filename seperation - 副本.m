clc;clear;close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%1.��ȡ�������
inPutFilePath = 'E:\\MatlabCode\\seperation\\shu\\hybrid_10_30_60.wav';
[y, fs_original] = audioread(inPutFilePath);
x_L = y(:,1);
x_R = y(:,2);
%%
%2.Ԥ����
%2.1��������
fs = 16000;
frameSize = fs*0.06;%һ֡Ϊ60ms
L = frameSize*2;
Offset = frameSize;
frameShift = frameSize/3;%֡��Ϊ20ms
MaxLag = trameSize/10;
onesample = 1000000/fs;
%2.2�ز���
x_L = resample(x_L,fs,fs_original);
x_R = resample(x_R,fs,fs_original);
%2.3��֡�Ӵ�,ʱƵ����
x_L = PreProccess(x_L,frameSize,frameShift);
x_R = PreProccess(x_R,frameSize,frameShift);
%%
%3.����ÿ֡��ITD
frameAmount = size(x_L,2);
ITD = zeros(1,frameAmount);
for n = 1:frameAmount

    Pxx = fft(x_L(:,n),L) ;
    Pyy = fft(x_R(:,n),L) ;
    Pxy = Pxx.*conj(Pyy);
    
    [G,t,R] = GCC('PHAT',Pxx,Pyy,Pxy,fs,L,L);
    delay_index=Offset-MaxLag:Offset+MaxLag;
    delay_us=delay_index/fs*1000000;
    G_new = G(delay_index);
    predxaxis=delay_us(1):1:delay_us(end);
    predcure=spline(delay_us,G_new,predxaxis);
    [~,cur_itd]=max(predcure);
    
    ITD(n) = cur_itd-(MaxLag+1)*onesample;
end
%%
%4.ͳ��ITD,��λ��Դ
%4.1����һ��ITD�����һ����Դ
source_list = cell(1);
newSource = Source(1,ITD(1));
source_list{1,1} = newSource;
%4.2������ֵ������ITD����������Դ���½���Դ
for n = 2:frameAmount
    flag = 0;
    for i = 1:length(source_list)
        if(abs(ITD(n)-source_list{1,i}.getMean)<30)
            source_list{1,i} = source_list{1,i}.Add(n,ITD(n));
            flag = 1;
            break;
        end
    end
    if(flag == 0)
        newSource = Source(n,ITD(n));
        newList = cell(1);
        newList{1,1} = newSource;
        source_list = [source_list, newList];
    end
end
%4.3ͳ�ƹ�������Դ
sourceCount = zeros(1,length(source_list));
sourceMean = zeros(1,length(source_list));
for n = 1:length(source_list)
    sourceCount(1,n) = source_list{1,n}.getNum;
    sourceMean(1,n) = source_list{1,n}.getMean;
end
%4.4�ų�Ұ����ɵļ���Դ
sourceMean1 = sourceMean(sourceCount>frameAmount*0.05);
%4.5��ѵ�����ݶԱȣ�ȷ����Դλ��
load('./trainData/ITD_GCC_16k.mat');
sourceITD = zeros(1,length(sourceMean1));
for n = 1:length(sourceITD)
    [~,minIndex] = min(abs(sourceMean1(1,n)*ones(1,length(mean_ITD))-mean_ITD));
    sourceITD(1,n) = mean_ITD(minIndex);
end
%%
%5.��Դ���� 
mask = zeros(length(sourcITD),frameAmount);
for n = 1:frameAmount
    [~,belong] = min(abs(ITD(n)*ones(1,length(sourcITD))-sourceITD));
    mask(belong,n) = 1;
end



    