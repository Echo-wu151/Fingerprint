function enhance_fingerprint3()
%%
%��ȡͼƬ����չ
I = preprocess();%ͼ��Ԥ����
multiple = 4;%��չ��Ӧ�ı���
windowsize = 8;%DFT���ڴ�С
padsize = (windowsize-multiple)/2;%��չ��С
centerpoint = windowsize/2 + 1;%DFT���ĵ�
I = paddingimage(I,multiple);%��չ������
Ipad = padarray(I,[padsize,padsize],'replicate','both');%��չ�Ա��ڸ����DFT
Ipad2 = padarray(I,[18,18],'replicate','both');%��չ�Ա��ڸ���Χ�ĻҶȾ�ֵ�ͷ���ļ���
%%
%�ָ�
[height,width] = size(I);%ͼ��ߴ�
heinum = height/multiple;%�ֿ���Ŀ�������������
widnum = width/multiple;
divideimage = zeros(heinum,widnum,windowsize,windowsize);%�ָ��ͼ��
dftmatrix = zeros(heinum,widnum,windowsize,windowsize);%������
sign = zeros(heinum,widnum);%�ָ��־
threshold_lowfre = 0.8;%�ָ��Ƶ���ַ���ռ�ȵ���ֵ
threshold_meangray = 0.45;%�ҶȾ�ֵ����ֵ
threshold_stdgray = 0.136;%�Ҷȷ������ֵ
%%
%ͨ�������׵�Ƶ����ռ�Ƚ��зָ�
for i = 1:heinum
    for j = 1:widnum
        divideimage(i,j,:,:) = Ipad((i-1)*multiple+1:i*multiple+windowsize-multiple,(j-1)*multiple+1:j*multiple+windowsize-multiple);%ͼ��ֿ�洢
        dftmatrix(i,j,:,:) = abs(fftshift(fft2(Ipad((i-1)*multiple+1:i*multiple+windowsize-multiple,(j-1)*multiple+1:j*multiple+windowsize-multiple))));%ͼ��DFT
        persent_lowfre = sum(sum(dftmatrix(i,j,centerpoint-1:centerpoint+1,centerpoint-1:centerpoint+1)))/sum(sum(dftmatrix(i,j,:,:)));%��Ƶ����ռ��
        meangray = mean2(Ipad2((i-1)*multiple+1:i*multiple+36,(j-1)*multiple+1:j*multiple+36));%40*40�ҶȾ�ֵ
        stdgray = std2(Ipad2((i-1)*multiple+1:i*multiple+36,(j-1)*multiple+1:j*multiple+36));%40*40�Ҷȷ���
        if persent_lowfre > threshold_lowfre
            sign(i,j) = 0;
        else
            if meangray < threshold_meangray && stdgray < threshold_stdgray
                sign(i,j) = 1;
            else
                sign(i,j) = 0;
            end
        end
    end
end
%��̬ѧ����
%�������ͨ��
CC = bwconncomp(sign);
numPixels = cellfun(@numel,CC.PixelIdxList);
[~,num] = size(numPixels);
sign2 = false(size(sign));
for i = 1:num
    if numPixels(i)>5000%�����ͨ�����ظ�������5000
        sign2(CC.PixelIdxList{i}) = 1;
    end
end
%���������ű�Ե
circle = strel('disk',3);%Բ��mask
sign3 = imdilate(sign2,circle);
%�鿴�ָ����
divide = I;
for i = 1:heinum
    for j = 1:widnum
        if sign3(i,j) == 0
            divide((i-1)*multiple+1:i*multiple,(j-1)*multiple+1:j*multiple) = 0;%������������
        end
    end
end
figure(1);
I0 = imread('3.bmp');
subplot(2,3,1);imshow(I0);title('ԭͼ');
subplot(2,3,2);imshow(divide);title('�ָ���');
%%
%����ͼ��ȷ��
cita = zeros(heinum,widnum);%����ͼ
for i = 1:heinum
    for j = 1:widnum
        if sign3(i,j) == 1
        dftcopy = zeros(windowsize,windowsize);%����
        for m = 1:windowsize
            for n = 1:windowsize
               dftcopy(m,n) =  dftmatrix(i,j,m,n);
            end
        end
        dftcopy(centerpoint,centerpoint) = 0;%ֱ����������
        maxnum = max(max(dftcopy));
        maxpoint = zeros(2,2);%�������ֵ��
        tempnum = 1;
        for m = 1:windowsize
            for n = 1:windowsize
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
        if sign3(i,j) == 1%�ж��Ƿ�Ϊָ������
        dftcopy = zeros(windowsize,windowsize);%����
        for m = 1:windowsize
            for n = 1:windowsize
               dftcopy(m,n) =  dftmatrix(i,j,m,n);
            end
        end
        dftcopy(centerpoint,centerpoint) = 0;%ɾ��ֱ������
        maxnum = max(max(dftcopy));
        maxpoint = zeros(2,2);%�������ֵ�㣬��Ӧָ�Ʒ�����Ƶ��
        tempnum = 1;
        for m = 1:windowsize
            for n = 1:windowsize
                if dftcopy(m,n) == maxnum %Ѱ�����ֵ��
                    maxpoint(tempnum,1) = m;
                    maxpoint(tempnum,2) = n;
                    tempnum = tempnum + 1;
                end
            end
        end
        %����Ƶ���벨��
        distanceofmax = ((maxpoint(1,2)-centerpoint)^2+(maxpoint(1,1)-centerpoint)^2)^0.5;%�������ֵ�㵽��9,9���ľ���
        frequency(i,j) = 2*pi*distanceofmax/windowsize;%Ƶ��
        nmbda(i,j) = windowsize/distanceofmax;%����
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
padlen = 1;
Ipad2 = padarray(I,[padlen,padlen],'replicate','both');%��չ
[height2,width2] = size(Ipad2);
filterresult = zeros(height2,width2);
imageresult = zeros(height,width);
citause = citasmooth.*180./pi;%�Ƕȱ任Ϊ�Ƕ���
for i = 1:heinum
    for j = 1:widnum
        if sign3(i,j) == 1
        [mag,phase] = imgaborfilt(Ipad2((i-1)*multiple+1:i*multiple+padlen*2,(j-1)*multiple+1:j*multiple+padlen*2), nmbdasmooth(i,j),citause(i,j));%Gabor�˲�
        temp = mag .*cos(phase);
        filterresult((i-1)*multiple+1:i*multiple+padlen*2,(j-1)*multiple+1:j*multiple+padlen*2) = temp;
        end
    end
end
imageresult = filterresult(padlen+1:height2-padlen,padlen+1:width2-padlen);
subplot(2,3,6);imshow(imageresult);title('������');
end