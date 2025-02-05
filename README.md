# PoPs-MAGMA

Download Pops codes from https://github.com/FinucaneLab/pops
Download Pops features from https://www.dropbox.com/sh/o6t5jprvxb8b500/AADZ8qD6Rpz4uvCk0b5nUnPaa/data?dl=0&subfolder_nav_tracking=1
  * Note: 1000G data and gene_loci data are based on hg19, not hg38.
  * Before running the Munge features, you should extract PoPs.features.txt.gz and put in the features_raw 
    

## 1. Munge features
python /opt/notebooks/codes/munge_feature_directory.py \
 --gene_annot_path /mnt/project/publically_available_supporting_files/pops_features/gene_annotation_hg38_TSS.txt \
 --feature_dir /opt/notebooks/features_raw/ \
 --save_prefix /opt/notebooks/pops_data/pops_features \
 --max_cols 500

### Generate gene annotation file using Generate_gene_annotation.R (hg38) that automatically calculates TSS.
### Download 1000g reference from the below 

1000 genome reference panel hg38 Download
pgen=https://www.dropbox.com/s/afvvf1e15gqzsqo/all_phase3.pgen.zst?dl=1
pvar=https://www.dropbox.com/s/op9osq6luy3pjg8/all_phase3.pvar.zst?dl=1
sample=https://www.dropbox.com/s/yozrzsdrwqej63q/phase3_corrected.psam?dl=1
And filter 1st+2nd degree: deg2_hg38.king.cutoff.out.id (629 samples) and keep only EUR (as needed)

## 2. Run PoPs analysis using run_multi_traits.sh

Pathway gene-set data: Index of /EM_Genesets/current_release/Human/ensembl/Pathways (https://download.baderlab.org/EM_Genesets/current_release/Human/ensembl/Pathways/)
The data was generated with ENSGID. 

## 3. Description for Results
### *.preds
- Y
Description: The gene-level association statistic derived from GWAS (often computed using tools like MAGMA). <br>
This value may represent the raw association score before adjustments or normalizations are applied. <br>
Example: Missing ("") here, but typically contains GWAS-derived statistics. <br>
- Y_proj
Description: The projection of the gene-level association statistic (Y) after accounting for covariates. <br>
This adjusted score removes biases due to covariates like gene size, SNP density, etc. <br>
Example: -0.5722362045076061 is an adjusted value for a specific gene. <br>
- project_out_covariates_gene
Description: A binary indicator (True or False) that shows whether the gene's association statistic (Y) has been projected out (adjusted) to remove the effects of covariates. <br>
Example: <br>
True: Indicates that the gene's score has been adjusted for covariates. <br>
False: Indicates no adjustment was applied. <br>
- feature_selection_gene
Description: A binary indicator (True or False) that shows whether the gene passed the feature selection step. <br>
Feature selection identifies significant gene features (e.g., pathways, expression levels) that contribute to prioritization. <br>
Example: <br>
True: Indicates the gene was selected based on feature significance. <br>
False: Indicates the gene did not pass feature selection. <br>
- training_gene
Description: A binary indicator (True or False) that shows whether the gene was included in the training set for the PoPS model. <br>
Some genes may be excluded due to missing data, quality issues, or their use as a test set for validation. <br>
Example: <br>
True: Indicates the gene was used for training the PoPS model. <br>
False: Indicates the gene was not used for training. <br>
