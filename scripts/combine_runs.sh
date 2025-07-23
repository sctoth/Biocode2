#!/bin/bash
# ----------------Parameters---------------------- #
#$ -S /bin/bash
#$ -pe mthread 16
#$ -q sThC.q
#$ -l mres=32G,h_data=2G,h_vmem=2G
#$ -cwd
#$ -j y
#$ -N combine_runs_biocode2_M997_Coral_1286
#$ -o combine_runs_biocode2_M997_Coral_1286_$TASK_ID.log
#$ -t 1 -tc 40
# ------------------------------------ #

# Directory containing fastq files
RUN1_DIR="/scratch/nmnh_ocean_dna/SeqRuns/genohub40000024_Biocode2_01/run1/trimmed_fastq"
RUN2_DIR="/scratch/nmnh_ocean_dna/Biocode2/genohub40000024/run2/M997_Coral_1286_trimmed_fastq"
OUTPUT_DIR="/scratch/nmnh_ocean_dna/Biocode2/genohub40000024/combined_runs/M997_Coral_1286"
SAMPLE_LIST="/scratch/nmnh_ocean_dna/SeqRuns/genohub40000024_Biocode2_01/run2/coral_file_newname.txt"

mkdir -p "$OUTPUT_DIR"

# Read all sample basenames into an array
mapfile -t samples < "$SAMPLE_LIST"

# Get the current task ID (SGE array index)
idx=$((SGE_TASK_ID - 1))  # zero-based index for bash arrays

sample="${samples[$idx]}"

echo "Processing sample $sample (index $idx), task ID: $SGE_TASK_ID"

# Define file paths for R1 and R2 for run1
# example BMOO_01972_M997_S54_run1_R2_trimmed.fastq.gz
run1_R1=$(find "$RUN1_DIR" -type f -name "*${sample}*run1_R1_trimmed.fastq.gz" | head -n 1)
run1_R2=$(find "$RUN1_DIR" -type f -name "*${sample}*run1_R2_trimmed.fastq.gz" | head -n 1)


# Instead of hardcoded run2 filenames:
# Example: 20250716-run-BMOO_01972_M997_S54_run2_R1_trimmed.fastq.gz 
run2_R1=$(find "$RUN2_DIR" -type f -name "*${sample}*run2_R1_trimmed.fastq.gz" | head -n 1)
run2_R2=$(find "$RUN2_DIR" -type f -name "*${sample}*run2_R2_trimmed.fastq.gz" | head -n 1)

if [[ -z "$run1_R1" || -z "$run1_R2" ]]; then
  echo "Warning: missing run1 files for sample $sample"
fi

if [[ -z "$run2_R1" || -z "$run2_R2" ]]; then
  echo "Warning: missing run2 files for sample $sample"
fi


# Output combined filenames
combined_R1="${OUTPUT_DIR}/${sample}_combined_R1_trimmed.fastq.gz"
combined_R2="${OUTPUT_DIR}/${sample}_combined_R2_trimmed.fastq.gz"

# Check and concatenate R1 files
if [[ -f "$run1_R1" && -f "$run2_R1" ]]; then
  echo "Concatenating R1 files for $sample..."
  cat "$run1_R1" "$run2_R1" > "$combined_R1"
else
  echo "Warning: missing R1 files for $sample"
fi

# Check and concatenate R2 files
if [[ -f "$run1_R2" && -f "$run2_R2" ]]; then
  echo "Concatenating R2 files for $sample..."
  cat "$run1_R2" "$run2_R2" > "$combined_R2"
else
  echo "Warning: missing R2 files for $sample"
fi

echo "Finished processing sample $sample"
