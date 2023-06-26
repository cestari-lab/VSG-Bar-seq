#   *** VSG-Bar-seq ***

## Description

This code is designed to split and map Oxford Nanopore reads for VSG-Bar-seq experiments. 
The script will split fastq files by barcode ID and then map the reads to the genome using minimap2 and samtools.
featureCounts will extract the genes and their read count from the alignment files for each barcode.
The last step on the script reports a "topmap" file in which for each barcode the feature with the most read counts is printed, along with the file name.

## Running requirements

To run the script, the tools minimap2, samtools, subread, and rcgrep are required. After installing or loading the required tools, run the script as indicated below: 

`sh vsg-barseq.sh path/to/directory path/to/fastq path/to/barcodes path/to/genome path/to/gtf nthreads`

## Contributing

If you'd like to contribute, please fork the repository and use a feature branch. Pull requests are warmly welcome.

## Licensing
The code in this project is licensed under a CC BY-NC 4.0 license. This means you can use it with proper attribution to original authors, indicating if any modifications were done, only for non commercial applications. (https://creativecommons.org/licenses/by-nc/4.0/)

## Links

If you want to see more of our work you can check out our website: https://www.cestarilab.com/
