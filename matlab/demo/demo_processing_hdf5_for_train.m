
%% demo for preparing dataset for training

% config
filePath_h5 = '/media/liangqiong/Data/liangqiong/Research/DeepLearning/Demo/Dataset/Orig_15/3T7T-Data/'
save_path_mat_processed = './data_processing/data_15/'
save_path_mat_3slice = '/media/liangqiong/Data/liangqiong/Research/DeepLearning/Demo/WATNet/matlab/demo/data_process_for_train/processed_data/augmented_mat/'
save_path_txt = '/media/liangqiong/Data/liangqiong/Research/DeepLearning/Demo/WATNet/matlab/demo/data_process_for_train/processed_data/Txt/';  % save filename
save_hdf5_path = '/media/liangqiong/Data/liangqiong/Research/DeepLearning/Demo/WATNet/matlab/demo/data_process_for_train/processed_data/hdf5/' % the final path for hdf5
txt_name = 'train_WATNet'
test_id_num = 2; % setting the test subject (we use leave-one-out-cross validation)
addpath(genpath('./data_process_for_train/'))

% step 0: data normalization and histgromatching
% all the files have already been processed and saved in 
data_process_nii_2_mat(filePath_h5, save_path_mat_processed)


% step 1: data augmentation
data_augment_with_mat(save_path_mat_processed, save_path_mat_3slice)


% step 3: generate hdf5 file
saveImgtoTxt(save_path_mat_3slice,save_path_txt, txt_name, test_id_num) % parse through the folder for all the files 
generate_hdf5_train_test(save_path_txt, save_hdf5_path, txt_name, test_id_num)


