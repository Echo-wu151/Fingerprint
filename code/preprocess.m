function result = preprocess()
%�Ե�����ͼ����Ԥ����
I = imread('3.bmp');
multiple = 8;%��չ��Ӧ�ı���
I = paddingimage(I,multiple);%��������չ
dftI = fftshift(fft2(I));%����Ҷ�任
margin = log(1+abs(dftI));%������
center = [385,401];%���������ĵ�
%�ֶ��ҳ�������������
x = [112,295,202,295,21,203,111,21];
y = [306,215,494,679,120,30,772,586];
len = 7;%���������С
% figure(1);
% subplot(1,2,1);imshow(margin,[]); %��ʾԭ������
for i = 1:8
    dftI(x(i)-len:x(i)+len,y(i)-len:y(i)+len) = 0;
    dftI(2*center(1)-x(i)-len:2*center(1)-x(i)+len,2*center(2)-y(i)-len:2*center(2)-y(i)+len) = 0;
end
% margin = log(1+abs(dftI));
% subplot(1,2,2);imshow(margin,[]);%��ʾ�����ķ�����
Itemp = ifft2(fftshift(dftI));%����Ҷ���任
% figure(2);
% imshow(Itemp,[]);%��ʾƵ������
Idivide = Itemp(220:539,306:505);%�и��ָ��ͼ��
MinValue = min(min(Idivide));
MaxValue = max(max(Idivide));
Idivide =(Idivide-MinValue)/(MaxValue-MinValue);
% figure(3);
% imshow(Idivide,[]);%��ʾָ��ͼ��
result = Idivide;
end