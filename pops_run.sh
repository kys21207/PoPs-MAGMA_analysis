#!/bin/bash 

# Default paths
gwas_input_path="/mnt/project/geunity_data"
fixed_data_path="/mnt/project/publically_available_supporting_files/pops_data"
code_path="/mnt/project/analysis_KJ/pops_analysis/codes"
magma_out_path="/opt/notebooks/data"
magma_score_out_path="/opt/notebooks/data/magma_scores"
pops_output_path="/opt/notebooks/out"

# Function to display usage
usage() {
    echo "Usage: $0 -g <gwas_file_name>"
    exit 1
}

# Parse command-line arguments
while getopts ":g:" opt; do
    case $opt in
        g) gwas_file_name="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check if gwas_file_name is provided
if [ -z "$gwas_file_name" ]; then
    usage
fi

# Extract gwas_name_prefix from gwas_file_name by removing the file extension
gwas_name_prefix=$(basename "$gwas_file_name" .regenie.gz)

# Create directories if they don't exist
mkdir -p $magma_out_path
mkdir -p $magma_score_out_path
mkdir -p $pops_output_path

# Step 1: Assign rsID to GWAS result
Rscript ${code_path}/add_rsid_2regenie.R ${gwas_input_path}/${gwas_file_name} $gwas_name_prefix

# Step 2: Prepare MAGMA input files
zcat ${gwas_name_prefix}.gwaslab.gz | awk 'NR>1 {print $1, $2, $3}' > ${gwas_name_prefix}.magma.input.snp.chr.pos.txt
zcat ${gwas_name_prefix}.gwaslab.gz | awk 'NR>1 {print $1, 10^(-$4)}' > ${gwas_name_prefix}.magma.input.p.txt

# Step 3: Run MAGMA annotation
/opt/notebooks/codes/magma \
  --annotate \
  --snp-loc ${gwas_name_prefix}.magma.input.snp.chr.pos.txt \
  --gene-loc ${fixed_data_path}/gene_annotation_hg38_TSS.txt \
  --out ${magma_out_path}/${gwas_name_prefix}.magma

# Step 4: Run MAGMA gene analysis
/opt/notebooks/codes/magma \
  --bfile ${fixed_data_path}/g1000_eur_hg38 \
  --pval ${gwas_name_prefix}.magma.input.p.txt N=26119 \
  --gene-annot ${gwas_name_prefix}.magma.genes.annot \
  --gene-model snp-wise=mean \
  --out ${magma_score_out_path}/${gwas_name_prefix}.magma

# Step 5: Run POPS analysis
python3 /opt/notebooks/codes/pops.py \
  --gene_annot_path ${fixed_data_path}/gene_annotation_hg38_TSS.txt \
  --feature_mat_prefix ${fixed_data_path}/features_munged/pops_features \
  --num_feature_chunks 115 \
  --magma_prefix ${magma_score_out_path}/${gwas_name_prefix}.magma \
  --control_features_path ${fixed_data_path}/control.features \
  --out_prefix ${pops_output_path}/${gwas_name_prefix}.pops

