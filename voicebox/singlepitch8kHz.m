%˵�����������׼ȷ��ͦ��
function pitch=singlepitch8kHz(x)
%figure;
%x=s1frame(2,:);
N=length(x);
for m=1:N
    R(m)=sum(x(1:end-m+1).*x(m:end));%������غ���
end
[k,v]=findpeaks(R,'q');
[amplitude,num]=max(v);
if R(1)==0
    pitch=0;
elseif length(k)==0
    pitch=0;
elseif amplitude/R(1)<0.28
    pitch=0;
elseif round(k(num))<18||round(k(num))>143                              %��������λ��[60Hz,500Hz],����8kHZ�������������ڶ�Ӧ��������ԼΪ[18,143]
        pitch=0;
else
        pitch=round(k(num));
end
end

    