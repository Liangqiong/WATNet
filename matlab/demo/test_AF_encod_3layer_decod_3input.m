clear;close all
addpath(genpath('./data_processing'))


use_gpu = 1
if exist('../+caffe', 'dir')
    addpath('..');
else
    error('Please run this demo from caffe/matlab/demo');
end


% Set caffe mode
if exist('use_gpu', 'var') && use_gpu
    caffe.set_mode_gpu();
    gpu_id = 0;  % we will use the first gpu in this demo
    caffe.set_device(gpu_id);
else
    caffe.set_mode_cpu();
end

addpath('./util')
%
%
load('3T-7T-wavelet-3layer-mat-mean-std.mat')  % for mat


model = '../../examples/MRI/protxt/AF_encod_3layer_decod_3input_deploy.prototxt';

weights = '../../examples/MRI/MRI_model/AF_3input_t2_iter_132000.caffemodel';

net=caffe.Net(model,weights,'test');
input_size1 =192;
input_size2 = 256;

count_input = 1
tmp_ind = 1;
data_wave_1 = [];
data_wave_2= [] ;
data_wave_3=[];


for su = 2 %1:10
    dataname = strcat('./data_processing/data_15/MRI_3T_7T_',num2str(su),'.mat');
    load(dataname)
    
    ind_all = zeros(size(im7TV_id));
    im7T_reconst = zeros(size(im7TV_id));
    % testing for each slice
    [m,n,t] = size(im3TV_id);
    for i = 1: 1:  t-2
        image = im3TV_id(:,:,i);
        GT = im7TV_id(:,:,i);
        image = imresize(image,[input_size1,input_size2],'bicubic');
        GT = imresize(GT,[input_size1,input_size2],'bicubic');
        image1 = image .* 255;
        GT1 = GT .* 255;
        
        
        image_s2 = im3TV_id(:,:,i+1);
        GT_s2 = im7TV_id(:,:,i);
        image_s2 = imresize(image_s2,[input_size1,input_size2],'bicubic');
        GT_s2 = imresize(GT_s2,[input_size1,input_size2],'bicubic');
        image_s2_1 = image_s2 .* 255;
        GT_s2_1 = GT_s2 .* 255;
        
        
        image_s3 = im3TV_id(:,:,i+2);
        GT_s3 = im7TV_id(:,:,i);
        image_s3 = imresize(image_s3,[input_size1,input_size2],'bicubic');
        GT_s3 = imresize(GT_s3,[input_size1,input_size2],'bicubic');
        image_s3_1 = image_s3 .* 255;
        GT_s3_1 = GT_s3 .* 255;
        
        
        [data_wave_1, data_wave_2,data_wave_3] = inner_hist_norm(image1,thr_T,count_input,data_wave_1,data_wave_2,data_wave_3,image_s2_1,image_s3_1);
        
        
        
        
        data(:, :, 1, count_input) = image;
        data(:, :, 2, count_input) = image_s2;
        data(:, :, 3, count_input) = image_s3;
        
        
        
        im_data_ALL = {data;data_wave_1;data_wave_2;data_wave_3};
        output_rgb=net.forward(im_data_ALL);
        output_rgb = double(output_rgb{1});
        output_rgb = imresize(double(output_rgb),[191,253]);
        ind_all(:,:,i:i+2) = ind_all(:,:,i:i+2) + ones(size(output_rgb));
        im7T_reconst(:,:,i:i+2)  = im7T_reconst(:,:,i:i+2) + output_rgb;
      
        
    end
    im7T_reconst  = im7T_reconst./ind_all;
    PSNR_all(su) = psnr(im7TV_id,im7T_reconst,1);
    SSIM_all(su) = ssim_index3d(im7TV_id*255, im7T_reconst*255, [1, 1, 1], im7TV_id>0);
    fprintf(['Subject', num2str(su),': PSNR=%.2f,  SSIM=%.4f  \n'], PSNR_all(su), SSIM_all(su));
    
    
    PSNR = PSNR_all(su);
    SSIM = SSIM_all(su);
    savename = strcat('./data_processing/temp_result/MRI_7T_AF_mat_',num2str(su),'.mat');
    save(savename,'im7T_reconst','PSNR','SSIM')
    
    clear im7T_reconst
    
end


