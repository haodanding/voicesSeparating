function [ tf_L_seped,tf_R_seped,mono ] = sepOnce( tf_L,tf_R,fs )
%source location detect and sound sepration
%   input:
%         tf_L: TF units after window and segmentation of left channel
%         tf_R: TF units after window and segmentation of right channel
%   output:
%         tf_L_seped: redistributed left TF units
%         tf_R_seped: redistributed right TF units

%   info: Jiaming.Shu 2015.4.29
%%
%1.�������������
frameSize = size(tf_L,1);
frameAmount = size(tf_L,2);
audioNum = size(tf_L,3);
Offset = frameSize/2;
% frameShift = 128;
MaxLag = 44;
onesample = 1000000/fs;
%%
%2.����ÿ֡��ITD
ITD = zeros(1,frameAmount,audioNum);
for audioIter = 1:audioNum
    for n = 1:frameAmount

        Pxx = tf_L(:,n,audioIter);
        Pyy = tf_R(:,n,audioIter);
        Pxy = Pxx.*conj(Pyy);

        [G,~,~] = GCC('PHAT',Pxx,Pyy,Pxy,fs,frameSize,frameSize);
        delay_index=Offset-MaxLag:Offset+MaxLag;
        delay_us=delay_index/fs*1000000;
        G_new = G(delay_index);
        predxaxis=delay_us(1):1:delay_us(end);
        try
            predcure=spline(delay_us,G_new,predxaxis);
            [~,cur_itd]=max(predcure);
            ITD(1,n,audioIter) = cur_itd-(MaxLag+1)*onesample;
        catch
            ITD(1,n,audioIter) = NaN;
        end
    end
end
%%
%3.ͳ��ITD,��λ��Դ
%3.0����ITD
ITD = reshape(ITD,1,frameAmount*audioNum);
ITD(isnan(ITD))=[]; %ɾ��NaN
%3.1����һ��ITD�����һ����Դ
source_list = cell(1);
newSource = Source(1,ITD(1));
source_list{1,1} = newSource;
%3.2������ֵ������ITD����������Դ���½���Դ
for ITDiter = 1:length(ITD)
    flag = 0;
    for i = 1:length(source_list)
        if(abs(ITD(ITDiter)-source_list{1,i}.getMean)<25)        %��ֵ1���涨���ٷ�Χ�ڵ�ITD����һ����Դ��
            source_list{1,i} = source_list{1,i}.Add(ITDiter,ITD(ITDiter));
            flag = 1;
            break;
        end
    end
    if(flag == 0)
        newSource = Source(ITDiter,ITD(ITDiter));
        newList = cell(1);
        newList{1,1} = newSource;
        source_list = [source_list, newList];
    end
end
%3.3ͳ�ƹ�������Դ
sourceCount = zeros(1,length(source_list));
sourceMean = zeros(1,length(source_list));
for n = 1:length(source_list)
    sourceCount(1,n) = source_list{1,n}.getNum;
    sourceMean(1,n) = source_list{1,n}.getMean;
end
%3.4�ų�Ұ����ɵļ���Դ
sourceMean1 = sourceMean(sourceCount>frameAmount*0.1);                     %��ֵ2:�涨����Ƶ�����µ���������Դ
%3.5��ѵ�����ݶԱȣ�ȷ����Դλ��
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
%4.��Դ���� 
% mask = zeros(length(sourceITD),frameAmount);
% for n = 1:frameAmount
%     [~,belong] = min(abs(ITD(n)*ones(1,length(sourceITD))-sourceITD));
%     mask(belong,n) = 1;
% end
%4.1����ÿ��Ƶ���ITD
% freq=[(0:frameSize/2-1) (-frameSize/2:-1)]*(2*pi/(frameSize));
freq=(0:frameSize-1)*(2*pi/(frameSize));
fmat=freq(ones(size(tf_L,2),1),:)';
% R21=(tf_L+eps)./(tf_R+eps); 
% delta=-imag(log(R21))./fmat;
% delta(1,:) = zeros(1,size(delta,2)); %ֱ����������λ��Ϊ0
% delta = onesample*delta; %ת����us
%4.2����ÿ��Ƶ�������
load('./trainData/IID_GCC_16k.mat');
mask = zeros(frameSize,frameAmount,sourceNum);%���һά������Դ���
% mask1 = zeros(frameSize,frameAmount,sourceNum);
dis_mat = zeros(frameSize,frameAmount,sourceNum);
% dis_mat1 = zeros(frameSize,frameAmount,sourceNum);
% for n = 1:frameAmount
%     for i = 1:frameSize
%         [~,belong] = min(abs(delta(i,n)*ones(1,length(sourceITD))-sourceITD));
%         mask(i,n,belong) = 1;
%     end
% end
%�����뿪��Ƶ���������
tf_L = sum(tf_L,3);
tf_R = sum(tf_R,3);

% for n = 1:frameAmount
%     for i = 1:frameSize
%         distance = zeros(1,sourceNum);
%         for j = 1:sourceNum
% %             distance(1,j) = (abs(mean_IID(i,sourceIndex(j))*exp(-1j*2*pi/frameSize*i*sourceITD(j)/onesample)*tf_L(i,n)-tf_R(i,n)))^2....
% %             /(1+(mean_IID(i,sourceIndex(j)))^2);
% %             distance(1,j) = (abs(mean_IID(i,sourceIndex(j))*tf_L(i,n)-exp(-1j*2*pi/frameSize*i*sourceITD(j)/onesample)*tf_R(i,n)))^2....
% %             /(1+(mean_IID(i,sourceIndex(j)))^2);
%             distance(1,j) = (abs(mean_IID(i,sourceIndex(j))*tf_L(i,n)-exp(-1j*2*pi/frameSize*(i-1)*sourceITD(j)/onesample)*tf_R(i,n)))^2....
%             /(1+(mean_IID(i,sourceIndex(j)))^2);
% %             dis_mat1(i,n,j)=distance(1,j);
%         end
%         [~,belong] = min(distance);
%         mask(i,n,belong) = 1;
%     end 
% end
%��������Դ���ݴ��������������ӦƵ��֮��ľ���
for sourceIter = 1:sourceNum
    IID_mat = repmat(mean_IID(:,sourceIndex(sourceIter)),1,frameAmount);
    dis_mat(:,:,sourceIter) = ((abs(IID_mat.*tf_L-exp(-1j*sourceITD(sourceIter)/onesample.*fmat).*tf_R)).^2)./(ones(frameSize,frameAmount)+IID_mat.^2);
end
%����̾���ԭ�����mask
for i = 1:frameSize %����0~pi֮���mask
    for j = 1:frameAmount
        [~,belong] = min(dis_mat(i,j,:));
        mask(i,j,belong) = 1;
    end
end
% mask(frameSize/2+1:frameSize,:,:) = mask(1:frameSize/2,:,:); %��һ���mask��ǰһ��Գ�
%4.3�����������Ƶ��
tf_L_seped = zeros(size(mask));
tf_R_seped = zeros(size(mask));
mono = zeros(size(mask));
for n = 1:size(mask,3)
    tf_L_seped(:,:,n) = tf_L .* mask(:,:,n);
    tf_R_seped(:,:,n) = tf_R .* mask(:,:,n);
    a_mat = repmat(mean_IID(:,sourceIndex(n)),1,frameAmount);
    mono(:,:,n) = (tf_L_seped(:,:,n).*exp(1j*sourceITD(n)/onesample.*fmat) + a_mat.*tf_R_seped(:,:,n))./(ones(frameSize,frameAmount)+a_mat.^2);
end

end
