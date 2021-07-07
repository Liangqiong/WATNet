function data_process_nii_2_mat(filePath, savepath)
% data processing normalization and histgromatching
% 
% filePath = '/media/liangqiong/Data/liangqiong/Research/DeepLearning/Demo/Dataset/Orig_15/3T7T-Data/'
% savepath = '/media/liangqiong/Data/liangqiong/Research/DeepLearning/Demo/WATNet/matlab/demo/data_processing/data_15/'
warning('off','all')
if ~exist(savepath,'file')
    mkdir(savepath);
 
    
end


%% set parameters

% add the toolbox: 3D bilateral grid regression

% set input data

fprintf('Started..............\n');


sn = 1; % subject number
fprintf('*****  Subject # : %d  \n',sn);


n_subject=10;


%% patch size & window size

step=1;  %%2; %%1;  %%2;
patch_size=3; %%3;  %5; %%3; %%4;
window_size=9; %%15;  %21; %%13; %11;  %%23;  %%23; %11; %9;
half_window_C=floor(window_size/2);


half_patch=floor(patch_size/2);
half_window=floor(window_size/2);
half_search=floor((patch_size+window_size)/2);
% patch_size_C=1;
patch_size_C=patch_size;
half_patch_C=floor(patch_size_C/2);


%% 3D Image size to be processed
% image size: (191,282,300)
% Number of slices in Z direction
CSliceN=1;   % # of slices to be processed
dim=3;  % choose this if CSliceN = 1


o1=1; o2=2; o3=3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% step 1 loading the target file and normalization

s = 1;
traget_id = 1 
target_name = strcat('S', num2str(1)) ;

%

fName3T = strcat(filePath,'/S',num2str(traget_id),'/3t.img');
im3T = readHeaderInMatlab(fName3T);
im3TR(:,:,:,s)=(im3T-min(im3T(:)))/(max(im3T(:))-min(im3T(:)));

fName7T = strcat(filePath,'/S',num2str(traget_id),'/7t.img');
im7T = readHeaderInMatlab(fName7T);
im7TR(:,:,:,s)=(im7T-min(im7T(:)))/(max(im7T(:))-min(im7T(:)));

% step 2: loading all images, normalization and then crop non-zero regions 
for su = 2:10
    thrT_name =  strcat(filePath,'/S',num2str(su),'/3t.img');
    sevT_name =  strcat(filePath,'/S',num2str(su),'/7t.img');
    
    net_name = strcat('S', num2str(su));
    
    im3T = readHeaderInMatlab(thrT_name);
    im7T = readHeaderInMatlab(sevT_name);
    
    im3TR(:,:,:,su)=(im3T-min(im3T(:)))/(max(im3T(:))-min(im3T(:)));
    im7TR(:,:,:,su)=(im7T-min(im7T(:)))/(max(im7T(:))-min(im7T(:)));

end


padLen = 0;
[xMin, xMax, yMin, yMax, zMin, zMax] = imROIcrop(im3TR, padLen);


im3T_all = im3TR(xMin:xMax,yMin:yMax,zMin:zMax,:);
im7T_all = im7TR(xMin:xMax,yMin:yMax,zMin:zMax,:);
thrT_ref = im3T_all(:,:,:,1);
sevT_ref = im7T_all(:,:,:,1);
%% step3 : histgrom matching 
%
im3TV_id = thrT_ref;
im7TV_id = sevT_ref;
save([savepath 'MRI_3T_7T_' num2str(traget_id) '.mat'],'im3TV_id', 'im7TV_id');
%

for su = 2:10
    im3T = im3T_all(:,:,:,su);
    im7T = im7T_all(:,:,:,su);

    aa = imhistmatchx(im3T,thrT_ref);
    im3TV_id = squeeze(aa);
    aa = imhistmatchx(im7T,sevT_ref);
    im7TV_id = squeeze(aa);
    save([savepath 'MRI_3T_7T_' num2str(su) '.mat'],'im3TV_id', 'im7TV_id');
 
end


end
