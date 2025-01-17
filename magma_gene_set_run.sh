#!/bin/bash

awk -F'\t' '{ gsub(" ", "_", $1); gsub(" ", "_", $2); print $0 }' OFS="\t" "/mnt/project/publically_available_supporting_files/pathway_gene_sets/Human_Reactome_January_04_2025_ensembl.gmt" > "data.gmt"


#for GENE_SET in "h.all" "c5.hpo" "c5.go.mf" "c5.go.cc" "c5.go.bp" "c2.cp.reactome"; do
/opt/notebooks/codes/magma \
  --gene-results /mnt/project/analysis_KJ/pops_analysis/magma_scores/ms_rrms.magma.genes.raw \
  --set-annot data.gmt \
  --out ms_rrms.magma.Human_Reactome
#done

