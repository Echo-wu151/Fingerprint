function enhance_fingerprint2()
%%
%��ȡͼƬ����չ
I = imread('23_2.bmp');
multiple = 8;%��չ��Ӧ�ı���
I = paddingimage(I,multiple);%��չ��8�ı���
Ipad = padarray(I,[12,12],'replicate','both');%��չ�Ա���32*32��DFT
%%
%�ָ�
[height,width] = size(I);%ͼ��ߴ�
heinum = height/multiple;%�ֿ���Ŀ�������������
widnum = width/multiple;
divideimage = zeros(heinum,widnum,32,32);%�ָ��ͼ��
dftmatrix = zeros(heinum,widnum,32,32);%������
sign = zeros(heinum,widnum);%�ָ��־
threshold_lowfre = 0.36;%�ָ��Ƶ���ַ���ռ�ȵ���ֵ
%%
%ͨ�������׵�Ƶ����ռ�Ƚ��зָ�
for i = 1:heinum
    for j = 1:widnum
        divideimage(i,j,:,:) = Ipad((i-1)*multiple+1:i*multiple+24,(j-1)*multiple+1:j*multiple+24);%ͼ��ֿ�洢
        dftmatrix(i,j,:,:) = abs(fftshift(fft2(Ipad((i-1)*multiple+1:i*multiple+24,(j-1)*multiple+1:j*multiple+24))));%ͼ��DFT
        persent_lowfre = sum(sum(dftmatrix(i,j,15:20,15:20)))/sum(sum(dftmatrix(i,j,:,:)));%��Ƶ����ռ��
        if persent_lowfre > threshold_lowfre
            sign(i,j) = 0;
        else
            sign(i,j) = 1;
        end
    end
end
%�鿴�ָ����
divide = I;
for i = 1:heinum
    for j = 1:widnum
        if sign(i,j) == 0
            divide((i-1)*multiple+1:i*multiple,(j-1)*multiple+1:j*multiple) = 0;%������������
        end
    end
end
figure(1);
subplot(2,3,1);imshow(I);title('ԭͼ');
subplot(2,3,2);imshow(divide);title('�ָ���');
%%
%����ͼ��ȷ��
cita = zeros(heinum,widnum);%����ͼ
for i = 1:heinum
    for j = 1:widnum
        if sign(i,j) == 1
        dftcopy = zeros(32,32);%����
        for m = 1:32
            for n = 1:32
               dftcopy(m,n) =  dftmatrix(i,j,m,n);
            end
        end
        dftcopy(17,17) = 0;%ֱ����������
        maxnum = max(max(dftcopy));
        maxpoint = zeros(2,2);%�������ֵ��
        tempnum = 1;
        for m = 1:32
            for n = 1:32
                if dftcopy(m,n) == maxnum %Ѱ�����ֵ��
                    maxpoint(tempnum,1) = m;
                    maxpoint(tempnum,2) = n;
                    tempnum = tempnum + 1;
                end
            end
        end
        cita(i,j) = 0.5*pi + atan((maxpoint(1,2)-maxpoint(2,2))/(maxpoint(1,1)-maxpoint(2,1)));%�������
        end
    end
end
subplot(2,3,4);quiver(flip(cos(cita - 0.5*pi)), flip(sin(cita - 0.5*pi)));title('����ͼ');
%%
%Ƶ��ͼ��ȷ��
frequency = zeros(heinum,widnum);%Ƶ��
nmbda = zeros(heinum,widnum);%����
for i = 1:heinum
    for j = 1:widnum
        if sign(i,j) == 1%�ж��Ƿ�Ϊָ������
        dftcopy = zeros(32,32);%����
        for m = 1:32
            for n = 1:32
               dftcopy(m,n) =  dftmatrix(i,j,m,n);
            end
        end
        dftcopy(17,17) = 0;%ɾ��ֱ������
        maxnum = max(max(dftcopy));
        maxpoint = zeros(2,2);%�������ֵ�㣬��Ӧָ�Ʒ�����Ƶ��
        tempnum = 1;
        for m = 1:32
            for n = 1:32
                if dftcopy(m,n) == maxnum %Ѱ�����ֵ��
                    maxpoint(tempnum,1) = m;
                    maxpoint(tempnum,2) = n;
                    tempnum = tempnum + 1;
                end
            end
        end
        %����Ƶ���벨��
        distanceofmax = ((maxpoint(1,2)-17)^2+(maxpoint(1,1)-17)^2)^0.5;%�������ֵ�㵽��17,17���ľ���
        frequency(i,j) = 2*pi*distanceofmax/32;%Ƶ��
        nmbda(i,j) = 32/distanceofmax;%����
        end
    end
end
%%
%����ͼƽ��
coscita = zeros(heinum,widnum);
sincita = zeros(heinum,widnum);
for i = 1:heinum
    for j = 1:widnum
        coscita(i,j) = cos(2*cita(i,j));
        sincita(i,j) = sin(2*cita(i,j));
    end
end
w0 = fspecial('gaussian',3,0.5);
%�ֱ���ø�˹��ֵ�˲�
coscitasmooth = imfilter(coscita,w0);
sincitasmooth = imfilter(sincita,w0);
citasmooth = 0.5*atan2(sincitasmooth,coscitasmooth);
subplot(2,3,5);quiver(flip(cos(citasmooth - 0.5*pi)), flip(sin(citasmooth - 0.5*pi)));title('ƽ����ķ���ͼ');
%Ƶ��ͼƽ����ʵ���ǲ���ͼ��ƽ��
nmbdasmooth = imfilter(nmbda,w0);
subplot(2,3,3);imshow(nmbdasmooth,[]);title('ƽ����Ĳ���ͼ');
%%
%�˲�
Ipad2 = padarray(I,[4,4],'replicate','both');%��չ
[height2,width2] = size(Ipad2);
filterresult = zeros(height2,width2);
imageresult = zeros(height,width);
citause = citasmooth.*180./pi;%�Ƕȱ任Ϊ�Ƕ���
for i = 1:heinum
    for j = 1:widnum
        if sign(i,j) == 1
        [mag,phase] = imgaborfilt(Ipad2((i-1)*multiple+1:i*multiple+8,(j-1)*multiple+1:j*multiple+8), nmbdasmooth(i,j),citause(i,j));%Gabor�˲�
        temp = mag .*cos(phase);
        filterresult((i-1)*multiple+1:i*multiple+8,(j-1)*multiple+1:j*multiple+8) = temp;
        end
    end
end
imageresult = filterresult(5:height2-4,5:width2-4);
w1 = fspecial('gaussian', [8,8],1);%��˹�˲���ʹ��Ч������
imageresult = imfilter(imageresult,w1);
subplot(2,3,6);imshow(imageresult);title('������');
end