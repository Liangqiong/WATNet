function data_augment_with_mat(file_path, savepath)
% file_path  path for saving the well-processed 3D mat files
%% To do data augmentation

% savepath = '/media/liangqiong/Data/liangqiong/Research/DeepLearning/3T7T/dataset/Augment/mat/S1-10-with-seg/subjs/'; % where to save the extracted mat, modified to your own dataset

if ~exist(savepath,'file')
    mkdir(savepath);
    mkdir(strcat(savepath,'S1'));mkdir(strcat(savepath,'S2'));
    mkdir(strcat(savepath,'S3'));mkdir(strcat(savepath,'S4'));
    mkdir(strcat(savepath,'S5'));mkdir(strcat(savepath,'S6'));
    mkdir(strcat(savepath,'S7'));mkdir(strcat(savepath,'S8'));
    mkdir(strcat(savepath,'S9'));mkdir(strcat(savepath,'S10'));
    
end



for su =  1: 10
    dataname = strcat(file_path,'MRI_3T_7T_',num2str(su),'.mat');
    load(dataname);
    imTL = im3TV_id;
    imTH = im7TV_id;
    im_name = strcat('S',num2str(su));
    
    [~,~,Len] = size(imTL);
    for i = 1 : Len-2
        image = imTL(:,:,i:i+2);
        image_7T = imTH(:,:,i:i+2);
        count = 0;
        if max(image(:))< 1e-5
            sub_im_7T = image_7T;
            sub_im_3T = image;
            
            save([savepath 'S' num2str(su) '/' im_name, '_sub' num2str(i) '_' num2str(count) '.mat'],'sub_im_3T', 'sub_im_7T');
            count = count + 1;
            
        else
            for angle = 0: 90 :270
                
                im_rot = imrotate(image, angle);
                im_7T_rot = imrotate(image_7T, angle);
                
                
                
                for scale = 1.0 : -0.2 : 0.5
                    im_down = imresize(im_rot, scale, 'bicubic');
                    im_7T_down = imresize(im_7T_rot, scale, 'bicubic');
                    
                    for j = 3 : -2 : 1  % 3--> not flip, 1-->flip horizontally
                        if j == 3
                            im_flip = im_down;
                            im_7T_flip = im_7T_down;
                        else
                            im_flip = flip(im_down, j);
                            im_7T_flip = flip(im_7T_down, j);
                        end
                        
                        
                        
                        sub_im_7T = im_7T_flip;
                        sub_im_3T = im_flip;
                        save([savepath 'S' num2str(su) '/' im_name, '_sub' num2str(i) '_' num2str(count) '.mat'],'sub_im_3T', 'sub_im_7T' );
                        count = count + 1;
                    end
                    
                end
            end
        end
        fprintf(['Processing Subject', num2str(su) ' of slice %d  \n'], i); 
    end
    
    
end

