function generate_hdf5_train_test(path_txt, save_hdf5_path, txt_name, test_id)

%% settings
%% settings
% folder paths save the mat files 
%  save_hdf5_path  paths save the final hdf5 file
% test_id = '10'
savefolder = strcat(save_hdf5_path,num2str(test_id),'/');

txt_train_name = strcat(path_txt, txt_name,'_S', num2str(test_id), '.txt');
txt_test_name = strcat(path_txt,txt_name, '_S', num2str(test_id), '.txt');


% delete(savefolder)
if ~exist(savefolder,'file')
    mkdir(savefolder)
end


size_input = 64; % 29 | 39
size_label = 64; % 57 | 77

stride = 48;

%% initialization
count_input = 0;
count_label = 0;
count_bic = 0;

%% generate data
load('3T-7T-wavelet-3layer-tot25-mat-mean-std.mat')

%% step  1 : for training hdf5
%

fid=fopen(txt_train_name,'r');
fid1=fopen(txt_test_name,'r');
formatSave = '%s \n';



name_list = textscan(fid, formatSave);
name_list = name_list{1};
Tot_Len = length(name_list);

name_ind = 1:Tot_Len;
sub_Len = 960;
tot_batch = ceil(Tot_Len/sub_Len);
totalct = 0;
created_flag = false;
for batch =    tot_batch:-1:1
    
    %% initialization
    savepath = strcat(savefolder, 'train_hdf5_64_pixel_3_wavelet',num2str(batch),'.h5');
    if exist(savepath,'file')
        continue
    end
    tic
    %% initialization
    count_input = 0;
    data_wave_1 =  [];%zeros(size_input/2,size_input/2,9,7800);
    data_wave_2 =  [];%zeros(size_input/4,size_input/4,9,7800);
    data_wave_3 =  [];%zeros(size_input/8,size_input/8,12,7800);
    %% generate data
    Len = batch;
    if Len*sub_Len < Tot_Len
        sel_randi = name_ind((Len-1)*sub_Len+1:Len*sub_Len);
    else
        sel_randi = name_ind((Len-1)*sub_Len+1:Tot_Len);
    end
    num_Qu=0;
    
    for ii = 1: length(sel_randi)
        i=sel_randi(ii);
        name_orig = name_list{i};
        % name of the following 2 slices
        
        
        
        load(name_orig);
        image1 = sub_im_3T;
        GT1 = sub_im_7T;
        image = double(image1).*255;
        GT = double(GT1).*255;
        
        
        [hei,wid,dim] = size(image); % LR subimage size
        
        % data and label
        for x = 1 : stride : hei - size_input + 1
            for y = 1 : stride : wid - size_input + 1
                
                sub_im = image(x : size_input + x - 1, y : size_input + y - 1,:);
                
                if (length(find(sub_im(:) ==0))  > size_input*size_input * 0.9)
                    continue
                else
                    
                    count_input = count_input + 1;
                    
                    [data_wave_1, data_wave_2,data_wave_3] = inner_hist_norm_3(sub_im,thr_T,count_input,data_wave_1,data_wave_2,data_wave_3);
                    data(:, :, :, count_input) = image1(x : size_input + x - 1, y : size_input + y - 1,:);
                    label(:, :, :, count_input)= GT1(x : size_input + x - 1, y : size_input + y - 1,:);
                    if rem(count_input,100)==0
                        
                        fprintf('processing the %d number of batch %d ..\n',count_input, batch)
                        
                    end
                    
                    
                    %
                    %                     end
                end
            end
            
        end
        
    end
    
    
    count=count_input;
    
    order = randperm(count);
    data = data(:, :, :, order);
    label = label(:, :, :, order);
    wave1 = data_wave_1(:, :, :, order);
    wave2 = data_wave_2(:, :, :, order);
    wave3 = data_wave_3(:, :, :, order);
    
    
    %% writing to HDF5
    %% writing to HDF5
    chunksz = 48; % chunksize
    created_flag = false;
    totalct = 0;
    
    for batchno = 1:floor(count/chunksz)
        last_read = (batchno-1)*chunksz;
        batchdata = data(:,:,:,last_read+1:last_read+chunksz);
        batchlabs = label(:,:,:,last_read+1:last_read+chunksz);
        batchwave1 = wave1(:,:,:,last_read+1:last_read+chunksz);
        batchwave2 = wave2(:,:,:,last_read+1:last_read+chunksz);
        batchwave3 = wave3(:,:,:,last_read+1:last_read+chunksz);
        
        startloc = struct('dat',[1,1,1,totalct+1], 'lab', [1,1,1,totalct+1], 'wave1',[1,1,1,totalct+1], 'wave2', [1,1,1,totalct+1], 'wave3', [1,1,1,totalct+1]);
        curr_dat_sz = store2hdf5_more_data(savepath, batchdata, batchlabs, batchwave1, batchwave2, batchwave3, ~created_flag, startloc, chunksz);
        created_flag = true;
        totalct = curr_dat_sz(end);
        
        
    end
    h5disp(savepath);
    batch
    toc
