function [ tf_L_seped,tf_R_seped,mono,azimuthout ] = sepOnce( tf_L,tf_R,fs,sourceNum,dnnModel )
%source location detect and sound sepration
%   input:
%         tf_L: TF units after window and segmentation of left channel
%         tf_R: TF units after window and segmentation of right channel
%   output:
%         tf_L_seped: redistributed left TF units
%         tf_R_seped: redistributed right TF units

%   info: Jiaming.Shu 2015.4.29
azimuth = -90:5:90;
load('./trainData/ITD_GCC_16k.mat');
load('./trainData/IID_GCC_16k.mat');
load(dnnModel);
%%
%1.�������������
frameSize = size(tf_L,1);
frameAmount = size(tf_L,2);
audioNum = size(tf_L,3);
frameShift = 256;
onesample = 1000000/fs;
degree = 0:10:90;
%%
%2.����ÿ֡������
for audioIter = 1:audioNum
    vad = VAD(tfsynthesis(tf_R(:,:,audioIter),sqrt(2)*hamming(frameSize)/(2*frameSize),frameShift),0.3);
    [IID, correlation] = featureExtract(tf_L(:,:,audioIter),tf_R(:,:,audioIter),vad);
    correlation = bsxfun(@plus, correlation, 1);
    correlation = bsxfun(@rdivide, correlation, 2);
    feature_x(:,:,audioIter) = [IID, correlation];
end

%%
%��Դ�Ĺ��Ʒ�Ϊ���ࡣA:��һ�η��롣B:�������������¹�����Դλ��
if(audioNum == 1)
%partA
labels = nnpredict(nn, feature_x);
deg = degree(labels);
[IDX, center] = kmeans(deg,sourceNum);
else
%partB
for audioIter = 1:audioNum
    labels = nnpredict(nn, feature_x(:,:,audioIter));
    deg = degree(labels);
    center(audioIter) = mean(deg);
end
end
%�Ƕ�ȡ��
for audioIter = 1:audioNum
    center(audioIter) = 10*round(center(audioIter)/10);
end
azimuthout = center;
sourceIndex = center./10.*2 + 19*ones(size(center));
%%
%4.��Դ���� 
freq=(0:frameSize-1)*(2*pi/(frameSize));
fmat=freq(ones(size(tf_L,2),1),:)';
%4.2����ÿ��Ƶ�������
% mask = 0.01*ones(frameSize,frameAmount,sourceNum);%���һά������Դ���
mask = zeros(frameSize,frameAmount,sourceNum);%���һά������Դ���
dis_mat = zeros(frameSize,frameAmount,sourceNum);
%�����뿪��Ƶ���������
tf_L = sum(tf_L,3);
tf_R = sum(tf_R,3);

%��������Դ���ݴ��������������ӦƵ��֮��ľ���
for sourceIter = 1:sourceNum
    IID_mat = repmat(mean_IID(:,sourceIndex(sourceIter)),1,frameAmount);
    dis_mat(:,:,sourceIter) = ((abs(IID_mat.*tf_L-exp(-1j*sourceITD(sourceIter)/onesample.*fmat).*tf_R)).^2)./(ones(frameSize,frameAmount)+IID_mat.^2);
end
%����̾���ԭ�����mask
for i = 1:frameSize/2+1 %����0~pi֮���mask
    for j = 1:frameAmount
        [~,belong] = min(dis_mat(i,j,:));
        mask(i,j,belong) = 1;
    end
end
%��һ���mask��ǰһ�뾵��Գ�
for n = 1:size(mask,3)
    mask(frameSize/2+2:frameSize,:,n) = flipud(mask(2:frameSize/2,:,n));
end
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

