function result = paddingimage(image,multiple)%multipleΪ�����Ӧ�ı���������Ϊ8
%ͼ�����䣬��ͼ���������䵽8�ı������Ա��ڷָ�
[height,width] = size(image);
if mod(height,multiple) ~= 0
    addheight = multiple - mod(height,multiple);%�������
else
    addheight = 0;
end
if mod(width,multiple) ~= 0
    addwidth = multiple - mod(width,multiple);%�������
else
    addwidth = 0;
end
result = padarray(image,[addheight,addwidth],'replicate','post');%������߽磬������䱣֤��Ŀ��ȷ
end
