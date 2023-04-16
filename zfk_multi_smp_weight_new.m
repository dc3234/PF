function [alf, BWout, smp, Imax] = zfk_multi_smp_weight_new(smp_10)
    
    [r, c, d]=size(smp_10);  % d��ͨ��
    
    smp_sum = sum(smp_10,3);%�ۼӳ߶�����ͼ  
    smp4 = mat2gray(smp_sum);%��һ��
    %% �Ƚ�smp1,smp2,smp3,��ͨ���� BWͼ�������ɱ��Ͷȹ��ɵ�Ȩ�أ���ͨ���ں�                       
    BW4 = imbinarize(smp4);%,0.5 smp4��ֵ�����õ�Ŀ������BW4
    BW4 = select_max_region(BW4,5);%��ֵ��ͼ�У�ѡ��������5����ͨ��������Ȥ��Ŀ��
 
 kk=0;
 while (kk<10)    %Ŀ�꼶����������Ȩ
    F = zeros(d,1);    
    for i=1:d
       BW1 = imbinarize(smp_10(:,:,i));%smp10ÿ��������ֵ�����õ�Ŀ������BW1             
       BW1 = select_max_region(BW1,5);%��ֵ��ͼ�У�ѡ��������5����ͨ��������Ȥ��Ŀ��
                       
       F(i) =  ComputeFMeasure_1(BW1,BW4); %��ͼ���ۺ�ͼ�Ƚ�        
    end
    
    alf = zeros(d,1);
    Fsum = sum(F,1);
    for i=1:d
       alf(i)= F(i)/Fsum;%�����alf1,alf2��ǰʵ��Ȩ�أ��ṩ����ǰͼ������Ȩ 
    end
    
    sum1 = zeros(r,c);
    for i=1:d
        sum1 = alf(i)*smp_10(:,:,i) + sum1;%��Ȩ�ۼ�
    end
    smp5 = mat2gray(sum1); %
    %fprintf("alf1=%f, alf2=%f, alf3=%f, alf4=%f, alf5=%f\n", alf(1), alf(2), alf(3), alf(4), alf(5));%
    %fprintf("alf6=%f, alf7=%f, alf8=%f, alf9=%f, alf10=%f\n", alf(6), alf(7), alf(8), alf(9), alf(10));
    [val, ind] = sort(alf,'descend');
       
    %������ǰ���۾�������ĸ�֪���ͳ̶ȣ����ɵ�Ȩ����� %˫ͨ���������ͼalfȨ�����added %two-stream fusion
    BW5 = imbinarize(smp5);%sMap_final��ֵ�����õ�Ŀ������BW5             
    BW5 = select_max_region(BW5,5);                 
    Fcomp45 = ComputeFMeasure_1(BW4,BW5);%���ڷ���ʱ���BW4��BW5�Ƚϣ����ƶ�-���Ͷ�
    if Fcomp45 >=0.95 %0.95
        break;
    else  
        BW4 = BW5;%�����ۺ������BW��ֵ���  
        kk=kk+1;
    end
end
    BWout = BW5;%������ۺϸ�֪ͼ����Ĥ 
    smp = smp5;%������ۺϸ�֪ͼ
    Imax = smp_10(:,:,ind(1));%���alf��Ӧ��ԭ��֪ͼ
end