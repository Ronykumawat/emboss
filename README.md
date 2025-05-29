# emboss
multithreading for emboss tool
# 🧬 Batch Palindrome Finder using EMBOSS

This is a simple and efficient bash script to find palindromic sequences in multiple DNA FASTA files using the `palindrome` tool from the EMBOSS package. It supports multi-threaded execution and works with custom parameters. You can use this to analyze large sets of genome or gene sequences for palindromic patterns.

---

## 📥 How to Use This Script

### Step 1: Clone the Repository

```bash
git clone https://github.com/Ronykumawat/emboss.git
cd emboss-palindrome-batch

⚙️ What You Need
This script requires:

EMBOSS (specifically, the palindrome tool)

Don't worry — the script automatically checks if EMBOSS is installed, and if not, it will try to install it using conda.

🧪 Input Format
Place your input files in a folder. These should be DNA FASTA files with extensions like .fa, .fasta, or .fna.

🚀 How to Run
Basic Command
./palindrome_batch.sh -i input_directory -o output_directory

Example:
./palindrome_batch.sh -i data/sequences -o results/palindromes -t 8 -e fa,fasta -min 12 -max 100 -overlap
This will:

Process .fa and .fasta files from data/sequences

Use 8 CPU threads

Look for palindromes of length 12 to 100

Allow overlapping palindromes

Save results in results/palindromes/

🔧 All Options Explained

| Option      | What It Does                                      | Default       |
| ----------- | ------------------------------------------------- | ------------- |
| `-i`        | Input directory containing FASTA files            | (required)    |
| `-o`        | Output directory where result files will be saved | (required)    |
| `-t`        | Number of parallel threads                        | 4             |
| `-e`        | File extensions to process (comma-separated)      | fa,fasta,fna  |
| `-min`      | Minimum palindrome length                         | 10            |
| `-max`      | Maximum palindrome length                         | 100           |
| `-gap`      | Max gap between arms of a palindrome              | 100           |
| `-mismatch` | Number of mismatches allowed in palindromes       | 0             |
| `-overlap`  | Include overlapping palindromes                   | Off (default) |
| `-h`        | Show help message                                 | —             |

📁 Output
All result files are saved with .palindrome extension in your output folder.

If any files fail to process, they are listed in a file called failed_files.log.

🧑‍💻 Author
Rounak Kumawat

📧 kumawatrounak9@gmail.com

🌐 GitHub: github.com/Ronykumawat/emboss

🪪 License
This project is licensed under the Apache License 2.0. You are free to use, modify, and share it.

