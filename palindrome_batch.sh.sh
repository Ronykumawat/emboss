#!/bin/bash

# Defaults
THREADS=4
MIN_PAL=10
MAX_PAL=100
GAP_LIMIT=100
MISMATCHES=0
OVERLAP="N"
EXTENSIONS=("fa" "fasta" "fna")
LOGFILE="failed_files.log"

# Function to check/install EMBOSS
install_emboss() {
    if ! command -v palindrome &> /dev/null; then
        echo "EMBOSS 'palindrome' tool not found. Attempting to install..."

        # Try conda first
        if command -v conda &> /dev/null; then
            echo "Installing EMBOSS using conda..."
            conda install -y -c bioconda emboss
        else
            echo "Conda not found. Please install EMBOSS manually or install conda first."
            exit 1
        fi
    else
        echo "'palindrome' tool from EMBOSS is already installed."
    fi
}

print_help() {
    cat << EOF
Usage: $(basename "$0") -i INPUT_DIR -o OUTPUT_DIR [options]

Required arguments:
  -i DIR          Input directory containing sequence files
  -o DIR          Output directory for palindrome files

Optional arguments:
  -t THREADS      Number of parallel threads (default: $THREADS)
  -e EXTENSIONS   Comma-separated list of file extensions to process (default: ${EXTENSIONS[*]})
  -min N          Minimum palindrome length (default: $MIN_PAL)
  -max N          Maximum palindrome length (default: $MAX_PAL)
  -gap N          Gap limit (default: $GAP_LIMIT)
  -mismatch N     Number of mismatches allowed (default: $MISMATCHES)
  -overlap        Allow overlapping palindromes (default: $OVERLAP)
  -h              Show this help message and exit

Example:
  $(basename "$0") -i input_seqs -o output_palindromes -t 8 -e fa,fasta -min 12 -max 100 -overlap
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i) INPUT_DIR="$2"; shift ;;
        -o) OUTPUT_DIR="$2"; shift ;;
        -t) THREADS="$2"; shift ;;
        -e) IFS=',' read -ra EXTENSIONS <<< "$2"; shift ;;
        -min) MIN_PAL="$2"; shift ;;
        -max) MAX_PAL="$2"; shift ;;
        -gap) GAP_LIMIT="$2"; shift ;;
        -mismatch) MISMATCHES="$2"; shift ;;
        -overlap) OVERLAP="Y" ;;
        -h) print_help; exit 0 ;;
        *) echo "Unknown option: $1"; print_help; exit 1 ;;
    esac
    shift
done

# Validate input
if [[ -z "$INPUT_DIR" || -z "$OUTPUT_DIR" ]]; then
    echo "Error: Input and output directories required!"
    print_help
    exit 1
fi

# Install EMBOSS if needed
install_emboss

mkdir -p "$OUTPUT_DIR"
rm -f "$LOGFILE"
touch "$LOGFILE"

# Gather input files
FILES=()
for ext in "${EXTENSIONS[@]}"; do
    while IFS= read -r -d '' file; do
        FILES+=("$file")
    done < <(find "$INPUT_DIR" -type f -iname "*.$ext" -print0)
done

input_count=${#FILES[@]}
if [[ $input_count -eq 0 ]]; then
    echo "No input files found with extensions: ${EXTENSIONS[*]}"
    exit 0
fi

# Function to process one file
run_palindrome() {
    local file="$1"
    local relpath="${file#$INPUT_DIR/}"
    local outname="${relpath//\//_}"
    outname="${outname%.*}.palindrome"
    local outfile="$OUTPUT_DIR/$outname"

    if ! palindrome -sequence "$file" \
        -minpallen "$MIN_PAL" \
        -maxpallen "$MAX_PAL" \
        -gaplimit "$GAP_LIMIT" \
        -nummismatches "$MISMATCHES" \
        -outfile "$outfile" \
        -overlap "$OVERLAP" > /dev/null 2>&1; then
        echo "$file" >> "$LOGFILE"
    fi
}

export -f run_palindrome
export INPUT_DIR OUTPUT_DIR MIN_PAL MAX_PAL GAP_LIMIT MISMATCHES OVERLAP LOGFILE

# Process files in parallel
printf "%s\0" "${FILES[@]}" | xargs -0 -n1 -P "$THREADS" bash -c 'run_palindrome "$0"'

# Count output files
output_count=$(find "$OUTPUT_DIR" -type f | wc -l)

echo "Input files found: $input_count"
echo "Output files generated: $output_count"

if [[ $input_count -eq $output_count ]]; then
    echo "All files processed successfully."
else
    echo "Warning: Number of output files differs from input files."
fi

if [[ -s "$LOGFILE" ]]; then
    echo "Some files failed. See $LOGFILE"
fi
