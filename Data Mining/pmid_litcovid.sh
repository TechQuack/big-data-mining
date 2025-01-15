echo "Récupération des PMID de LitCovid"

# Define the input and output files
input_file="result_basex.txt"
output_file="pmid_list.txt"

# Extract unique PMIDs (numbers at the beginning of each line) and save to output file
awk -F'/' '{print $1}' "$input_file" | sort -u > "$output_file"

echo "Extraction terminée. Les PMIDs uniques sont dans $output_file"
