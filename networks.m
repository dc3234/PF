%双流多分支正反馈加权的显著目标检测框架
clc;
close all;

addpath('.\Funcs\RBD\Funcs\SLIC');%RBD算法用到超像素处理'
addpath('.\Funcs\RBD\Funcs');
addpath('.\Funcs');

%% 1. Parameter Settings
RES = 'Result_save0221';%1023zfk雙流部分加了zfk加權
if ~exist(RES, 'dir')
    mkdir(RES);
end
DIRS = '.\data';%image and gt
dirs = dir(fullfile(DIRS));
alg_path = '.\RES_other_model';

alg_name1 = 'AFNet';%'RBD';
alg_name2 = 'F3Net';%'PiCANet2';%'AFNet';%
alg_name3 = 'PiCANet';%'F3Net';%
alg_name4 = 'PFA';%'PiCANet2';%'F3Net';%


alg_name5 = 'SelfReformer';%'Amulet';%(5 DUTOMRON ) MAE: 0.043+0.075;  Smeasure: 0.861+0.172; Fm: 0.807; Em: 0.899+0.191;(13 DUTOMRON ) MAE: 0.066+0.065;  Smeasure: 0.854+0.146; Fm: 0.843; Em: 0.886+0.200
alg_name6 = 'CAGNet-R';%'F3Net';%
alg_name7 = 'DSS';%'PiCANet2';%'F3Net';%
alg_name8 = 'RBD';%'RBD';

