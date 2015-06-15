function [output,azimuthout] = sepIter(inPutFilePath,times,sourceNum)
    %%
    %1.��ȡ�������
    % inPutFilePath = 'E:\\MatlabCode\\seperation\\shu\\female_male_10_50.wav';
%     inPutFilePath = 'E:\\MatlabCode\\seperation\\shu\\mixedvoice\3_330.wav';
    % inPutFilePath = 'E:\\MatlabCode\\seperation\\shu\\music_female_10_50.wav';
%     inPutFilePath = 'E:\\Document\\�������\\������\\data\\������\\female\\female_90.wav';
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
    if (fs_original==44100)
        x_L = resample(x_L,fs,fs_original);
        x_R = resample(x_R,fs,fs_original);
    end
    %2.3��֡�Ӵ�,ʱƵ����
    awin=hamming(frameSize);
    tf_L=tfanalysis(x_L,awin,frameShift,frameSize); % time-freq domain
    tf_R=tfanalysis(x_R,awin,frameShift,frameSize) ; % time-freq domain

    %%
    %3.��λ�������
    for Iter = 1:times
        [tf_L,tf_R,mono,azimuthout] = sepOnce(tf_L,tf_R,fs,sourceNum);
    end

    %%
    %4.ת����ʱ��
    output = cell(1,size(mono,3));
    for n = 1:size(mono,3)
%         output{n}=tfsynthesis(mono(:,:,n),sqrt(2)*awin/(2*frameSize),frameShift);
    output{n}=tfsynthesis(tf_R(:,:,n),sqrt(2)*awin/(2*frameSize),frameShift);
    end
end