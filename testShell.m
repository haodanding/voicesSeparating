clc;clear;close all;
deg = 0:10:90;
degEst=cell(1,length(deg));
for i = 1:length(deg)
%     inPutFilePath = sprintf('E:\\Document\\�������\\������\\data\\�ɼ���\\female_%02d.wav',deg(i));
%     inPutFilePath = sprintf('E:\\Document\\�������\\������\\data\\������\\whitenoise\\female_noise_20_%02d.wav',deg(i));
%     inPutFilePath = sprintf('E:\\Document\\�������\\������\\data\\������\\whitenoise\\female_noise_15_%02d.wav',deg(i));
%     inPutFilePath = sprintf('E:\\Document\\�������\\������\\data\\������\\whitenoise\\female_noise_10_%02d.wav',deg(i));
%     inPutFilePath = sprintf('E:\\Document\\�������\\������\\data\\������\\whitenoise\\female_noise_5_%02d.wav',deg(i));
%     inPutFilePath = sprintf('E:\\Document\\�������\\������\\data\\������\\whitenoise\\female_noise_0_%02d.wav',deg(i));
    inPutFilePath = sprintf('E:\\MatlabCode\\seperation\\shu\\mixedvoice\\mixed_f_10_m_%02d.wav',deg(i));

    [output,ami] = sepIter(inPutFilePath,4);
    degEst{i}=ami;
end