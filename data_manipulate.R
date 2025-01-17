library(data.table) 

# Get input arguments
args <- commandArgs(trailingOnly = TRUE)
gwas_file_path <- args[1]
output_prefix <- args[2]

# Read demo file containing SNPID and rsID
demo_file <- fread("demo.gwaslab.gz", header = TRUE)
demo_file <- demo_file[!is.na(rsID)] 

# Read input GWAS file
raw_file <- fread(gwas_file_path, header = TRUE)

# Remove the EXTRA column if present
if ("EXTRA" %in% names(raw_file)) {
  raw_file <- raw_file[, !("EXTRA"), with = FALSE]
}

# Merge GWAS with rsID information
merged_file <- merge(raw_file, demo_file[, .(SNPID, rsID)], by.x = "ID", by.y = "SNPID")

# Remove rows with missing rsID
merged_file <- merged_file[!is.na(rsID)]

# Select columns for output
selected_cols <- merged_file[, .(rsID, CHROM, GENPOS, LOG10P)]

# Save output as a gzipped file
output_file <- paste0(output_prefix, ".gwaslab.gz")
fwrite(selected_cols, output_file, sep = "\t", compress = "gzip")

