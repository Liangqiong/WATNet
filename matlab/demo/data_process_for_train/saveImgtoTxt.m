function saveImgtoTxt(folder,savefolder , txt_name, test_id_num)

% folder  % the path where mat files are saved
% savefolder % the path save the txt files
% txt_name:  base name for save the text files

if ~exist(savefolder,'file')
    mkdir(savefolder)
end

filenames = dir(folder);
filenames_new = filenames(3:end);
filenames = filenames_new;


% for test_id_num = 1:10
test_id = strcat('S',num2str(test_id_num));

txt_train_name = strcat(savefolder, txt_name , '_', test_id, '.txt');
txt_test_name = strcat(savefolder, txt_name ,'_', test_id, '.txt');
tot_img_files = [];

count = 0;
for su = 1:length(filenames)
    name = filenames(su).name;
    
    if contains(test_id, name)
        continue
    end
    
    tmp_path = strcat(folder,name,'/');
    
    img_files = dir(fullfile(tmp_path,'*.mat'));
    for i = 1:length(img_files)
        img_files(i).name = strcat(tmp_path, img_files(i).name );
    end
    if count ==0
        tot_img_files = img_files;
    else
        tot_img_files = [img_files;tot_img_files];
    end
    
    count = count + 1;
    
    
end



% random save these items




name_rand =randperm(length(tot_img_files));
fid=fopen(txt_train_name,'w');

formatSave = '%s \n';


for i = 1:1:length(name_rand)
    ii=name_rand(i);
    net_name = tot_img_files(ii).name;
    fprintf(fid, formatSave,net_name);
    
end
fclose(fid)
fprintf(['Saving the training txt files of subject' num2str(test_id_num) 'to: \n', txt_train_name, '\n']);



%% --- step 2----  for the testing files



count = 0;
clear tot_img_files
for su = 1:length(filenames)
    name = filenames(su).name;
    
    if contains(test_id, name)
        inner_count = 0;
        
        
        tmp_path = strcat(folder,name,'/');
        
        img_files = dir(fullfile(tmp_path,'*.mat'));
        for i = 1:length(img_files)
            name = img_files(i).name;
            end_name = name(end-5:end);
            if strcmp(end_name,'_0.mat')
                inner_count = inner_count + 1;
                new_img_files(inner_count).name = strcat(tmp_path, img_files(i).name );
            end
        end
        if count ==0
            tot_img_files = new_img_files';
        else
            tot_img_files = [tot_img_files;new_img_files'];
        end
        
        count = count + 1;
    end
    
end



%% random save these items




name_rand =randperm(length(tot_img_files));
fid1=fopen(txt_test_name,'w');

formatSave = '%s \n';


for i = 1:1:length(name_rand)
    ii=name_rand(i);
    net_name = tot_img_files(ii).name;
    fprintf(fid1, formatSave,net_name);
end
fclose(fid1)
fprintf(['Saving the test txt files of subject' num2str(test_id_num) 'to: \n', txt_test_name, '\n']);


end

