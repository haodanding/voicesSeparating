clc;clear;close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%1.��ȡ�������
% inPutFilePath = 'E:\\MatlabCode\\seperation\\shu\\female_10_30_60.wav';
inPutFilePath = 'E:\\MatlabCode\\seperation\\shu\\music_male_10_50.wav';
% inPutFilePath = 'E:\\MatlabCode\\seperation\\shu\\music_female_10_50.wav';
[y, fs_original] = audioread(inPutFilePath);
x_L = y(:,1);
x_R = y(:,2);
%%
%2.Ԥ����
%2.1��������
fs = 16000;
%frameSize = fs*0.06;%һ֡Ϊ60ms
frameSize = 512;
Offset = frameSize/2;
frameShift = 128;
MaxLag = 44;
onesample = 1000000/fs;
%2.2�ز���
x_L = resample(x_L,fs,fs_original);
x_R = resample(x_R,fs,fs_original);
%2.3��֡�Ӵ�,ʱƵ����
awin=hamming(frameSize);
tf_L=tfanalysis(x_L,awin,frameShift,frameSize); % time-freq domain
tf_R=tfanalysis(x_R,awin,frameShift,frameSize) ; % time-freq domain
%tf_L(1,:)=[];tf_R(1,:)=[]; % remove dc component from mixtures
%%
%3.����ÿ֡��ITD
frameAmount = size(tf_L,2);
ITD = zeros(1,frameAmount);
for n = 1:frameAmount

    Pxx = tf_L(:,n);
    Pyy = tf_R(:,n);
    Pxy = Pxx.*conj(Pyy);
    
    [G,t,R] = GCC('PHAT',Pxx,Pyy,Pxy,fs,frameSize,frameSize);
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
        if(abs(ITD(n)-source_list{1,i}.getMean)<25)
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
sourceMean1 = sourceMean(sourceCount>frameAmount*0.1);
%4.5��ѵ�����ݶԱȣ�ȷ����Դλ��
load('./trainData/ITD_GCC_16k.mat');
sourceIndex = zeros(1,length(sourceMean1));
sourceITD = zeros(1,length(sourceMean1));
for n = 1:length(sourceITD)
    [~,minIndex] = min(abs(sourceMean1(1,n)*ones(1,length(mean_ITD))-mean_ITD));
    sourceIndex(1,n) = minIndex;
    sourceITD(1,n) = mean_ITD(minIndex);
end
sourceNum = length(sourceITD);
%%
%5.��Դ���� 
% mask = zeros(length(sourceITD),frameAmount);
% for n = 1:frameAmount
%     [~,belong] = min(abs(ITD(n)*ones(1,length(sourceITD))-sourceITD));
%     mask(belong,n) = 1;
% end
%5.1����ÿ��Ƶ���ITD
%freq=[(0:frameSize/2) ((-frameSize/2)+1:-1)]*(2*pi/(frameSize));
freq=(0:frameSize-1)*(2*pi/(frameSize));
fmat=freq(ones(size(tf_L,2),1),:)';
R21=(tf_L+eps)./(tf_R+eps); 
delta=-imag(log(R21))./fmat;
delta(1,:) = zeros(1,size(delta,2)); %ֱ����������λ��Ϊ0
delta = onesample*delta; %ת����us
%5.2����ÿ��Ƶ�������
load('./trainData/IID_GCC_16k.mat');
mask = zeros(frameSize,frameAmount,sourceNum);%���һά������Դ���

% for n = 1:frameAmount
%     for i = 1:frameSize
%         [~,belong] = min(abs(delta(i,n)*ones(1,length(sourceITD))-sourceITD));
%         mask(i,n,belong) = 1;
%     end
% end

for n = 1:frameAmount
    for i = 1:frameSize
        distance = zeros(1,sourceNum);
        for j = 1:sourceNum
%             distance(1,j) = (abs(mean_IID(i,sourceIndex(j))*exp(-1j*2*pi/frameSize*i*sourceITD(j)/onesample)*tf_L(i,n)-tf_R(i,n)))^2....
%             /(1+(mean_IID(i,sourceIndex(j)))^2);
            distance(1,j) = (abs(mean_IID(i,sourceIndex(j))*tf_L(i,n)-exp(-1j*2*pi/frameSize*i*sourceITD(j)/onesample)*tf_R(i,n)))^2....
            /(1+(mean_IID(i,sourceIndex(j)))^2);
        end
        [~,belong] = min(distance);
        mask(i,n,belong) = 1;
    end 
end


%5.3�����������Ƶ��
tf_L_seped = zeros(size(mask));
tf_R_seped = zeros(size(mask));
mono = zeros(size(mask));
for n = 1:size(mask,3)
    tf_L_seped(:,:,n) = tf_L .* mask(:,:,n);
    tf_R_seped(:,:,n) = tf_R .* mask(:,:,n);
    a_mat = repmat(mean_IID(:,sourceIndex(n)),1,frameAmount);
    mono(:,:,n) = (tf_L_seped(:,:,n).*(exp(1j*2*pi/frameSize*sourceITD(n)/onesample)*fmat) + a_mat.*tf_R_seped(:,:,n))./(ones(frameSize,frameAmount)+a_mat.^2);
end
%5.4ת���ص�ʱ��
output = cell(1,sourceNum);
for n = 1:sourceNum
    output{n}=tfsynthesis(mono(:,:,n),sqrt(2)*awin/(2*frameSize),frameShift);
end




    