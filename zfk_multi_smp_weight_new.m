function [alf, BWout, smp, Imax] = zfk_multi_smp_weight_new(smp_10)
    
    [r, c, d]=size(smp_10);  % d是通道
    
    smp_sum = sum(smp_10,3);%累加尺度序列图  
    smp4 = mat2gray(smp_sum);%归一化
    %% 比较smp1,smp2,smp3,各通道的 BW图，生成由饱和度构成的权重，做通道融合                       
    BW4 = imbinarize(smp4);%,0.5 smp4二值化，得到目标区域BW4
    BW4 = select_max_region(BW4,5);%二值化图中，选最大面积的5个连通域做感兴趣的目标
 
 kk=0;
 while (kk<10)    %目标级的正反馈加权
    F = zeros(d,1);    
    for i=1:d
       BW1 = imbinarize(smp_10(:,:,i));%smp10每个分量二值化，得到目标区域BW1             
       BW1 = select_max_region(BW1,5);%二值化图中，选最大面积的5个连通域做感兴趣的目标
                       
       F(i) =  ComputeFMeasure_1(BW1,BW4); %单图与综合图比较        
    end
    
    alf = zeros(d,1);
    Fsum = sum(F,1);
    for i=1:d
       alf(i)= F(i)/Fsum;%求出的alf1,alf2当前实际权重，提供给当前图像做加权 
    end
    
    sum1 = zeros(r,c);
    for i=1:d
        sum1 = alf(i)*smp_10(:,:,i) + sum1;%加权累加
    end
    smp5 = mat2gray(sum1); %
    %fprintf("alf1=%f, alf2=%f, alf3=%f, alf4=%f, alf5=%f\n", alf(1), alf(2), alf(3), alf(4), alf(5));%
    %fprintf("alf6=%f, alf7=%f, alf8=%f, alf9=%f, alf10=%f\n", alf(6), alf(7), alf(8), alf(9), alf(10));
    [val, ind] = sort(alf,'descend');
       
    %根据以前积累经验产生的感知饱和程度，生成的权重相加 %双通道输出显著图alf权重相加added %two-stream fusion
    BW5 = imbinarize(smp5);%sMap_final二值化，得到目标区域BW5             
    BW5 = select_max_region(BW5,5);                 
    Fcomp45 = ComputeFMeasure_1(BW4,BW5);%相邻反馈时间的BW4与BW5比较，相似度-饱和度
    if Fcomp45 >=0.95 %0.95
        break;
    else  
        BW4 = BW5;%更新综合输出的BW二值结果  
        kk=kk+1;
    end
end
    BWout = BW5;%输出的综合感知图的掩膜 
    smp = smp5;%输出的综合感知图
    Imax = smp_10(:,:,ind(1));%最大alf对应的原感知图
end