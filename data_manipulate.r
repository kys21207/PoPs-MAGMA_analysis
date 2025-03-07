library(data.table)
library(dplyr)

input_file="L12_PSORIASIS_meta_out_filtered.tsv.gz"
# Read the gzipped input file
data <- fread(cmd = paste("gunzip -c", shQuote(input_file)), sep = "\t", header = TRUE)

#CHROM GENPOS ID ALLELE0 ALLELE1 A1FREQ N BETA SE CHISQ LOG10P INFO
#all_inv_var_meta_beta   all_inv_var_meta_sebeta all_inv_var_meta_p      all_inv_var_meta_mlogp  all_inv_var_het_p 
# Select and rename columns using dplyr
meta <- data[, .(CHROM = `#CHR`, GENPOS = POS, ID = SNP, ALLELE0 = REF, ALLELE1 = ALT, A1FREQ=0.1, N=100000,
                  BETA = all_inv_var_meta_beta, SE = all_inv_var_meta_sebeta, CHISQ=1, LOG10P = all_inv_var_meta_sebeta, INFO = NA)]
meta <- meta[!is.na(LOG10P)]

fwrite(meta, "meta_mvp_ukb_psoriasis.regenie.tsv.gz", sep = "\t", compress = "gzip")