end




%%
%
%
% %% step  2 : for test hdf5
% %

name_list = textscan(fid1, formatSave);
name_list = name_list{1};
Tot_Len = length(name_list);

name_ind = 1:Tot_Len;
sub_Len = 960;
tot_batch = ceil(Tot_Len/sub_Len);
totalct = 0;
created_flag = false;
for batch =  1: tot_batch
    
    %% initialization
    
    savepath = strcat(savefolder, 'test_hdf5_64_pixel_3_wavelet',num2str(batch),'.h5');
    if exist(savepath,'file')
        continue
    end
    tic
    %% initialization
    count_input = 0;
    data_wave_1 =  [];%zeros(size_input/2,size_input/2,9,7800);
    data_wave_2 =  [];%zeros(size_input/4,size_input/4,9,7800);
    data_wave_3 =  [];%zeros(size_input/8,size_input/8,12,7800);
    %% generate data
    Len = batch;
    if Len*sub_Len < Tot_Len
        sel_randi = name_ind((Len-1)*sub_Len+1:Len*sub_Len);
    else
        sel_randi = name_ind((Len-1)*sub_Len+1:Tot_Len);
    end
    num_Qu=0;
    
    for ii = 1: length(sel_randi)
        i=sel_randi(ii);
        name_orig = name_list{i};
        % name of the following 2 slices
        
        
        
        load(name_orig);
        image1 = sub_im_3T;
        GT1 = sub_im_7T;
        image = double(image1).*255;
        GT = double(GT1).*255;
        
        
        
        [hei,wid,dim] = size(image); % LR subimage size
        
        % data and label
        for x = 1 : stride : hei - size_input + 1
            for y = 1 : stride : wid - size_input + 1
                
                sub_im = image(x : size_input + x - 1, y : size_input + y - 1,:);
                
                if (length(find(sub_im(:) ==0))  > size_input*size_input * 0.9)
                    continue
                else
                    
                    count_input = count_input + 1;
                    [data_wave_1, data_wave_2,data_wave_3] = inner_hist_norm_3(sub_im,thr_T,count_input,data_wave_1,data_wave_2,data_wave_3);
                    data(:, :, :, count_input) = image1(x : size_input + x - 1, y : size_input + y - 1,:);
                    label(:, :, :, count_input)= GT1(x : size_input + x - 1, y : size_input + y - 1,:);
                    if rem(count_input,100)==0
                        fprintf('processing the %d number of batch %d ..\n',count_input, batch)
                        
                    end
                    
                    
                    %
                    %                     end
                end
            end
            
        end
        
    end
    
    
 
    count=count_input;

    order = randperm(count);
    data = data(:, :, :, order);
    label = label(:, :, :, order);
    wave1 = data_wave_1(:, :, :, order);
    wave2 = data_wave_2(:, :, :, order);
    wave3 = data_wave_3(:, :, :, order);

    %% writing to HDF5
    chunksz = 64; % chunksize
    created_flag = false;
    totalct = 0;

    for batchno = 1:floor(count/chunksz)
        last_read = (batchno-1)*chunksz;
        batchdata = data(:,:,:,last_read+1:last_read+chunksz);
        batchlabs = label(:,:,:,last_read+1:last_read+chunksz);
        batchwave1 = wave1(:,:,:,last_read+1:last_read+chunksz);
        batchwave2 = wave2(:,:,:,last_read+1:last_read+chunksz);
        batchwave3 = wave3(:,:,:,last_read+1:last_read+chunksz);

        startloc = struct('dat',[1,1,1,totalct+1], 'lab', [1,1,1,totalct+1], 'wave1',[1,1,1,totalct+1], 'wave2', [1,1,1,totalct+1], 'wave3', [1,1,1,totalct+1]);
        curr_dat_sz = store2hdf5_more_data(savepath, batchdata, batchlabs, batchwave1, batchwave2, batchwave3, ~created_flag, startloc, chunksz);
        created_flag = true;
        totalct = curr_dat_sz(end);


    end
    h5disp(savepath);
    batch
    toc
    
    
    fprintf('--------------------------------------------------------------------------------------------\n')
    fprintf('\n The final processed  hdf5 files are saved in folder:\n',savefolder, '\n')
    fprintf('---------------------------------------Enjoy your code--------------------------------------\n')
end




