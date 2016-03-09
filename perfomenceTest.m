clc;clear;close all;
L = 473000;
for SNR = 20
    for deg = 10:10:90
        sepPath = sprintf('./output/�����Ա�/outMale_female_male_%02d.wav',deg);
        origPath = sprintf('E:\\Document\\�������\\������\\180����Դ\\female2.wav');
        [y1,fs1] = audioread(sepPath);
        [y2,fs2] = audioread(origPath);
        if (fs2==44100)
            y2 = resample(y2,fs1,fs2);
        end
        s1 = strsplit(sepPath,'/');
        s2 = strsplit(origPath,'\\');
        p1 = strcat('./output/��������/', s1(end));
        p2 = strcat('./output/ԭ����/', s2(end));
        %         audiowrite(p1{1}, y1(1:L), fs1);
%         audiowrite(p2{1}, y2(1:L,2), fs2);
        audiowrite(p2{1}, y2, fs1);
    end
end

