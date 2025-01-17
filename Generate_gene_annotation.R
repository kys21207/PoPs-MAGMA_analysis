############################################################################### 
# 1) Load libraries
###############################################################################
library(biomaRt)

###############################################################################
# 2) Connect to Ensembl GRCh38
###############################################################################
# You can specify "ensembl" (default, typically uses latest version) 
# or pick a specific Ensembl release with useEnsembl(..., version=XX).
# For GRCh38 / human genes:
mart <- useEnsembl(biomart = "genes", 
                   dataset = "hsapiens_gene_ensembl", 
                   version = NULL)  # or set a specific version if needed

###############################################################################
# 3) Retrieve gene-level attributes
###############################################################################
# We'll retrieve:
#   - ensembl_gene_id
#   - chromosome_name
#   - start_position (gene start)
#   - end_position   (gene end)
#   - strand
# 
# These positions are based on GRCh38 (a.k.a. hg38).
###############################################################################
gene_df <- getBM(
  attributes = c("ensembl_gene_id", 
                 "chromosome_name", 
                 "start_position", 
                 "end_position",
                 "strand"),
  mart = mart
)

###############################################################################
# 4) Filter to standard chromosomes (optional)
###############################################################################
# Many rows may have patches or haplotype chromosomes.
# If you only want primary autosomes + X + Y + MT, use:
valid_chroms <- c(1:22, "X", "Y", "MT")
gene_df <- gene_df[ gene_df$chromosome_name %in% valid_chroms, ]

###############################################################################
# 5) Compute TSS
###############################################################################
# For a forward (+) strand gene (strand == 1), TSS is the START.
# For a reverse (–) strand gene (strand == -1), TSS is the END.
###############################################################################
gene_df$TSS <- ifelse(gene_df$strand == 1, 
                      gene_df$start_position, 
                      gene_df$end_position)

###############################################################################
# 6) Rename columns to your desired final format
#    ENSGID, CHR, START, END, TSS
###############################################################################
names(gene_df)[names(gene_df) == "ensembl_gene_id"]  <- "ENSGID"
names(gene_df)[names(gene_df) == "chromosome_name"]  <- "CHR"
names(gene_df)[names(gene_df) == "start_position"]   <- "START"
names(gene_df)[names(gene_df) == "end_position"]     <- "END"

# 'TSS' is already added, so that’s fine.

###############################################################################
# 7) (Optional) Sort the table by chromosome and then by TSS
###############################################################################
# Convert CHR to a factor with an order (1..22, X, Y, MT).
# Or keep it as is. Sorting is often helpful if you want a neat file.
###############################################################################
# If you want a numeric sort for chr 1..22, with X, Y, MT last, do:
gene_df$CHR <- factor(gene_df$CHR, 
                      levels = c(as.character(1:22), "X", "Y", "MT"),
                      ordered = TRUE)
gene_df <- gene_df[order(gene_df$CHR, gene_df$TSS), ]

###############################################################################
# 8) Write out final file
###############################################################################
out_file <- "gene_annotation_grch38_TSS.txt"
write.table(
  gene_df,
  file      = out_file,
  sep       = "\t",
  row.names = FALSE,
  quote     = FALSE
)

# Done!

