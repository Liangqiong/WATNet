## Note (brief introduction of WATNet)
This is a reference implementation for paper "Synthesizing 7T from 3T MRI via Deep Learning in Spatial and Wavelet Domains" (caffe implementation). In this paper, we introduce a novel deep learning network that fuses complementary information from spatial and wavelet domains to synthesize 7T T1-weighted images from their 3T counterparts.

The code has been tested on Linux (Ubuntu 14.04), using Caffe, Titan X GPU and on MATLAB 2018b.

Code is provided by Liangqiong Qu on 2019/08/16)


## Prerequisites
- Caffe and matcaffe: 
Change the makefile.config file according to the your own computer and build caffe as "http://caffe.berkeleyvision.org/installation.html"

- built code as: "make all -j8 && make matcaffe"

## Getting Started and Usage
### Dataset 
- The 3T/7T files are saved in folder "Dataset/Orig_15/3T7T-Data/" 

- Pre-processing of the dataset (including min-max normalization, histogram matching, and data augmentation)
`Run WATNet/matlab/demo/demo_processing_hdf5_for_train.m`
- Note that this demo also contains instruction for preparing hdf5 file. Step 3 is not required when testing

### Train a model
- Step 1: Preparing hdf5 file for Data processing
`Run WATNet/matlab/demo/demo_processing_hdf5_for_train.m `
- Step 2: cd to folder WATNet/examples/MRI/
% please change the files in AF_encod_3layer_decod_3input.prototxt to your own prepared hdf5 files
`Run bash train_MRI.sh`
* **Important in step 2:** Make sure changing the root in AF_encod_3layer_decod_3input.prototxt to your own prepared hdf5 root

### Test a pre-trained model: 

`Run WATNet/matlab/demo/test_AF_encod_3layer_decod_3input.m `


### Useful notes for train/test
- Pre-trained models and protoxt files for model definition are saved in folder WATNet/examples/MRI/
- WATNet was trained with the image patches extracted from 3T and 7T
images. The patch size was 64 × 64 × 3 (or lager size for better performance), covering 3 consecutive axial slices to promote inter-slice continuity
- Train with crop size 64×64×3, and then finetune on size 128×128×3 or even more lager size help produce better performance
- Test code are saved in folder "WATNet/matlab/demo"
- Initial results are saved in folder "WATNet/matlab/demo/Final_result/", you can use these results for comparisons