for dir_k = 3%:length(dirs)
        dir_name = dirs(dir_k).name;%image name
        dir_name % DUTOMRON
        Other_alg_dir = fullfile(alg_path,dir_name); % alg_path =  '.\RES_other_model'
        
        SRC = fullfile(DIRS,dir_name,'image');  % DIRS = '.\data'
        SRC % '.\data\DUTOMRON\image\'
        srcSuffix = '.jpg';%suffix for your input image  从data中的image获取图片名字
        files = dir(fullfile(SRC, strcat('*', srcSuffix))); % 连接后缀，获得整个图片名，例如  '.\data\DUTOMRON\image\im005.jpg'
  tic
  for k=1:10%length(files)
            disp(k);
            srcName = files(k).name;
            srcName % 图片名.jpg
            noSuffixName = srcName(1:end-length(srcSuffix));
            noSuffixName  % 图片名

            srcImg = imread(fullfile(SRC, srcName)); %% read Image 把图像读进来，这里先拿出来是为了后续保存new_sample用，如果达到条件则保存到另外一个文件中，否则不保存了
            [r,c,d]=size(srcImg); % 长，宽，通道
            if d<3  % 变三通道
              srcImg(:,:,1)=srcImg(:,:,1);
              srcImg(:,:,2)=srcImg(:,:,1);
              srcImg(:,:,3)=srcImg(:,:,1);
            end         
            if r>512  % 调整宽高
                srcImg = imresize(srcImg,512/r); % 缩小，返回结果图的长宽为图像是 原SrcImg的512/r倍。
            elseif c>512
                srcImg = imresize(srcImg,512/c); % 缩小
            end
            [r,c,d]=size(srcImg);  
           
         %% Smp 组成序列图像 
            smp1 = im2double(imread(fullfile(Other_alg_dir, alg_name1, strcat(noSuffixName,'.png'))));                     
            smp2 = im2double(imread(fullfile(Other_alg_dir, alg_name2, strcat(noSuffixName,'.png')))); 
            smp3 = im2double(imread(fullfile(Other_alg_dir, alg_name3, strcat(noSuffixName,'.png'))));            
            smp4 = im2double(imread(fullfile(Other_alg_dir, alg_name4, strcat(noSuffixName,'.png'))));  
            smp5 = im2double(imread(fullfile(Other_alg_dir, alg_name5, strcat(noSuffixName,'_sal.png'))));                     
            smp6 = im2double(imread(fullfile(Other_alg_dir, alg_name6, strcat(noSuffixName,'.png')))); 
            smp7 = im2double(imread(fullfile(Other_alg_dir, alg_name7, strcat(noSuffixName,'.png'))));            
            smp8 = im2double(imread(fullfile(Other_alg_dir, alg_name8, strcat(noSuffixName,'.png'))));  
           
            smp1 = imresize(smp1(:,:,1),[r,c]);  % 指定目标图像的高度和宽度，允许图像缩放后比例和原图比例不同，有可能产生畸变。  
            smp2 = imresize(smp2(:,:,1),[r,c]);       
            smp3 = imresize(smp3(:,:,1),[r,c]);        
            smp4 = imresize(smp4(:,:,1),[r,c]);
            smp5 = imresize(smp5(:,:,1),[r,c]);    
            smp6 = imresize(smp6(:,:,1),[r,c]);       
            smp7 = imresize(smp7(:,:,1),[r,c]);        
            smp8 = imresize(smp8(:,:,1),[r,c]);
      
            
            update_num = 1;
            RES3_2 = fullfile(RES,strcat(dir_name),num2str(update_num)); 
            if ~exist(RES3_2, 'dir')
                mkdir(RES3_2);
            end            
            imgName=fullfile(RES3_2, strcat(noSuffixName, '.png'));    
            imwrite(smp1, imgName);%output  % 仅仅为了将一组实验中用到的方法的显著图保存到同一个文件，方便测试。
            
            update_num = 2;
            RES3_2 = fullfile(RES,strcat(dir_name),num2str(update_num)); 
            if ~exist(RES3_2, 'dir')
                mkdir(RES3_2);
            end
            imgName=fullfile(RES3_2, strcat(noSuffixName, '.png'));    
            imwrite(smp2, imgName);%
         
            update_num = 3;
            RES3_2 = fullfile(RES,strcat(dir_name),num2str(update_num));  
            if ~exist(RES3_2, 'dir')
                mkdir(RES3_2);
            end
            imgName=fullfile(RES3_2, strcat(noSuffixName, '.png'));    
            imwrite(smp3, imgName);% output
            
            update_num = 4;
            RES3_2 = fullfile(RES,strcat(dir_name),num2str(update_num));  
            if ~exist(RES3_2, 'dir')
                mkdir(RES3_2);
            end
            imgName=fullfile(RES3_2, strcat(noSuffixName, '.png'));    
            imwrite(smp4, imgName);% output
            
            update_num = 5;
            RES3_2 = fullfile(RES,strcat(dir_name),num2str(update_num)); 
            if ~exist(RES3_2, 'dir')
                mkdir(RES3_2);
            end            
            imgName=fullfile(RES3_2, strcat(noSuffixName, '.png'));    
            imwrite(smp5, imgName);%output 
            
            update_num = 6;
            RES3_2 = fullfile(RES,strcat(dir_name),num2str(update_num)); 
            if ~exist(RES3_2, 'dir')
                mkdir(RES3_2);
            end
            imgName=fullfile(RES3_2, strcat(noSuffixName, '.png'));    
            imwrite(smp6, imgName);%
         
            update_num = 7;
            RES3_2 = fullfile(RES,strcat(dir_name),num2str(update_num));  
            if ~exist(RES3_2, 'dir')
                mkdir(RES3_2);
            end
            imgName=fullfile(RES3_2, strcat(noSuffixName, '.png'));    
            imwrite(smp7, imgName);% output
            
            update_num = 8;
            RES3_2 = fullfile(RES,strcat(dir_name),num2str(update_num));  
            if ~exist(RES3_2, 'dir')
                mkdir(RES3_2);
            end
            imgName=fullfile(RES3_2, strcat(noSuffixName, '.png'));    
            imwrite(smp8, imgName);% output
                       
            smp_10 = zeros(r,c,4);
            smp_10(:,:,1) = smp1;
            smp_10(:,:,2) = smp2;
            smp_10(:,:,3) = smp3;
            smp_10(:,:,4) = smp4;
            
            smp_20 = zeros(r,c,4);
            smp_20(:,:,1) = smp5;
            smp_20(:,:,2) = smp6;
            smp_20(:,:,3) = smp7;
            smp_20(:,:,4) = smp8;
            
      %%  four-branch:smp1,smp2,smp3,smp4, zfk-weighted 
           [alf1, BWout1, smp_out1, Imax1] = zfk_multi_smp_weight_new(smp_10);%第一感知流zfk加权结果输出
           [alf2, BWout2, smp_out2, Imax2] = zfk_multi_smp_weight_new(smp_20);%第二感知流zfk加权结果输出
           
           smp_mix = mat2gray(smp_out1+smp_out2); %双流混合输出图 smp_mix % (13 DUTOMRON ) MAE: 0.074+0.067;  Smeasure: 0.838+0.153; Fm: 0.838; Em: 0.863+0.222     第一good    
     
            update_num = 9;
            RES3_2 = fullfile(RES,strcat(dir_name),num2str(update_num));  
            if ~exist(RES3_2, 'dir')
                mkdir(RES3_2);
            end
            imgName=fullfile(RES3_2, strcat(noSuffixName, '.png'));    
            imwrite(smp_out1, imgName);% zfk后的目标显著图smp 
            
            update_num = 10;
            RES3_2 = fullfile(RES,strcat(dir_name),num2str(update_num));  
            if ~exist(RES3_2, 'dir')
                mkdir(RES3_2);
            end
            imgName=fullfile(RES3_2, strcat(noSuffixName, '.png'));    
            imwrite(smp_out2, imgName);% 另外一流，zfk后的目标显著图的二值掩膜 BW
            
            update_num = 11;
            RES3_2 = fullfile(RES,strcat(dir_name),num2str(update_num));  
            if ~exist(RES3_2, 'dir')
                mkdir(RES3_2);
            end
            imgName=fullfile(RES3_2, strcat(noSuffixName, '.png'));    
            imwrite(Imax1, imgName); % 
            
            update_num = 12;
            RES3_2 = fullfile(RES,strcat(dir_name),num2str(update_num));  
            if ~exist(RES3_2, 'dir')
                mkdir(RES3_2);
            end
            imgName=fullfile(RES3_2, strcat(noSuffixName, '.png'));    
            imwrite(Imax2, imgName);% 
            
            update_num = 13;
            RES3_2 = fullfile(RES,strcat(dir_name),num2str(update_num));  
            if ~exist(RES3_2, 'dir')
                mkdir(RES3_2);
            end
            imgName=fullfile(RES3_2, strcat(noSuffixName, '.png'));    
            imwrite(smp_mix, imgName);%双流混合叠加的结果显著图
            
            update_num = 14;
            RES3_2 = fullfile(RES,strcat(dir_name),num2str(update_num));  
            if ~exist(RES3_2, 'dir')
                mkdir(RES3_2);
            end
            imgName=fullfile(RES3_2, strcat(noSuffixName, '.png'));    
            imwrite(BWout1, imgName);%第一流的二值输出
            update_num = 15;
            RES3_2 = fullfile(RES,strcat(dir_name),num2str(update_num));  
            if ~exist(RES3_2, 'dir')
                mkdir(RES3_2);
            end
            imgName=fullfile(RES3_2, strcat(noSuffixName, '.png'));    
            imwrite(BWout2, imgName);%第二流的二值输出
          
    
   
 %}    
 toc  
 end
end
